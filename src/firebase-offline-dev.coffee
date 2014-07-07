fs = require("fs")

@saveFirebaseToFile = (ref, savePath) ->
  ref.on "value", (snap) ->
    fs.writeFileSync snap.val().toJSON(), savePath
    
@goOfflineWithData = (ref, loadPath) ->
  ref.goOffline()
  dataFile = fs.readFileSync(loadPath)
  ref.set(JSON.parse(dataFile))