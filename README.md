# Курс для Платформы

Установить [CourseCompiler](https://github.com/BSU-RFCT-Afonenko-Cources/CourseCompiler) и добавить его в PATH.

```bash
cd lab
coco _course.yaml produced.yaml
```

Далее на платформе импортировать из файла `produced.yaml`

# Методичка

## html

```bash
quarto render --to html --profile student,html
```

## pdf

```bash
quarto render --to pdf --profile student,pdf
```

## Методичка с решениями

## html

```bash
quarto render --to html --profile full,dev,html
```

## pdf

```bash
quarto render --to pdf --profile full,dev,pdf
```
