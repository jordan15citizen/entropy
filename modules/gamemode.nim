import std/[strformat, strutils, rdstdin, random]
import ./[functions, questions, userdata]

proc chooseDifficulty*(): Difficulty =
  echo "Choose a difficulty:"
  echo "  1. Easy   (7 lives, simpler questions)"
  echo "  2. Medium (5 lives, balanced challenge)"
  echo "  3. Hard   (4 lives, tougher questions)"

  var input = ""
  while input notin ["1", "2", "3"]:
    input = readLineFromStdin("Enter 1, 2, or 3: ").strip()

  case input
  of "1": return easy
  of "2": return medium
  else: return hard

proc difficultyStartingStats*(difficulty: Difficulty): tuple[lives: int, money: int] =
  case difficulty
  of easy: return (7, 80)
  of medium: return (5, 50)
  of hard: return (4, 40)

proc runGame*(questions: seq[Question]) =
  let difficulty = chooseDifficulty()
  let startingStats = difficultyStartingStats(difficulty)
  var stats = GameStats(lives: startingStats.lives, money: startingStats.money)

  echo "Choose a mode:"
  echo "  1. Regular (one round)"
  echo "  2. Endless (repeat until lives run out)"
  var mode = ""
  while mode notin ["1", "2"]:
    mode = readLineFromStdin("Enter 1 or 2: ").strip()
  let endlessMode = mode == "2"

  var userData = loadUserData()
  var questionOrder = filterQuestionsByDifficulty(questions, difficulty)
  if questionOrder.len == 0:
    questionOrder = questions

  randomize()
  shuffle(questionOrder)
  echo repeat("=", 60)
  echo "                      ENTROPY"
  echo fmt"                 {difficultyLabel(difficulty).toUpperAscii()} DIFFICULTY"
  echo if endlessMode: "                    ENDLESS MODE" else: "                    REGULAR MODE"
  echo repeat("=", 60)

  var
    index = 0
    questionNum = 0

  while stats.lives > 0 and (endlessMode or questionNum < questionOrder.len):
    if index >= questionOrder.len:
      index = 0
      shuffle(questionOrder)
      echo repeat("-", 60)
      echo "Question round complete. Shuffling for the next round."

    askQuestion(questionNum + 1, questionOrder[index], difficulty, stats)
    inc questionNum
    inc index

  userData.highScore = max(userData.highScore, stats.score)
  inc userData.gamesPlayed
  userData.questionsAnswered += stats.questionsAnswered
  userData.correctAnswers += stats.correctAnswers
  userData.incorrectAnswers += stats.incorrectAnswers
  saveUserData(userData)

  echo repeat("-", 60)
  echo "                      GAME SUMMARY"
  echo repeat("-", 60)
  echo fmt"  Final score: {stats.score}"
  echo fmt"  Money: ${stats.money}"
  echo fmt"  Difficulty: {difficultyLabel(difficulty)}"
  echo fmt"  Questions answered: {stats.questionsAnswered}"
  echo fmt"  Correct answers: {stats.correctAnswers}"
  echo fmt"  Incorrect answers: {stats.incorrectAnswers}"
  echo fmt"  Total attempts: {stats.attempts}"
  echo fmt"  High score: {userData.highScore}"
  echo fmt"  Games played: {userData.gamesPlayed}"
  echo fmt"  All-time questions answered: {userData.questionsAnswered}"
  echo fmt"  All-time correct answers: {userData.correctAnswers}"
  echo fmt"  All-time incorrect answers: {userData.incorrectAnswers}"
  echo repeat("=", 60)
