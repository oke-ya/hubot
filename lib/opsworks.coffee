fs   = require('fs')
path = require('path')

_   = require('underscore')
AWS = require('aws-sdk')
Q   = require('q')
ENV = process.env

fs.exists path.resolve(__dirname, '../.env'), (b) ->
  require('dotenv').load() if b
  ENV = process.env

AWS.config.update(accessKeyId:     ENV['AWS_ACCESS_KEY_ID'],
                  secretAccessKey: ENV['AWS_SECRET_ACCESS_KEY'])

class OpsWorks
  @api = new AWS.OpsWorks(region: "us-east-1");
  
  @getStacks = () ->
    deferred = Q.defer()
    if OpsWorks.stacks
      deferred.resolve OpsWorks.stacks
    else
      OpsWorks.api.describeStacks({}, (err, data) ->
        if (err)
          deferred.reject(err)
        else
          OpsWorks.stacks = data['Stacks']
          deferred.resolve OpsWorks.stacks
      )
    deferred.promise

  @getApps = () ->
    deferred = Q.defer()
    OpsWorks.getStacks()
    .then (stacks) ->
      deferred.resolve (_.map stacks, (stack) -> stack["Name"])
    .fail (err) ->
      deferred.reject err
    return deferred.promise

  @use = (name) ->
    deferred = Q.defer()
    OpsWorks.getStacks()
    .then (stacks) ->
      params = (_.find stacks, (stack) -> stack["Name"] == name)
      OpsWorks.api.describeApps {StackId: params.StackId}, (err, data) ->
        deferred.resolve new OpsWorks(params, data["Apps"][0])
    .fail (err) ->
      deferred.reject err

    return deferred.promise

  constructor: (stack, app) ->
    self = @
    for k, v of stack
      self[k] = v
    for k, v of app
      self[k] = v

  deploy: () ->
    deferred = Q.defer()
    unless @stackName
      deferred.reject(new Error("stackID is missing"))
      return
    params = {AppId: @AppId, StackId: @StackId, Command: {Name: 'deploy'}}
    OpsWorks.api.createDeployment params, (err, data) ->
      if err
        deferred.reject err
      else
        deferred.resolve data
    deferred.promise

  deployStatus: (num) ->
    num ?= 0
    deferred = Q.defer()
    OpsWorks.api.describeDeployments {AppId: @AppId}, (err, data) ->
      if err
        deferred.reject err
      else
        deferred.resolve data["Deployments"][0..num]
    deferred.promise

  instances: () ->
    deferred = Q.defer()
    OpsWorks.api.describeInstances {StackId: @StackId}, (err, data) ->
      if err
        deferred.reject err
      else
        deferred.resolve data["Instances"]
      
    deferred.promise

  detachELB: () ->
    [name, env] = @Name.split("-")
    elbName = if env == "stg" then "#{name}-staging-http"  else "#{name}-production-http"
    elbAPI = new AWS.ELB(region: ENV["AWS_REGION"])
    elbAPI.describeLoadBalancers (err, response) ->
      elb = _.find response["LoadBalancerDescriptions"], (elb) -> elb["LoadBalancerName"] == elbName
      arg = {LoadBalancerName: elbName, Instances: elb["Instances"]}
      elbAPI.deregisterInstancesFromLoadBalancer arg, (err, respose) ->
        if err
          deferred.reject err
        else
          deferred.resolve(response)
    deferred = Q.defer()
    deferred.promise
    
  attachELB: () ->
    [name, env] = @Name.split("-")
    elbName = if env == "stg" then "#{name}-staging-http"  else "#{name}-production-http"
    deferred = Q.defer()
    elbAPI = new AWS.ELB(region: ENV["AWS_REGION"])
    console.log ENV["AWS_REGION"]
    OpsWorks.api.describeInstances {StackId: @StackId}, (err, response) ->
      instances = _.map response["Instances"], (i) -> {InstanceId: i["Ec2InstanceId"]}
      elbAPI.registerInstancesWithLoadBalancer {"LoadBalancerName": elbName, Instances: instances}, (err, response) ->
        if err
          deferred.reject err
        else
          deferred.resolve(response)        
    deferred.promise    

module.exports = OpsWorks
