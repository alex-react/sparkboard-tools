###

  Turn a firebase manifest into a subscription object.

###

module.exports = (manifest) ->
  manifest.subscribe = (updateDataCallback) ->
    manifest.query = manifest.query || (ref, cb) -> cb(ref)
    manifest.query manifest.ref, (ref) =>
      if ref == null
        manifest.inactive = true
        updateDataCallback(manifest.default)
        return
      manifest.queryRef = ref
      updateObject = (snapshot) ->
        parse = manifest.parse || (snapshot) -> snapshot.val()
        value = parse(snapshot)
        updateDataCallback(value)
      cancelUpdateObject = ->
        updateDataCallback(manifest.default)
        
      ref.on "value", updateObject, cancelUpdateObject
  manifest.unsubscribe = ->
      if manifest.inactive != true
        manifest.queryRef?.off() # "value", manifest.__callback
  manifest