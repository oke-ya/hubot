# FIXME webmock
assert   = require("assert")
OpsWorks = require('../lib/opsworks')

describe "OpsWorks", ->
  @timeout(10000)
  describe "use", ->
    it "should initialize with api result", (done) ->
      OpsWorks.use("zeroshiki-stg")
        .then (app) ->
          assert.equal "5ccee25a-3834-4fe9-8753-b61fb9868973", app.StackId
          done()

  # describe "#deploy", ->
  #   it "should create deployment", (done) ->
  #     OpsWorks.use("zeroshiki-stg")
  #       .then (app) ->
  #         app.deploy()
  #         done()
