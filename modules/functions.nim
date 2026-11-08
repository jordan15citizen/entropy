import std/[strformat, strutils, rdstdin, os]
import ./questions

type
  GameStats* = object
    lives*: int
    money*: int
    score*: int
    attempts*: int
    bonusMultiplier*: int
    questionsAnswered*: int
    correctAnswers*: int
    incorrectAnswers*: int

proc difficultyReward*(difficulty: Difficulty): int =
  case difficulty
  of easy: return 1
  of medium: return 2
  of hard: return 3

proc openShop*(question: Question, stats: var GameStats): bool =
  echo repeat("-", 60)
  echo "                     SHOP"
  echo "  1. Extra life - $40"
  echo "  2. Hint - $15"
  echo "  3. Double reward - $25"
  echo "  4. Exit"
  echo repeat("-", 60)

  var choice = ""
  while choice notin ["1", "2", "3", "4"]:
    choice = readLineFromStdin("Choose an item: ").strip()

  case choice
  of "1":
    if stats.money < 40:
      echo "  You do not have enough money for an extra life."
      return true
    stats.money -= 40
    inc stats.lives
    echo "  You bought an extra life!"
    return true
  of "2":
    if stats.money < 15:
      echo "  You do not have enough money for a hint."
      return true
    stats.money -= 15
    let correctAnswerIndex = parseInt(question.correctAnswer) - 1
    var wrongAnswers: seq[string]
    for i, answer in question.answers:
      if i != correctAnswerIndex:
        wrongAnswers.add(answer)
    let hintText = if wrongAnswers.len > 1:
                     fmt"{wrongAnswers[0]} or {wrongAnswers[1]}"
                   else:
                     wrongAnswers[0]
    echo fmt"  Hint: the correct answer is not {hintText}."
    return true
  of "3":
    if stats.money < 25:
      echo "  You do not have enough money for a doubled reward."
      return true
    stats.money -= 25
    stats.bonusMultiplier = 2
    echo "  Next correct answer will earn double rewards!"
    return true
  else:
    echo "  Leaving the shop."
    return false

proc askQuestion*(questionNum: int, question: Question, difficulty: Difficulty, stats: var GameStats) =
  let correctAnswerIndex = parseInt(question.correctAnswer) - 1
  let correctAnswerText = question.answers[correctAnswerIndex]
  let baseRewardMultiplier = difficultyReward(difficulty)

  echo repeat("-", 60)
  echo fmt"Question {questionNum}: {question.text}"
  echo fmt"Difficulty: {difficultyLabel(difficulty)}"
  echo ""
  for i, answer in question.answers:
    echo fmt"  {i + 1}. {answer}"
  echo ""

  inc stats.attempts
  echo repeat("-", 60)
  echo fmt"  Lives: {stats.lives}  |  Money: ${stats.money}  |  Score: {stats.score}  |  Attempts: {stats.attempts}"

  var userGuess = ""
  while true:
    userGuess = readLineFromStdin("Please enter your answer here, or type 'shop' to open the shop: ").strip()
    if userGuess.cmpIgnoreCase("shop") == 0:
      discard openShop(question, stats)
      echo repeat("-", 60)
      echo fmt"  Lives: {stats.lives}  |  Money: ${stats.money}  |  Score: {stats.score}  |  Attempts: {stats.attempts}"
      continue
    break

  let rewardMultiplier = baseRewardMultiplier * stats.bonusMultiplier
  if userGuess == question.correctAnswer.strip() or
      userGuess.cmpIgnoreCase(correctAnswerText) == 0:
    echo ""
    echo fmt"  Correct! The answer is {correctAnswerText}."
    inc stats.questionsAnswered
    inc stats.correctAnswers
    stats.score += 5 * rewardMultiplier
    stats.money += 20 * rewardMultiplier
  else:
    echo fmt"  Not quite. The correct answer is {correctAnswerText}."
    inc stats.questionsAnswered
    inc stats.incorrectAnswers
    dec stats.lives
    stats.money -= 10 * rewardMultiplier
    if stats.lives <= 0:
      echo ""
      echo "  You have no lives left. Game over!"

  stats.bonusMultiplier = 1
  sleep(1500)
