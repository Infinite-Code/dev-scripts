# Description:
#   Some github related scripts for Slack

settings = require './settings.coffee'

module.exports = (robot) ->

    robot.hear /https:\/\/github.com\/([^/]*)\/([^/]*)\/([^/]*)\/([0-9]*)/i, (res) ->
        org = res.match[1]
        repo = res.match[2]
        type = res.match[3]
        if type == 'tree'
            # not supported, skip it
            return
        if type == 'pull'
            type = 'pulls'
        issueNumber = res.match[4]
        apiUrl = "https://api.github.com/repos/#{org}/#{repo}/#{type}/#{issueNumber}"
        robot.http(apiUrl)
            .header('Authorization', 'Basic ' + settings.GITHUB_BASIC_TOKEN)
            .get() (error, response, body) ->
                data = JSON.parse body
                typeDisplay = type.charAt(0).toUpperCase() + type.slice(1, type.length-1)
                res.send "Github #{typeDisplay} #{issueNumber}: #{data.title} (#{data.user.login})"
