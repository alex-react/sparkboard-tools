###

    Router for React.

    Use @Mixin on the client and @create on the server.

    On the client, @Mixin goes into the root component and sets
    route matches into props.matchedRoute.

    Expects a path list:

        routes =  [
            { path: "/",                 handler: Home },
            { path: "/writing",          handler: Writing },
            { path: "/writing/:slug",    handler: WritingView },
            { path: "*",                 handler: NotFound }
        ]

    When matchRoute(path) is called, a matchedRoute object
    is set into this.props:

        matchedRoute:
            path: "/writing/my-post"
            params:
                slug: "my-post"
            handler: WritingView

###

_ = require("underscore")
urlPattern = require('url-pattern')

closest = (el, tag) ->
    tag = tag.toUpperCase()
    if el.nodeName == tag
        return el
    while el = el.parentNode
        if el.nodeName == tag
            return el
    null



RouterMixin = @Mixin =
    
    # Before component mounts, match route.
    # Route is passed via props on the server & window.location.pathname on client.
    componentWillMount: ->
        this.props.matchedRoute = this.matchRoute(this.props.path || window.location.pathname)

    # Catch all clicks and don't reload the page for URLs that begin with "/"
    handleClick: (e) ->
        if link = closest(e.target, 'A') 
            if link.getAttribute("href")?[0] == "/"
                e.preventDefault()
                e.stopPropagation()
                this.navigate(link.pathname)

    handlePopstate: ->
        path = window.location.pathname
        if this.props.matchedRoute.path != path
            this.setProps matchedRoute: this.matchRoute(path)

    componentDidMount: ->
        window.addEventListener 'popstate', this.handlePopstate

    matchRoute: (path) ->
        path += "/" if path[path.length-1] != "/"
        for route in (this.routes || [])
            route.path += "/" if route.path[route.path.length-1] != "/"
            pattern = urlPattern.newPattern route.path
            params = pattern.match(path)
            if params
                matchedRoute = 
                    path: path
                    params: params
                    handler: route.handler
                return matchedRoute

    navigate: (path, callback) ->
        window.history.pushState(null, null, path)
        this.setProps({ matchedRoute: this.matchRoute(path) }, callback)

@create = (routes) ->
    Router = _.clone RouterMixin

    _.extend Router,
        routes: routes
        add: (route) ->
            this.routes.push route
    Router
