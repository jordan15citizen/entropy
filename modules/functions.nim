import std/[strformat, strutils, rdstdin, os]
import ./questions

type
  GameStats* = object
    lives*: int
    money*: int
    score*: int
    attempts*: int

proc askQuestion*(questionNum: int, question: Question, stats: var GameStats) =
  let correctAnswerIndex = parseInt(question.correctAnswer) - 1
  let correctAnswerText = question.answers[correctAnswerIndex]

  echo repeat("-", 60)
  echo fmt"Question {questionNum}: {question.text}"
  echo ""
  for i, answer in question.answers:
    echo fmt"  {i + 1}. {answer}"
  echo ""

  inc stats.attempts
  echo repeat("-", 60)
  echo fmt"  Lives: {stats.lives}  |  Money: ${stats.money}  |  Score: {stats.score}  |  Attempts: {stats.attempts}"

  let userGuess = readLineFromStdin("Please enter your answer here: ").strip()
  if userGuess == question.correctAnswer.strip() or
      userGuess.cmpIgnoreCase(correctAnswerText) == 0:
    echo ""
    echo fmt"  Correct! The answer is {correctAnswerText}."
    stats.score += 5
    stats.money += 20
  else:
    echo fmt"  Not quite. The correct answer is {correctAnswerText}."
    dec stats.lives
    stats.money -= 10
    if stats.lives <= 0:
      echo ""
      echo "  You have no lives left. Game over!"

  sleep(1500)
