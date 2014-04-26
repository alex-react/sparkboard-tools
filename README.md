# Sparkboard Tools

Tools for building web applications using Firebase and React, with isomorphic routing/rendering and real-time data subscriptions on the client.

**Warning: Use at your own risk. API is not stable and there are no tests.**

**SubscriptionMixin** - a React mixin for subscribing to real-time data sources

**fetchSubscriptions** - a function for fetching subscriptions server-side

**firebaseSubscription** - create a subscription object out of a Firebase manifest

**Router** - Isomorphic router - a React mixin on the client, a standalone function on the server.

**mergeFirebaseRules** - write Firebase rules in multiple files (use JSON, JavaScript, or CoffeeScript) and compile them using this tool.


**utils**

- **safeStringify** - eliminates script tags from code
- **slugify** - change titles into slugs
- **getRootComponent** - small helper for React
- **snapshotToArray** - turn a Firebase snapshot into an array, swapping each object's `name` into an `id` field