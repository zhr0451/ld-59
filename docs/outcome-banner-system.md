# Outcome Banner System

Документ описывает экран последствий, который появляется после выбора ответа в нарративной головоломке.

## Назначение

`OutcomePanel` показывает арт последствия выбранного ответа. Баннер выбирается не по персонажу напрямую, а по конкретному варианту ответа в текущем вопросе.

Поток:

1. Игрок выбирает ответ в `QuestPanel`.
2. `main_quest_logic.gd` определяет индекс ответа.
3. По этому индексу берётся картинка из `current_question.answer_banners`.
4. `QuestPanel` закрывается.
5. Открывается `CanvasLayer/UIRoot/OutcomePanel`.
6. Таймер ставится на паузу, пока игрок смотрит баннер.
7. Игрок нажимает `Continue`.
8. Таймер продолжает работу.
9. Игра продолжает старую ветку:
   - правильный ответ открывает `TeleportPanel`;
   - неправильный ответ запускает провал и плохой портал.

Если у ответа нет баннера, система пропускает `OutcomePanel` и работает как раньше.

## Основные файлы

- `src/resources/narrative_question.gd`
- `src/ui/outcome_banner_logic.gd`
- `src/game_logic/puzzle/main_quest_logic.gd`
- `scenes/main_scene.tscn`
- `resources/questions/*.tres`
- `assets/banners/*.png`

## UI

Узел находится в основной сцене:

```text
CanvasLayer/UIRoot/OutcomePanel
|- Backdrop
|- BannerTextureRect
|- ContinueButton
```

`OutcomePanel` изначально скрыт. Он открывается только через `main_quest_logic.gd`.

Во время показа `OutcomePanel` игровой таймер не уменьшается.

## Конфиг вопроса

Один вопрос хранится в ресурсе `NarrativeQuestion`.

Поле баннеров:

```gdscript
@export var answer_banners: Array[Texture2D] = []
```

Индексы должны совпадать:

```text
answers[0] -> answer_banners[0]
answers[1] -> answer_banners[1]
answers[2] -> answer_banners[2]
```

Пример:

```text
answers = [
  "Send the traveler to the tower",
  "Send the traveler to the sea",
  "Send the traveler to the wasteland"
]

correct_answer_index = 0

answer_banners = [
  res://assets/banners/v-p-tower.png,
  res://assets/banners/v-p-sea.png,
  res://assets/banners/v-p-pustosh.png
]
```

В этом примере:

- первый ответ правильный, даёт `Good +1`, показывает `v-p-tower.png`, затем открывает `TeleportPanel`;
- второй ответ неправильный, даёт `Evil +1`, показывает `v-p-sea.png`, затем запускает провал;
- третий ответ неправильный, даёт `Evil +1`, показывает `v-p-pustosh.png`, затем запускает провал.

## Как добавить новый баннер

1. Помести картинку в `assets/banners`.
2. Открой нужный ресурс вопросов в `resources/questions`.
3. Выбери нужный `NarrativeQuestion`.
4. В поле `answer_banners` добавь 3 картинки.
5. Убедись, что порядок картинок совпадает с порядком ответов.

## Правила поддержки

- Не привязывай баннеры напрямую к кнопкам `AnswerButton1/2/3`.
- Не добавляй логику выбора баннера в скрипты персонажей.
- Вся логика выбора результата должна оставаться в `main_quest_logic.gd`.
- Если вопрос имеет 3 ответа, желательно добавлять 3 баннера.
- Если баннер не назначен, игра не упадёт, но экран последствия не появится.
