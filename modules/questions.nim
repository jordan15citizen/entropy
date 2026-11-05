import std/[json, os, strutils]

type
  Difficulty* = enum
    easy = "easy"
    medium = "medium"
    hard = "hard"

  Question* = object
    text*: string
    answers*: seq[string]
    correctAnswer*: string
    difficulty*: Difficulty

proc difficultyFromString*(value: string): Difficulty =
  case toLowerAscii(value)
  of "easy": return easy
  of "hard": return hard
  else: return medium

proc difficultyLabel*(difficulty: Difficulty): string =
  case difficulty
  of easy: return "Easy"
  of medium: return "Medium"
  of hard: return "Hard"

proc filterQuestionsByDifficulty*(questions: seq[Question], difficulty: Difficulty): seq[Question] =
  case difficulty
  of easy:
    for question in questions:
      if question.difficulty == easy:
        result.add(question)
  of medium:
    for question in questions:
      if question.difficulty in [easy, medium]:
        result.add(question)
  of hard:
    for question in questions:
      if question.difficulty in [medium, hard]:
        result.add(question)

proc loadQuestions*(): seq[Question] =
  let questionsPath = currentSourcePath().parentDir / "json" / "questions.json"
  let questionData = parseFile(questionsPath)

  for item in questionData["questions"].getElems():
    let difficultyValue = if item.hasKey("difficulty"): item["difficulty"].getStr() else: "medium"
    var question = Question(
      text: item["question"].getStr(),
      correctAnswer: item["correctAnswer"].getStr(),
      difficulty: difficultyFromString(difficultyValue)
    )
    for answer in item["answers"].getElems():
      question.answers.add(answer.getStr())
    result.add(question)
