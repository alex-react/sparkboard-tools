_ = require("underscore")

###
    
    Create a subscription object that uses one firebase ref as
    an 'index' of IDs to fetch from another firebase ref.
    
    Example:

    # Will look up post IDs in /users/#{ownerId}/writing,
    # and fetch the actual posts from /posts.

    firebaseRelationalSubscription
      indexRef: new Firebase(FIREBASE_URL+'/users/'+ownerId+'/writing').limit(limit)
      dataRef: new Firebase(FIREBASE_URL+'/posts')
      ref: new Firebase(FIREBASE_URL+'/writing')
      shouldUpdateSubscription: (oldProps, newProps) ->
        oldProps.settings.ownerId != newProps.settings.ownerId
      query: (ref, done) -> done(ref.limit(limit))
      default: _([])
      server: true
      parseObject: (snapshot) ->
          post = snapshot.val()
          post.id = snapshot.name()
          post
      parseList: (list) -> list.reverse()

###


# TODO: these subscriptions do not update when new children are added
module.exports = (manifest) ->
    _.extend manifest, 
    handlers: {}
    models: {}
    modelIndex: []
    modelIndexRemoved: []
    parseObject: manifest.parseObject || (snapshot) ->
        obj = snapshot.val() || {}
        obj.priority = snapshot.getPriority()
        obj.id = snapshot.name()
        obj
    parseList: manifest.parseList || (list) -> list
    exportModels: ->
        list = _.chain(@models).pairs().map((pair) -> pair[1]).sortBy((object)->object.priority)
        @parseList list.value()
    subscribe: (callback, options={}) ->
        exportAllModels = =>
            if _(@models).keys().length == @modelIndex.length # or options.wait != true
                callback(@exportModels()) 

        updateObject = (snapshot) =>
            @models[snapshot.name()] = @parseObject(snapshot)
            exportAllModels()

        cancelUpdateObject = (id) =>
            =>
                @modelIndex = _.without @modelIndex, id
                @modelIndexRemoved.push(id)
                exportAllModels()
        addChild = (id) =>
            childRef = manifest.dataRef.child(id)
            childRef.on "value", updateObject, cancelUpdateObject(id)
            @handlers[id] = 
                fn: updateObject
                ref: childRef

        removeChild = (id) =>
            @handlers[id]?.ref.off("value", @handlers[id].fn)
            delete @handlers[id]
            delete @models[id]
        manifest.indexRef.on "value", (snapshot) =>
            currentKeys = _(snapshot.val()).keys()
            existingKeys = _(@models).keys().concat(@modelIndexRemoved)
            removedKeys = _(existingKeys).without currentKeys
            newKeys = _(currentKeys).without existingKeys

            @modelIndex = _(currentKeys).without @modelIndexRemoved

            for key in removedKeys
                removeChild(key)
            for key in newKeys
                addChild(key)

            exportAllModels()

        

    unsubscribe: ->
        manifest.indexRef.off()
        for key, object of @handlers
            object.ref.off "value", object.fn
            delete @handlers[key]
            delete @models[key]
        @modelIndex = []
    manifest