# Description:
#   Deploy commands.
#
# Commands:
  #   hubot >< - You look so sad. Cheer up.

module.exports = (robot) ->

  robot.respond /></i, (msg) ->
    msg.send "なでなでヽ(・ω・｀)"

  robot.respond /\^\^/i, (msg) ->
    msg.send "∩( ・ω・)∩ばんじゃーい"

  robot.respond /\-\-/i, (msg) ->
    msg.send "(。-`ω-)ンー"

