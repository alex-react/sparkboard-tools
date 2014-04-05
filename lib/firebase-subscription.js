// Generated by CoffeeScript 1.7.1

/*

  Turn a firebase manifest into a subscription object.
 */

(function() {
  module.exports = function(manifest) {
    manifest.subscribe = function(updateDataCallback) {
      manifest.query = manifest.query || function(ref, cb) {
        return cb(ref);
      };
      return manifest.query(manifest.ref, (function(_this) {
        return function(ref) {
          manifest.queryRef = ref;
          manifest.__callback = function(snapshot) {
            var parse, value;
            parse = manifest.parse || function(snapshot) {
              return snapshot.val();
            };
            value = parse(snapshot);
            return updateDataCallback(value);
          };
          return ref.on("value", manifest.__callback);
        };
      })(this));
    };
    manifest.unsubscribe = function() {
      return manifest.queryRef.off("value", manifest.__callback);
    };
    return manifest;
  };

}).call(this);