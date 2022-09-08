import os
import json
import time
import datetime
import logging

import requests
import boto3

url = "https://opensky-network.org/api/flights/aircraft"

# Logging https://dev.to/aws-builders/why-you-should-never-ever-print-in-a-lambda-function-3i37
logger = logging.getLogger()
logging.basicConfig(level=logging.INFO)  # To see output in local console
logger.setLevel(logging.INFO)  # To see output in Lambda


def get_unix_start_time(date):
    return int(time.mktime(date.timetuple()))

def get_unix_end_time(date):
    date = date + datetime.timedelta(days=1)
    return get_unix_start_time(date)

def get_data(url, auth=None, params=None):
    resp = requests.get(url, auth=auth, params=params)
    logger.info(f'response: {resp}')
    logger.info(f'response text: {resp.text}')
    data = resp.json()

    return data

def get_ssm_parameter(name):
    ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])
    parameter = ssm.get_parameter(Name=name, WithDecryption=True)['Parameter']['Value']
    return parameter

def _get_datetime_key(dt):
    key = (
        dt.strftime("%Y")
        + "/"
        + dt.strftime("%m")
        + "/"
        + dt.strftime("%d")
        + "/"
    )
    return key

def lambda_handler(event, context):

    logger.info(f"event: {event}")
    logger.info(f"context: {context}")

    query_datetime = datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ')
    unix_start = get_unix_start_time(query_datetime)
    unix_end = get_unix_end_time(query_datetime)
    airplane_icao24 = event['airplane_icao24']
    params = {'begin': unix_start, 'end': unix_end, 'icao24': airplane_icao24}

    logger.info(f"Query Parameters: {params}")

    auth = (get_ssm_parameter('/development/opensky-network/username'), 
            get_ssm_parameter('/development/opensky-network/password'))
    data = get_data(url, auth=auth, params=params)
    
    if data:
        logger.info("Saving data to S3")
        client = boto3.client('s3', region_name=os.environ['AWS_REGION'])
        key = f"{_get_datetime_key(query_datetime)}{airplane_icao24}.json" 
        client.put_object(Body=json.dumps(data), Bucket=os.environ['bucket'], Key=key)
    else:
        logger.info("No data to save to S3")