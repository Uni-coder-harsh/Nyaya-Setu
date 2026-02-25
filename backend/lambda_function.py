import json
import boto3

def lambda_handler(event, context):
    """
    This function handles the API request.
    For the Hackathon, we start simple: Receive text -> Return text.
    """
    
    try:
        if 'body' in event:
            body = json.loads(event['body'])
            user_text = body.get('text', '')
        else:
            user_text = event.get('text', '')
            
        print(f"Received input: {user_text}")
        
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps(f"Error parsing input: {str(e)}")
        }

    ai_response = f"Nyaya-Setu Backend received: '{user_text}'. I am ready to process this legal query."

    # 3. Return Response
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',  # Required for CORS (Flutter)
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': ai_response
        })
    }