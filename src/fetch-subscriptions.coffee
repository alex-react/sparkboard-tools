
###

    Fetch data (once) from multiple subscription objects and put all results into a single object.

    For example, if the subscriptions hash looks like this:

    {
        users: {...subscription object...}
        projects: {...subscription object...}
        anotherObject: {...subscription object...}
    }

    Data will be returned in an object like this:

    {
        users: [...data...]
        projects: [...data...]
        anotherObject: {...data...}
    }

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
    
    # Fetch data using subscribe().  
    # Immediately unsubscribe() after receiving the data.
    getData = (subscription, callback) ->
        subscription.subscribe (data) ->
            object = {}
            object[subscription.path] = data
            callback(null, object)
            subscription.unsubscribe()
        , {wait: true}

    # Fetch all data concurrently.
    # Put results into an object with a structure that
    # mirrors the original hash of subscription objects.
    async.map list, getData, (err, data) ->
        object = {}
        for result in data
            _.extend object, result
        fetchCallback(object)