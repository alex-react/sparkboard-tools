_ = require("underscore")

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
        if !_.isObject(element) or _.isArray(element)
          element =
            val: element
        element.id = snap.name()
        element.priority = snap.getPriority()
        elements.push element
        false
    elements

@closestData = (el, dataAttr) ->
  if el.dataset and el.dataset.hasOwnProperty(dataAttr)
      return el
  while el = el.parentNode
      if el.dataset and el.dataset.hasOwnProperty(dataAttr)
          return el
  null
@closestClass = (el, className) ->
    if el.className and el.className.indexOf(className) > -1
        return el
    while el = el.parentNode
        if el.className and el.className.indexOf(className) > -1
            return el
    null
@closestTag = (el, tag) ->
    tag = tag.toUpperCase()
    if el.nodeName == tag
        return el
    while el = el.parentNode
        if el.nodeName == tag
            return el
    null