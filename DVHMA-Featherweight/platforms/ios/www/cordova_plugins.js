cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
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
    "de.zertapps.dvhma.plugins.storage": "1.0.0"
  };
});