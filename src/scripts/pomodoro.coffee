# Description:
#   Hubot's pomodoro timer
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot start pomodoro - start a new pomodoro
#   hubot start pomodoro <time> - start a new pomodoro with a duration of <time> minutes
#   hubot stop pomodoro - stop a pomodoro
#   hubot pomodoro? - shows the details of the current pomodoro
#   hubot total pomodoros - shows the number of the total completed pomodoros
#
# Author:
#   mcollina

pomodoros = {}
defaultLength = 25

module.exports = (robot) ->

  robot.brain.data.pomodoros ||= 0

  check = ->
    for name, session of pomodoros
      console.log(name)
      if new Date().getTime() - session.time.getTime() > 1000 * defaultLength * 2 && !session.started
        session.msg.reply "Dude, you should do a pomodoro soon!"

  setInterval check, 1000 * 60 * 5

  robot.respond /start (p|pom|pomodoro)/i, (msg) ->
    console.log pomodoros, msg.envelope.user.name
    currentPomodoro = pomodoros[msg.envelope.user.name]

    if currentPomodoro?.started
      msg.reply "Pomodoro already started!"
      return

    currentPomodoro = {}
    
    currentPomodoro.func = ->
      msg.reply "Pomodoro completed!"
      currentPomodoro.started = false

    currentPomodoro.time = new Date()
    currentPomodoro.length = defaultLength
    currentPomodoro.started = true
    currentPomodoro.msg = msg

    msg.reply "Pomodoro started!"

    currentPomodoro.timer = setTimeout(currentPomodoro.func, currentPomodoro.length * 60 * 1000)
    pomodoros[msg.envelope.user.name] = currentPomodoro

  robot.respond /(p|pom|pomodoro)\?/i, (msg) ->
    currentPomodoro = pomodoros[msg.envelope.user.name]

    unless currentPomodoro?.started
      msg.reply "You have not started a pomodoro"
      return

    minutes = currentPomodoro.time.getTime() + currentPomodoro.length * 60 * 1000
    minutes -= new Date().getTime()

    minutes = Math.round(minutes / 1000 / 60)

    msg.reply "There are still #{minutes} minutes in your pomodoro"

  robot.respond /stop (p|pom|pomodoro)/i, (msg) ->
    currentPomodoro = pomodoros[msg.envelope.user.name]

    unless currentPomodoro?.started
      msg.reply "You have not started a pomodoro"
      return

    clearTimeout(currentPomodoro.timer)

    currentPomodoro.started = false
    msg.reply "Pomodoro stopped!"
