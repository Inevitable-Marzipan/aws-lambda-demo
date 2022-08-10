import os
import json
import time
import datetime
import requests
import boto3

url = ""
auth = ('username', 'password')


def get_unix_start_time(date):
    return int(time.mktime(date.timetuple()))

def get_unix_end_time(date):
    date = date + datetime.timedelta(days=1)
    return get_unix_start_time(date)

def get_data(url, auth=None, params=None):
    resp = requests.get(url, auth=auth, params=params)
    data = resp.json()

    return data

def lambda_handler(event, context):
    unix_start = get_unix_start_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    unix_end = get_unix_end_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    params = {'begin': unix_start, 'end': unix_end}
    data = get_data(url, auth=auth, params=params)
    client = boto3.client('s3', region_name=os.environ['AWS_REGION'])
    client.put_object(Body=json.dumps(data), Bucket=os.environ['bucket'], Key='test.json')