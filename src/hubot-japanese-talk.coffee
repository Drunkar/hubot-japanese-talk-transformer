## Description:
##   general reply to questions.
##
## Commands:
##   hubot --?


if typeof process.env.HUBOT_JP_TALK_API_SERVER == "undefined"
    TALK_API_SERVER = "http://localhost:5000"
else
    TALK_API_SERVER = process.env.HUBOT_JP_TALK_API_SERVER
ERROR_MESSAGE = "エラーっぽい"


module.exports = (robot) ->

    robot.respond /(.*)/i, (msg) ->
        #
        # メンションすると返答
        #

        console.log "fetching..." + TALK_API_SERVER
        keyword = msg.match[1] + "？"
        console.log(keyword)
        request = msg.http(TALK_API_SERVER)
                          .query(input: keyword)
                          .get()
        request (err, res, body) ->
            if err
                message = ERROR_MESSAGE
            else
                console.log("done.")
                json = JSON.parse body
                console.log(json)
                if json["outputs"]
                    index = weightedRandomChoice(json.outputs[0].score)
                    message = json.outputs[0].val[index]
                else
                    message = ERROR_MESSAGE
            msg.send message



    robot.hear /(.*)/i, (msg) ->
        #
        # @のついていない普通の会話に対して、10%の確率で返答する。
        #

        respond = Math.floor(Math.random() * 10) + 1
        if respond == 10
            keyword = msg.match[1]
            if keyword.indexOf("@") == -1
                console.log "fetching..." + TALK_API_SERVER
                console.log(keyword)
                request = msg.http(TALK_API_SERVER)
                                  .query(input: keyword)
                                  .get()
                request (err, res, body) ->
                    if err
                        message = ERROR_MESSAGE
                    else
                        console.log("done.")
                        json = JSON.parse body
                        if json["outputs"]
                            index = weightedRandomChoice(json.outputs[0].score)
                            message = json.outputs[0].val[index]
                        else
                            message = ERROR_MESSAGE

                    msg.send message


weightedRandomChoice = (weights) ->
    # input example: [0.8, 0.4, 0.9, 0.2]
    min = Math.min.apply(null, weights)
    sumOfWeights = 0
    for weight in weights
        sumOfWeights += weight - min
    randomWeight = Math.random() * sumOfWeights
    for i in [0..weights.length]
        randomWeight = randomWeight - (weights[i] - min)
        if randomWeight <= 0
            return i
