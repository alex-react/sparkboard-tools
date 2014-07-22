// Generated by CoffeeScript 1.7.1
(function() {
  var fs;

  fs = require("fs");

  this.saveFirebaseToFile = function(ref, savePath) {
    return ref.on("value", function(snap) {
      return fs.writeFileSync(snap.val().toJSON(), savePath);
    });
  };

  this.goOfflineWithData = function(ref, loadPath) {
    var dataFile;
    ref.goOffline();
    dataFile = fs.readFileSync(loadPath);
    return ref.set(JSON.parse(dataFile));
  };

}).call(this);