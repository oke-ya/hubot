# FIXME webmock

assert   = require("assert")
OpsWorks = require('../lib/opsworks')

describe "OpsWorks", ->
  @timeout(10000)
  # describe "use", ->
  #   it "should initialize with api result", (done) ->
  #     OpsWorks.use("zeroshiki-stg")
  #       .then (app) ->
  #         assert.equal "5ccee25a-3834-4fe9-8753-b61fb9868973", app.StackId
  #         done()

  # describe "#deploy", ->
  #   it "should create deployment", (done) ->
  #     OpsWorks.use("zeroshiki-stg")
  #       .then (app) ->
  #         app.deploy()
  #         done()

  # describe "#deployStagus", ->
  #   it "should describe status", (done) ->
  #     OpsWorks.use("zeroshiki-stg")
  #       .then (app) ->
  #         app.deployStatus().then (deploys) ->
  #           assert.equal 'successful', deploys[0].Status
  #           done()

  # describe "#instances", ->
  #   it "should describe status", (done) ->
  #     OpsWorks.use("zeroshiki-stg")
  #       .then (app) ->
  #         app.instances().then (instances) ->
  #           console.log instances
  #           assert.equal 1, instances.length
  #           done()

  # describe "#detachELB", ->
  #   it "should deatch ELB", (done) ->
  #     OpsWorks.use("witch-stg")
  #       .then (app) ->
  #         app.detachELB().then (response) ->
  #           console.log response

  # describe "#attachELB", ->
  #   it "should attach ELB", (done) ->
  #     OpsWorks.use("witch-stg")
  #       .then (app) ->
  #         app.attachELB().then (response) ->
  #           console.log response