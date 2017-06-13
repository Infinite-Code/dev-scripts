# Description:
#   Some github related scripts for Slack

settings = require './settings.coffee'

module.exports = (robot) ->

   robot.hear /https:\/\/github.com\/Infinite-Code\/moby-finance\/issues\/([0-9].*)/i, (res) ->
     issueNumber = res.match[1]
     robot.http('https://api.github.com/repos/Infinite-Code/moby-finance/issues/' + issueNumber)
        .header('Authorization', 'Basic ' + settings.GITHUB_BASIC_TOKEN)
        .get() (error, response, body) ->
            data = JSON.parse body
            res.send "Github Issue #{issueNumber}: #{data.title}"
