# Description:
#   Deploy commands.
#
# Commands:
#   hubot apps - Display app names.
OpsWorks = require("../lib/opsworks")

module.exports = (robot) ->
  robot.respond /APPS/i, (msg) ->
    OpsWorks.getApps().then (apps) -> msg.send apps.join(" ")
  
  robot.respond /DEPLOY (.*)$/i, (msg) ->
    app = msg.match[1]
    OpsWorks.use(app).then (app) ->
      app.createDeploy()
    
