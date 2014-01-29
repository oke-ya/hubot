# Description:
#   A way to interact with the Google Chart API.
#
# Commands:
#   hubot qrcode <url> - Create QR code usinng Google chart API for <url>.

module.exports = (robot) ->
  robot.respond /(qrcode) (.*)/i, (msg) ->
    url = encodeURIComponent(msg.match[2])
    q = "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=#{url}"
    msg.send q
