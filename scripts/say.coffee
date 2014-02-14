# Description:
#   Deploy commands.
#
# Commands:
  #   hubot >< - You look so sad. Cheer up.

module.exports = (robot) ->

  robot.respond /.*></i, (msg) ->
    msg.send "なでなでヽ(・ω・｀)"

  robot.respond /.*\^\^/i, (msg) ->
    msg.send "∩( ・ω・)∩ばんじゃーい"

  robot.respond /.*\-\-/i, (msg) ->
    msg.send "(。-`ω-)ンー"

  robot.respond /.*いってきます/i, (msg) ->
    msg.send "いってらっしゃい(｀・ω・)ノシ"

  robot.respond /oo/i, (msg) ->
    msg.send "ヾ(*゜ο゜)ノオォォォォーーー！！すごい!!"

  robot.respond /おつかれ[-ー]/i, (msg) ->
    msg.send "ﾄﾞﾓﾄﾞﾓ (・ω・｀=)ゞ"

