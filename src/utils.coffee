@safeStringify = (obj) ->
    JSON.stringify(obj).replace(/<\/script/g, '<\\/script').replace(/<!--/g, '<\\!--')

@slugify = (string) -> 
  string = string || ""
  string = string.toLowerCase()
  string.replace(/[\s-]+/g, "-").replace(/[^\w-]*/g, "")

@getRootComponent = (component) ->
  while component._owner
      component = component._owner
  component

# Helper method for use with Firebase snapshots. We frequently wish
# to convert a Firebase hash to an array.
@snapshotToArray = (snapshot) ->
    elements = []
    snapshot.forEach (snap) ->
        element = snap.val()
        element.id = snap.name()
        elements.push element
        false
    elements