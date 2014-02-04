# Description:
#   Deploy commands.
#
# Commands:
#   hubot apps - Display app names.
#   hubot deploy <app> - Create deployment on OpsWorks.
#   hubot deploy-status <app> (num) - Show deployment status latest num number(default is 1).
#   hubot admin <app> - Invoke admin server on the app.

OpsWorks = require("../lib/opsworks")
ssh      = require('ssh2')
_        = require('underscore')

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
    OpsWorks.use(app)
    .fail (err) ->
      msg.send "エラーですぅ #{face.failure} #{err.message}"
    .then (app) ->
      app.deploy().then (result) ->
        if result.DeploymentId
          msg.send "デプロイするよ #{face.success} https://console.aws.amazon.com/opsworks/home?#/stack/#{app.StackId}/deployments/#{result.DeploymentId}"
        else
          msg.send "デプロイできません #{face.failure}"


  robot.respond /DEPLOY[_\-]STATUS ([^ ]+)( ([0-9]+))?$/i, (msg) ->
    app = msg.match[1]
    num = msg.match[2]
    num -= 1 if num
    OpsWorks.use(app)
    .fail (err) ->
      msg.send "エラーですぅ #{face.failure} #{err.message}"
    .then (app) ->
      app.deployStatus(num).then (deploys) ->
        for deploy in deploys
          trans = {
            running:    "デプロイ中だよ #{face.normal}"
            successful: "終わったよ    #{face.success}"
            failed:     "失敗しちゃった #{face.failure}"}
          status = trans[deploy.Status]
          msg.send "#{status} https://console.aws.amazon.com/opsworks/home?#/stack/#{deploy.StackId}/deployments/#{deploy.DeploymentId}"


  robot.respond /ADMIN (.*)$/i, (msg) ->
    app = msg.match[1]
    unless process.env["HUBOT_PRIVATE_KEY"]
      msg.send "秘密鍵が設定されてない #{face.failure}"
      return
    
    OpsWorks.use(app)
    .fail (err) ->
      msg.send "エラーですぅ #{face.failure} #{err.message}"
    .then (app) ->
      app.instances().then (instances) ->
        instance = _.find instances, (instance) -> instance.Status == 'online'
        session = new ssh()
        session.on 'ready', () ->
          rails_env = if app.Name.match(/stg/) then "staging" else "production"
          cmd = """
          SERVER_PROCESS=$(ps ax | grep ruby | grep rails | grep -v bash | awk '{print $1}')
          if [ -n "$SERVER_PROCESS" ];then
            kill $SERVER_PROCESS
          fi
          cd /srv/www/#{app.Name}/current
          RAILS_ENV=#{rails_env} ALLOW_ADMIN=1 nohup bundle exec rails s
          """
          session.exec cmd, {pty: true}, (err, stream) ->
            stream.on 'data', (data, extended) ->
              result = data.toString()
#              console.log result
              if result.match(/nohup\.out/)
                console.log "nohup.out"
                stream.destroy()
            stream.on 'end', () ->
              voice = """
              $ ssh -N -L 8888:localhost:3000 deploy@#{instance.PublicIp} を起動して
              http://localhost:8888/admin にアクセスだ! （｀・ω・´）
              """
              msg.send voice
        session.on 'error', () ->
          msg.send "SSHでエラーっす #{face.failure}"

        session.connect
          host: instance.PublicIp
          port: 22
          username: 'deploy'
          privateKey: process.env["HUBOT_PRIVATE_KEY"]
