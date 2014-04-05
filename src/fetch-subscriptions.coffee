
###

    Asynchronously fetch data from multiple subscription objects.

###

_ = require("underscore")
async = require("async")

module.exports = (subscriptions, fetchCallback) ->

    # Make a list out of the subscription hash.
    # This is to prepare for async fetching.
    list = _.chain(subscriptions)
            .pairs()
            .map((pair)->
                if !pair[1].server
                    return false
                _.extend pair[1], path: pair[0])
            .value().filter(Boolean)
    
    # Function to fetch data using subscribe().  
    # Remember to unsubscribe() after receiving the first data.
    getData = (subscription, callback) ->
        subscription.subscribe (data) ->
            object = {}
            object[subscription.path] = data
            callback(null, object)
            subscription.unsubscribe()

    # Fetch asynchronously & put data into an object that matches 
    # the structure of the original hash.
    async.map list, getData, (err, data) ->
        object = {}
        for result in data
            _.extend object, result
        fetchCallback(object)