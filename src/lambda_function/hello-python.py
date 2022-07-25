import requests
import boto3

ssm = boto3.client('ssm')
parameter = ssm.get_parameter(Name='username', WithDecryption=True)['Parameter']['Value']

def lambda_handler(event, context):

   message = 'Hello {} !, username: {}'.format(event['key1'], parameter)
   return {
       'message' : message
   }