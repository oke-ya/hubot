_   = require('underscore')
AWS = require('aws-sdk')
Q   = require('q')
ENV = process.env

AWS.config.update(accessKeyId:     ENV['AWS_ACCESS_KEY_ID'],
                  secretAccessKey: ENV['AWS_SECRET_ACCESS_KEY'])
api = new AWS.OpsWorks(region: "us-east-1");

class OpsWorks
  @getStacks = () ->
    deferred = Q.defer()
    if OpsWorks.stacks
      deferred.resolve OpsWorks.stacks
    else
      api.describeStacks({}, (err, data) ->
        if (err)
          deferred.reject(err)
          return
        OpsWorks.stacks = data['Stacks']
        deferred.resolve OpsWorks.stacks
      )
    deferred.promise

  @getApps = () ->
    deferred = Q.defer()
    OpsWorks.getStacks().then (stacks) ->
      deferred.resolve (_.map stacks, (stack) -> stack["Name"])
    return deferred.promise

  @use = (name) ->
    deferred = Q.defer()
    OpsWorks.getStacks().then (stacks) ->
      params = (_.find stacks, (stack) -> stack["Name"] == name)
      deferred.resolve new OpsWorks(params)
    return deferred.promise

  
  constructor: (params) ->
    self = @
    for k, v of params
      self[k] = v
    
module.exports = OpsWorks
