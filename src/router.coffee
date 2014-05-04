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

{closestTag} = require("./utils")



RouterMixin = @Mixin =
    
    # Before component mounts, match route.
    # Route is passed via props on the server & window.location.pathname on client.
    # componentWillMount: ->
    #     path = this.props.path || window.location.pathname
    #     @matchRoute path, (matchedRoute) =>
    #         this.props.matchedRoute = matchedRoute

    # Catch all clicks and don't reload the page for URLs that begin with "/"
    handleClick: (e) ->
        if link = closestTag(e.target, 'A') 
            if link.getAttribute("href")?[0] == "/"
                e.preventDefault()
                e.stopPropagation()
                this.navigate(link.pathname)
    handlePopstate: ->
        path = window.location.pathname
        if this.props.matchedRoute.path != path
            @matchRoute path, (matchedRoute) =>
                this.setProps matchedRoute: matchedRoute

    componentDidMount: ->
        window.addEventListener 'popstate', this.handlePopstate
        window.Router = this

    matchStaticRoute: (path) ->
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
        return matchedRoute || null

    matchRoute: (path, callback, options={}) ->
        path += "/" if path[path.length-1] != "/"
        matchedRoute = @matchStaticRoute(path)
        if matchedRoute
            callback(matchedRoute)
        else
            @fallbackRoute path, (matchedRoute) ->
                callback(matchedRoute)

    navigate: (path, callback) ->
        
        @matchRoute path, (matchedRoute) =>
            window.history.pushState(null, null, path)
            this.setProps({ matchedRoute: matchedRoute }, callback)

@create = (routes) ->
    Router = _.clone RouterMixin

    _.extend Router,
        routes: routes
        add: (route) ->
            this.routes.push route
        addFallback: (fallback) ->
            this.fallbackRoute = fallback
    Router
