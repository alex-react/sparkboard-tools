###

  Turn a firebase manifest into a subscription object.

###

module.exports = (manifest) ->
  manifest.subscribe = (updateDataCallback) ->
    manifest.query = manifest.query || (ref, cb) -> cb(ref)
    manifest.query manifest.ref, (ref) =>
      manifest.queryRef = ref
      manifest.__callback = (snapshot) ->
        parse = manifest.parse || (snapshot) -> snapshot.val()
        value = parse(snapshot)
        updateDataCallback(value)
      ref.on "value", manifest.__callback
  manifest.unsubscribe = ->
      manifest.queryRef.off "value", manifest.__callback
  manifest