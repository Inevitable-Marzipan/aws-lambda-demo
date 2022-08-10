from lambda_function.lambda_function import (
    url,
    auth,
     get_unix_start_time,
     get_unix_end_time,
     get_data,
     lambda_handler
)
from tests.conftest import MockResponse

import os
import datetime
import json
from unittest.mock import patch
from unittest import mock

from moto import mock_s3
import boto3
import pytest

def test_get_unix_start_time():
    date = datetime.date(2022, 1, 1)

    expected = 1640995200
    actual = get_unix_start_time(date)

    assert actual == expected

def test_get_unix_end_time():
    date = datetime.date(2022, 1, 1)

    expected = 1641081600
    actual = get_unix_end_time(date)

    assert actual == expected

def test_get_data():
    url = ""
    auth = ('username', 'password')
    params = {"key": "value"}
    expected_data = {'data_key': 'data_value'}
    status_code = 200
    with patch('lambda_function.lambda_function.requests') as mock_requests:
        mock_requests.get.return_value = MockResponse(expected_data, status_code)
        actual = get_data(url, auth, params)
    
        assert actual == expected_data
        mock_requests.get.assert_called_once()
        mock_requests.get.assert_called_with(url, auth=auth, params=params)    

@mock_s3
@mock.patch.dict(os.environ, {"bucket": "test_bucket", "AWS_REGION": "eu-west-2"})
def test_lambda_handler():
    bucket_name = os.environ['bucket']
    region = os.environ['AWS_REGION']
    conn = boto3.resource('s3', region)
    conn.create_bucket(Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': region})

    event = {"time": "2015-10-08T16:53:06Z"}
    context = None

    unix_start = get_unix_start_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    unix_end = get_unix_end_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    params = {'begin': unix_start, 'end': unix_end}
    json_data = {"data_key": "data_value"}
    status_code = 200

    with patch('lambda_function.lambda_function.get_data') as mock_get_data:
        mock_get_data.return_value = json_data

        lambda_handler(event, context)
        mock_get_data.assert_called_once()
        mock_get_data.assert_called_with(url, auth=auth, params=params)

    body = conn.Object(bucket_name, 'test.json').get()[
    'Body'].read().decode("utf-8")

    assert json.loads(body) == json_data
