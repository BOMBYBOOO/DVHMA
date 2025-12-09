var exec = require("cordova/exec");

exports.listen = function (success, error) {
    exec(success, error, "DeepLink", "listen", []);
};
