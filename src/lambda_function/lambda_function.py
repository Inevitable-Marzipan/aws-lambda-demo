import time
import datetime
import requests

def get_unix_start_time(date):
    return int(time.mktime(date.timetuple()))

def get_unix_end_time(date):
    date = date + datetime.timedelta(days=1)
    return get_unix_start_time(date)

def get_data(url, auth=None, params=None):
    resp = requests.get(url)
    data = resp.json()

    return data

def lambda_handler(event, context):

    data = None
    return {
        'data' : data
    }