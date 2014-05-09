###

  Firebase Index Server
  ===

  A small node.js server that will maintain indexes on Firebase paths
  using a queue pattern.
  
  Based on this discussion:
  https://groups.google.com/forum/#!topic/firebase-talk/ZSkIBC9FhOQ

###

# Eventually we can dynamically create indexes, possibly
# using a web UI. For now, I just want to create a single
# index for a hard-coded path.

WorkQueue = require("../vendor/firebase-work-queue")


# connect to Firebase
FIREBASE_URL = process.env.FIREBASE_URL || "firebase-index-server.firebaseio.com"
rootRef = new Firebase(FIREBASE_URL)

module.exports = (index) ->

  # a hard-coded index
  index =
    type: "tagIndex"
    sourcePath: "/posts/"
    sourceAttribute: "tags"
    indexPath: "/tags/"

  # Examples:
  # 
  # SOURCE:
  # /post/id123 =>
  #   title: "End of the world"
  #   tags:
  #     announcement: true
  #     pessimistic: true
  # 
  # INDEXES:
  # /tags =>
  #   pessimistic:
  #     id123: true
  #   announcement:
  #     id123: true

  # construct queue path
  queueRef = rootRef.child("/queue"+index.sourcePath)

  # respond to data in queue path
  handleQueue = (path) ->
    (snapshot, callback) ->
      # get the existing data at the source path
      rootRef.child(index.sourcePath+"/"+snapshot.name()).once "value", (snap) ->
        oldData = snap.val()
        newData = 

  # create listener on queue path

  rootRef.child(path).on "child_added", handleQueue(path)


###

Details to handle later:

- set a ".priority" attribute to setPriority of element
- decide whether to 'set' or 'update' the object
- store indexes in Firebase itself (use a GUI to manage indexes)
  // or have another, better way to manage indexes in code

###


