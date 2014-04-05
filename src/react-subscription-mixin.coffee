
###

    Subscription mixin for React.

    Expects a 'manifest' of subscriptions in `statics.subscriptions`
    with `subscribe`, `unsubscribe`, and `default` methods.

    Example:
    
    React.createClass
        mixins: [SubscriptionMixin]
        statics: ->
            subscriptions: (props) ->
                users:
                    subscribe: -> 
                        # initiate subscription
                    unsubscribe: ->
                        # clean up
                    shouldUpdateSubscription: (oldProps, newProps) ->
                        # Return true if subscription should update
                        # when props change
                    default: -> 
                        # default value for the prop
###



{getRootComponent} = require("./utils")


setSubscriptionPropsCallback = (owner, path) ->
    (data) ->
        props = {}
        props[path] = data
        owner.setProps(props)

module.exports =
    
    subscribe: (props) ->
        owner = getRootComponent(this)
        @__subscriptions = {}
        for path, subscription of @type.subscriptions?(props)

            do (path, subscription) =>
                subscription.subscribe setSubscriptionPropsCallback(owner, path)
                @__subscriptions[path] = subscription
    
    unsubscribe: ->
        for path, subscription of @__subscriptions
            subscription.unsubscribe()
            delete @__subscriptions[path]

    componentDidMount: ->
        @subscribe(this.props)

    componentWillUnmount: ->
        @unsubscribe()
    
    componentWillReceiveProps: (newProps) ->
        owner = getRootComponent(this)
        newSubscriptions = @type.subscriptions(newProps)
        for path, subscription of @__subscriptions
            if subscription.shouldUpdateSubscription?(this.props, newProps)
                subscription.unsubscribe()
                subscription = @__subscriptions[path] = newSubscriptions[path]
                subscription.subscribe setSubscriptionPropsCallback(owner, path)

    getDefaultProps: ->
        props = {}
        for path, subscription of this.type.subscriptions?(this.props)
            props[path] = props[path] || subscription.default 
        props