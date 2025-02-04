# Автоматизація розсилки електронних листів з AWS Lambda

## Опис проєкту
Цей проєкт реалізує автоматичну розсилку листів через Amazon SES при додаванні або оновленні записів у DynamoDB. AWS Lambda слухає зміни в DynamoDB Streams та відправляє email на вказану адресу.

---

## Передумови
### Переконайтесь, що у вас:
✅ Налаштований AWS CLI (`aws configure list`)  
✅ Є права доступу до **DynamoDB**, **Lambda**, **SES**  
✅ Вибраний регіон `eu-north-1`  
✅ Підтверджена електронна адреса в **Amazon SES**  

![Alt-текст](<1.png>)
![Alt-текст](<2.png>)
---

## Крок 1: Створення DynamoDB
Створюємо таблицю `Users`:
```sh
aws dynamodb create-table     --table-name Users     --attribute-definitions AttributeName=userId,AttributeType=S     --key-schema AttributeName=userId,KeyType=HASH     --billing-mode PAY_PER_REQUEST     --region eu-north-1
```
![Alt-текст](<3.png>)

### Додаємо тестовий запис
```sh
aws dynamodb put-item     --table-name Users     --item '{
        "userId": {"S": "12345"},
        "email": {"S": "user@example.com"},
        "name": {"S": "Іван"}
    }'     --region eu-north-1
```
![Alt-текст](<4.png>)
![Alt-текст](<10.png>)

---

## Крок 2: Включення DynamoDB Streams
```sh
aws dynamodb update-table     --table-name Users     --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES     --region eu-north-1
```

---

## Крок 3: Створення Lambda
```sh
aws lambda create-function     --function-name DynamoEmailSender     --runtime python3.8     --role "ROLE_ARN"     --handler lambda_function.lambda_handler     --zip-file fileb://function.zip     --region eu-north-1
```

---

## Крок 4: Прив’язка Lambda з DynamoDB Streams
```sh
aws lambda create-event-source-mapping     --function-name DynamoEmailSender     --event-source "STREAM_ARN"     --batch-size 1     --starting-position LATEST     --region eu-north-1
```

---

## Крок 5: Тестування
### Ручний тест Lambda
```sh
aws lambda invoke --function-name DynamoEmailSender output.txt --region eu-north-1
```
### Додавання нового користувача
```sh
aws dynamodb put-item     --table-name Users     --item '{
        "userId": {"S": "test001"},
        "email": {"S": "testuser@example.com"},
        "name": {"S": "Олексій"}
    }'     --region eu-north-1
```
### Перевірка логів
```sh
aws logs tail /aws/lambda/DynamoEmailSender --region eu-north-1 --follow
```
![Alt-текст](<6.png>)
![Alt-текст](<7.png>)
---

