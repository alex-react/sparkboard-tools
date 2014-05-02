_ = require("underscore")

module.exports = (manifest) ->
    _.extend manifest, 
    handlers: {}
    models: {}
    modelIndex: []
    modelIndexRemoved: []
    parseObject: manifest.parseObject || (snapshot) ->
        obj = snapshot.val()
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
            @handlers[id]?.ref.off?()
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
            object.ref.off()
            delete @handlers[key]
            delete @models[key]
        @modelIndex = []
    manifest