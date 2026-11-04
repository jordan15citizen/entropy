import std/[strformat, strutils, rdstdin, random]
import ./[functions, questions, userdata]

proc runGame*(questions: seq[Question]) =
  var stats = GameStats(lives: 5, money: 50)

  echo "Choose a mode:"
  echo "  1. Regular (one round)"
  echo "  2. Endless (repeat until lives run out)"
  var mode = ""
  while mode notin ["1", "2"]:
    mode = readLineFromStdin("Enter 1 or 2: ").strip()
  let endlessMode = mode == "2"

  var userData = loadUserData()
  echo repeat("=", 60)
  echo "                      ENTROPY"
  echo if endlessMode: "                    ENDLESS MODE" else: "                    REGULAR MODE"
  echo repeat("=", 60)

  var questionOrder = questions
  randomize()
  shuffle(questionOrder)
  var
    index = 0
    questionNum = 0

  while stats.lives > 0 and (endlessMode or questionNum < questionOrder.len):
    if index >= questionOrder.len:
      index = 0
      shuffle(questionOrder)
      echo repeat("-", 60)
      echo "Question round complete. Shuffling for the next round."

    askQuestion(questionNum + 1, questionOrder[index], stats)
    inc questionNum
    inc index

  userData.highScore = max(userData.highScore, stats.score)
  inc userData.gamesPlayed
  saveUserData(userData)

  echo repeat("-", 60)
  echo "                      GAME SUMMARY"
  echo repeat("-", 60)
  echo fmt"  Final score: {stats.score}"
  echo fmt"  Money: ${stats.money}"
  echo fmt"  Questions answered: {questionNum}"
  echo fmt"  Total attempts: {stats.attempts}"
  echo fmt"  High score: {userData.highScore}"
  echo fmt"  Games played: {userData.gamesPlayed}"
  echo repeat("=", 60)
