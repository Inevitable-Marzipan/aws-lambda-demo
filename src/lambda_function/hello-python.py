import requests
import boto3

ssm = boto3.client('ssm')
parameter = ssm.get_parameter(Name='/development/opensky-network/username', WithDecryption=True)['Parameter']['Value']

def lambda_handler(event, context):

   message = 'Hello there {} !, username: {}'.format(event['key1'], parameter)
   return {
       'message' : message
   }