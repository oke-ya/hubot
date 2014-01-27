# Description:
#   Deploy commands.
#
# Commands:
#   hubot apps - Display app names.
OpsWorks = require("../lib/opsworks")

module.exports = (robot) ->
  face = {
    normal:  '(´-ω-)'
    success: '(*´▽｀*)'
    failure: '(PД`q｡)'
  }

  robot.respond /APPS/i, (msg) ->
    OpsWorks.getApps().then (apps) -> msg.send apps.join(" ")
  
  robot.respond /DEPLOY (.*)$/i, (msg) ->
    app = msg.match[1]
    OpsWorks.use(app).then (app) ->
      app.deploy().then (result) ->
        if result.DeploymentId
          msg.send "デプロイするよ #{face.success} id: #{result.DeploymentId}"
        else
          msg.send "デプロイできません #{face.failure}"


  robot.respond /DEPLOY[_\-]STATUS ([^ ]+)( ([0-9]+))?$/i, (msg) ->
    app = msg.match[1]
    num = msg.match[2]
    if num
      num -= 1

    OpsWorks.use(app).then (app) ->
      app.deployStatus(num).then (deploys) ->
        for deploy in deploys
          trans = {
            running:    "デプロイ中だよ #{face.normal}"
            successful: "終わったよ    #{face.success}"
            failed:     "失敗しちゃった #{face.failure}"}
          status = trans[deploy.Status]
          msg.send "#{status} id: #{deploy.DeploymentId}"
