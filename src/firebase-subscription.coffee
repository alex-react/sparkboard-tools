###

  Turn a firebase manifest into a subscription object.

  Example of a firebase manifest:

    ref: new Firebase(FIREBASE_URL+"/posts/"+id)
    default: {}
    parse: (snapshot) ->
        # modify the snapshot before setting into props
        post = snapshot.val()
        post.date = snapshot.getPriority() if post
        post.id = snapshot.name() if post
        post                    
    shouldUpdateSubscription: (oldProps, newProps) ->
        # a subscription can depend on the component's props.
        # when props change, we can optionally re-initialize
        # a subscription.
        oldProps.matchedRoute.params.id != newProps.matchedRoute.params.id


  Example of a subscription object:

  subscription = 
    subscribe: (callback) ->
      # whenever data changes, runs callback(data)
    unsubscribe: ->
      # cleans up

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