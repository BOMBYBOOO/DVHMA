cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "de.zertapps.dvhma.plugins.deeplink.DeepLink",
      "file": "plugins/de.zertapps.dvhma.plugins.deeplink/www/deeplink.js",
      "pluginId": "de.zertapps.dvhma.plugins.deeplink",
      "clobbers": [
        "deeplink"
      ]
    },
    {
      "id": "de.zertapps.dvhma.plugins.webintent.WebIntent",
      "file": "plugins/de.zertapps.dvhma.plugins.webintent/www/webintent.js",
      "pluginId": "de.zertapps.dvhma.plugins.webintent",
      "clobbers": [
        "webintent"
      ]
    },
    {
      "id": "de.zertapps.dvhma.plugins.storage.DVHMA-Storage",
      "file": "plugins/de.zertapps.dvhma.plugins.storage/www/DVHMA-Storage.js",
      "pluginId": "de.zertapps.dvhma.plugins.storage",
      "clobbers": [
        "window.todo"
      ]
    }
  ];
  module.exports.metadata = {
    "de.zertapps.dvhma.plugins.deeplink": "1.0.0",
    "de.zertapps.dvhma.plugins.webintent": "1.0.0",
    "de.zertapps.dvhma.plugins.storage": "1.0.0"
  };
});