import std/[strformat, strutils, rdstdin, random, options]
import ./[functions, questions, userdata]

type
  GameMode* = enum
    interactiveMode
    regularMode
    endlessMode
    suddenDeathMode

proc parseGameMode*(value: string): GameMode =
  case value.toLowerAscii()
  of "regular": return regularMode
  of "endless": return endlessMode
  of "sudden-death", "sudden_death", "sudden death": return suddenDeathMode
  else: raise newException(ValueError, "Unknown game mode: " & value)

proc parseDifficulty*(value: string): Difficulty =
  case value.toLowerAscii()
  of "easy": return easy
  of "medium": return medium
  of "hard": return hard
  else: raise newException(ValueError, "Unknown difficulty: " & value)

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

proc runGame*(questions: seq[Question], selectedMode = interactiveMode,
              selectedDifficulty = none(Difficulty)) =
  let difficulty = if selectedDifficulty.isSome: selectedDifficulty.get else: chooseDifficulty()
  let startingStats = difficultyStartingStats(difficulty)
  var stats = GameStats(lives: startingStats.lives, money: startingStats.money)

  var gameMode = selectedMode
  if gameMode == interactiveMode:
    echo "Choose a mode:"
    echo "  1. Regular (one round)"
    echo "  2. Endless (repeat until lives run out)"
    echo "  3. Sudden Death (one life lost = death)"
    var mode = ""
    while mode notin ["1", "2", "3"]:
      mode = readLineFromStdin("Enter 1, 2, or 3: ").strip()
    case mode
    of "1": gameMode = regularMode
    of "2": gameMode = endlessMode
    else: gameMode = suddenDeathMode

  var userData = loadUserData()
  var questionOrder = filterQuestionsByDifficulty(questions, difficulty)
  if questionOrder.len == 0:
    questionOrder = questions

  randomize()
  shuffle(questionOrder)
  echo repeat("=", 60)
  echo "                      ENTROPY"
  echo fmt"                 {difficultyLabel(difficulty).toUpperAscii()} DIFFICULTY"
  case gameMode
  of regularMode: echo "                    REGULAR MODE"
  of endlessMode: echo "                    ENDLESS MODE"
  of suddenDeathMode: echo "                 SUDDEN DEATH MODE"
  of interactiveMode: discard
  echo repeat("=", 60)

  var
    index = 0
    questionNum = 0

  while stats.lives > 0 and (gameMode == endlessMode or questionNum < questionOrder.len):
    if index >= questionOrder.len:
      index = 0
      shuffle(questionOrder)
      echo repeat("-", 60)
      echo "Question round complete. Shuffling for the next round."

    askQuestion(questionNum + 1, questionOrder[index], difficulty, stats,
                gameMode == suddenDeathMode)
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
