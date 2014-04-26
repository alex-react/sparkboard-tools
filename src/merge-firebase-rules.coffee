###

  **Problem:** Firebase expects a single JSON file to specify security rules for an app. But a large app will have many rules, and I'd rather separate these rules into different files.

  **Solution:** This module iterates over a directory of JSON/JS/CoffeeScript files, creates a nested hash of all the rules (maintaining the structure of the files/directories), and outputs all rules into a single JSON file.

###



requireDirectory = require('require-directory')
argv = require("optimist").argv
_ = require("underscore")
fs = require("fs")
traverse = require("traverse")
path = require("path")

readPath = argv._[0]
writePath = argv._[1]

renameParent = (traversal, context, object, from, to) ->
  if context.key == from
    basePath = context.parent.path
    newPath = basePath.concat([to])
    traversal.set newPath, object
    context.remove()

module.exports = (readPath, writePath) ->
  console.log "Begin to merge Firebase rules:"
  if !readPath
    console.log "...No path provided. Quitting."
    return false
  else
    console.log "...Reading from: #{readPath}"

  rulesFromFiles = requireDirectory module, readPath, /_[^\/]*$/


  traversal = traverse(rulesFromFiles)

  traversal.forEach (object) ->
    renameParent traversal, this, object, "validate", ".validate"
    renameParent traversal, this, object, "read", ".read"
    renameParent traversal, this, object, "write", ".write"

  traversal.forEach (object) ->
    if this.key in ['index', 'root']
      basePath = this.parent.path
      for key, value of object
        newPath = basePath.concat([key])
        traversal.set newPath, value
      this.remove()

  rules = JSON.stringify rulesFromFiles, null, 4

  fs.writeFileSync writePath, rules
  console.log "...Compiled rules: #{writePath}"
  
  # Clear require.cache so that we can reload this function
  readPath = path.resolve readPath
  for key in _(require.cache).keys()
    if key.match ///^#{readPath}///
      delete require.cache[key]
  # delete require.cache[require.resolve('./b.js')]
  rules