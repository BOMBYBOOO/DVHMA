/*  Copyright 2015 SAP SE
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at

 *     http://www.apache.org/licenses/LICENSE-2.0

 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

function onDeviceReady() {
	console.log("[DVHMA] device ready fired");
	listenForIOSIntent();
	checkForExtraText();
	deeplink.listen(function(url){
    console.log("[DeepLink] Received URL:", url);

    let p = new URL(url).searchParams;

    let title = p.get("EXTRA_SUBJECT");
    let content = p.get("EXTRA_TEXT");

    if (title || content) {
        window.todo.create([{ title, content }], reloadItems, logError);
    }

}, logError);

}


function listenForIOSIntent() {
    window.webintent.getIntent(function(intent) {

        if (!intent || !intent.data) return;

        var params = intent.data;

        // If we received title/content → save it into DB
        if (params.title || params.content) {
            var item = {
                title: params.title || "NoTitle",
                content: params.content || "NoContent"
            };

            window.todo.create([item], reloadItems, logError);
        }

    }, logError);
}

function logError(error) {
	console.log(error);
}

function checkForExtraText() {
    console.log("[WebIntent] Checking for EXTRA_TEXT");

    window.webintent(window.webintent.EXTRA_TEXT, function(content) {
        console.log("[WebIntent] EXTRA_TEXT value:", content);

        window.webintent(window.webintent.EXTRA_SUBJECT, function(title) {
            console.log("[WebIntent] EXTRA_SUBJECT =", title);

            window.todo.create([{title, content}], reloadItems, logError);

        }, function(err){
            console.log("[WebIntent] No subject:", err);
        });

    }, function(err) {
        console.log("[WebIntent] No EXTRA_TEXT:", err);
        window.todo.get(reloadItems, logError);
    });
}



function onRemoveItem(e) {
	window.todo.delete([e.target.parentNode.parentNode.dataset.id], reloadItems, logError);
}

function onEditItem(e) {
	var id = e.target.parentNode.parentNode.dataset.id;
	window.todo.get(function(items) {
		var oldTitle = items[id]["title"];
		var oldContent = items[id]["content"];
		var newTitle = prompt("Enter title", oldTitle);
		if (newTitle == null) {
			newTitle = oldTitle;
		}
		var newContent = prompt("Enter content", oldContent);
		if (newContent == null) {
			newContent = oldContent;
		}
		window.todo.edit([id, {"title" : newTitle, "content" : newContent}], reloadItems, logError);
	}, logError);
}

function onLoadContent(e) {
	var contentDiv = e.target.parentNode.parentNode.parentNode.getElementsByClassName("content")[0];
	if (contentDiv.dataset.loaded == "true") {
		contentDiv.innerHTML = '';
		contentDiv.dataset.loaded = false;
		contentDiv.parentNode.getElementsByTagName("img")[0].src = "img/ic_action_expand.png";
	} else {
		window.todo.get(function(items) {
			var id = e.target.parentNode.parentNode.dataset.id;
			contentDiv.parentNode.getElementsByTagName("img")[0].src = "img/ic_action_collapse.png";
			contentDiv.innerHTML = items[id]["content"];
			contentDiv.dataset.loaded = true;
		}, logError);
	}
}

function reloadItems(items) {
	var itemsDiv = document.getElementById("items");
	while (itemsDiv.hasChildNodes()) {
		itemsDiv.removeChild(itemsDiv.firstChild);
	}
	
	for (i = 0; i < items.length; i++) {
		var entry = items[i]["title"];
	
		var div = document.createElement("div");
		
		var headDiv = document.createElement("div");
		headDiv.setAttribute("data-id", i);
		headDiv.className = "title";
		
		var span = document.createElement("span");
		var img = document.createElement("img");
		img.src = "img/ic_action_expand.png";
		img.addEventListener("click", onLoadContent);
		span.appendChild(img);
		headDiv.appendChild(span);
		
		var p = document.createElement("p");
		p.innerHTML = entry;
		headDiv.appendChild(p);
		
		var buttonDiv = document.createElement("div");
		buttonDiv.className = "editRemoveButtons";
		
		var editButton = document.createElement("button");
		editButton.innerHTML = "Edit";
		editButton.addEventListener("click", onEditItem);
		buttonDiv.appendChild(editButton);
		
		var removeButton = document.createElement("button");
		removeButton.innerHTML = "Remove";
		removeButton.addEventListener("click", onRemoveItem);
		buttonDiv.appendChild(removeButton);
		headDiv.appendChild(buttonDiv);
		
		div.appendChild(headDiv);
		
		var contentDiv = document.createElement("div");
		contentDiv.className = "content";
		contentDiv.dataset.loaded = false;
		div.appendChild(contentDiv);
		
		itemsDiv.appendChild(div);
	}
}

function onNewItemClick() {
	window.todo.create([{"title" : "NewTitle", "content" : "New Content"}], reloadItems, logError);
}

document.addEventListener("deviceready", onDeviceReady);
