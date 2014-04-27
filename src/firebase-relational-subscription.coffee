_ = require("underscore")

module.exports = (manifest) ->
    _.extend manifest, 
    handlers: {}
    models: {}
    modelIndex: []
    parseObject: manifest.parseObject || (snapshot) ->
        obj = snapshot.val()
        obj.priority = snapshot.getPriority()
        obj.id = snapshot.name()
        obj
    parseList: manifest.parseList || (list) -> list
    exportModels: ->
        # modelList = []
        # for key in @modelIndex
        #     modelList.push @models[key] if @models[key]
        # modelList
        list = _.chain(@models).pairs().map((pair) -> pair[1]).sortBy((object)->object.priority)
        @parseList list.value()
    subscribe: (callback, options={}) ->
        updateObject = (snapshot) =>
            @models[snapshot.name()] = @parseObject(snapshot)
            if _(@models).keys().length == @modelIndex.length # or options.wait != true
                callback(@exportModels()) 

        manifest.indexRef.on "child_added", (snapshot) =>
            @modelIndex.push snapshot.name()
            childRef = manifest.dataRef.child(snapshot.name())
            childRef.on "value", updateObject
            @handlers[snapshot.name()] = 
                fn: updateObject
                ref: childRef

        manifest.indexRef.on "child_removed", (snapshot) =>
            key = snapshot.name()
            @modelIndex = _(@modelIndex).without key
            delete @handlers[key]
            delete @models[key]
            callback(@exportModels())

    unsubscribe: ->
        manifest.indexRef.off()
        for key, object of @handlers
            object.ref.off()
            delete @handlers[key]
            delete @models[key]
        @modelIndex = []
    manifest