import json
import boto3
import logging
import os
from botocore.exceptions import ClientError

# --- Configuration & Logging Setup ---
# Set up professional logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Pull variables from Lambda Environment Variables (Security Best Practice)
REGION = os.environ.get('AWS_REGION_NAME', 'eu-north-1')
KB_ID = os.environ.get('KNOWLEDGE_BASE_ID', 'Z7CVCJQ8HN')
MODEL_ARN = os.environ.get('MODEL_ARN', 'arn:aws:bedrock:eu-north-1::foundation-model/amazon.nova-2-lite-v1:0')

# Initialize Bedrock Client outside the handler for connection pooling
client = boto3.client(service_name='bedrock-agent-runtime', region_name=REGION)

def lambda_handler(event, context):
    logger.info(f"Incoming Request: {json.dumps(event)}")
    
    try:
        # 1. Parse Input
        body = json.loads(event['body']) if 'body' in event else event
        user_text = body.get('text', '').strip()
        mode = body.get('mode', 'advice')
        
        if not user_text:
            logger.warning("Empty user text received.")
            return build_response(400, {"error": "User text is required"})

        # 2. Dynamic Persona Selection
        if mode == 'draft':
            persona = (
                "You are an expert Indian Legal Drafter. Generate a formal Legal Draft/FIR "
                "in English and Hindi using BNS sections. Use [Placeholders] for user details."
            )
        else:
            persona = (
                "You are Nyaya-Setu, a legal assistant for rural India. Explain rights "
                "under the Bharatiya Nyaya Sanhita (BNS) in simple Hindi and English."
            )

        logger.info(f"Invoking Knowledge Base {KB_ID} in {mode} mode.")

        # 3. Knowledge Base Execution
        response = client.retrieve_and_generate(
            input={'text': user_text},
            retrieveAndGenerateConfiguration={
                'type': 'KNOWLEDGE_BASE',
                'knowledgeBaseConfiguration': {
                    'knowledgeBaseId': KB_ID,
                    'modelArn': MODEL_ARN,
                    'generationConfiguration': {
                        'inferenceConfig': {
                            'textInferenceConfig': {
                                'temperature': 0.1,
                                'maxTokens': 2500
                            }
                        },
                        'additionalModelRequestFields': {
                            'system': persona
                        }
                    }
                }
            }
        )

        # 4. Extract Response & Citations
        ai_reply = response['output']['text']
        citations = extract_citations(response)
        
        logger.info(f"Response generated successfully with {len(citations)} citations.")

        return build_response(200, {
            'legal_advice': ai_reply,
            'citations': citations,
            'mode': mode,
            'status': 'success'
        })

    except ClientError as e:
        logger.error(f"AWS Bedrock ClientError: {str(e)}")
        return build_response(500, {"error": "Legal database connection failed."})
    except Exception as e:
        logger.error(f"Unexpected Error: {str(e)}", exc_info=True)
        return build_response(500, {"error": "An internal error occurred."})

def extract_citations(response):
    """Helper to parse complex Bedrock citation objects"""
    sources = set()
    for citation in response.get('citations', []):
        for reference in citation.get('retrievedReferences', []):
            s3_uri = reference.get('location', {}).get('s3Location', {}).get('uri', '')
            if s3_uri:
                # Clean up URI for better display in Flutter
                sources.add(s3_uri.split('/')[-1]) 
    return list(sources)

def build_response(status_code, body):
    """Helper for standardized API Gateway responses"""
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Content-Type': 'application/json'
        },
        'body': json.dumps(body)
    }