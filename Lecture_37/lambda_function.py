import boto3
import json

ses = boto3.client('ses', region_name="eu-north-1")

def lambda_handler(event, context):
    for record in event['Records']:
        event_type = record['eventName']
        
        if event_type in ['INSERT', 'MODIFY']:
            user_email = record['dynamodb']['NewImage']['email']['S']
            user_name = record['dynamodb']['NewImage']['name']['S']
            
            if event_type == 'INSERT':
                subject = f"Привет, {user_name}!"
                body_text = f"Спасибо за регистрацию, {user_name}!"
                body_html = f"<html><body><h1>Привет, {user_name}!</h1><p>Спасибо за регистрацию!</p></body></html>"
            else:
                subject = f"Обновление данных, {user_name}"
                body_text = f"Ваши данные обновлены, {user_name}!"
                body_html = f"<html><body><h1>Обновление данных, {user_name}</h1><p>Ваши данные были изменены в системе.</p></body></html>"
            
            try:
                ses.send_email(
                    Source="gerchukekaterina@gmail.com",
                    Destination={'ToAddresses': [user_email]},
                    Message={
                        'Subject': {'Data': subject},
                        'Body': {
                            'Text': {'Data': body_text},
                            'Html': {'Data': body_html}
                        }
                    }
                )
            except Exception as e:
                print(f"Ошибка при отправке email: {str(e)}")
    
    return {"statusCode": 200, "body": json.dumps("Success")}
