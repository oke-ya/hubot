# Description:
#   Deploy commands.
#
# Commands:
#   hubot apps - Display app names.

_   = require('underscore')
AWS = require('aws-sdk')
Q   = require('q')
ENV = process.env

AWS.config.update(accessKeyId:     ENV['AWS_ACCESS_KEY_ID'],
                  secretAccessKey: ENV['AWS_SECRET_ACCESS_KEY'])

module.exports = (robot) ->
  opsworks = new AWS.OpsWorks(region: "us-east-1");
  getStacks = () ->
    deferred = Q.defer()
    opsworks.describeStacks({}, (err, data) ->
      if (err)
        deferred.reject(err)
        return
      deferred.resolve data['Stacks']
    )
    return deferred.promise

  robot.respond /APPS/i, (msg) ->
    msg.send 'please wait ...'
    getStacks().then (stacks) ->
      msg.send (_.map stacks, (stack) -> stack["Name"]).join(", ")
  
  robot.respond /DEPLOY (.*)$/i, (msg) ->
    app = msg.match[1]
    getStacks().then (stacks) ->
      stack = _.find stacks, (stack) -> stack["Name"] == app
      id = stack["StackId"]
      unless id
        msg.send "Error not such app #{app}."
        return
      console.log id