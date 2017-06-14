# Description:
#   Some github related scripts for Slack

settings = require './settings.coffee'

module.exports = (robot) ->

   robot.hear /https:\/\/github.com\/([^/]*)\/([^/]*)\/issues\/([0-9].*)/i, (res) ->
     org = res.match[1]
     repo = res.match[2]
     issueNumber = res.match[3]
     apiUrl = "https://api.github.com/repos/#{org}/#{repo}/issues/#{issueNumber}"
     robot.http(apiUrl)
        .header('Authorization', 'Basic ' + settings.GITHUB_BASIC_TOKEN)
        .get() (error, response, body) ->
            data = JSON.parse body
            res.send "Github Issue #{issueNumber}: #{data.title}"
