from lambda_function.lambda_function import (
    url,
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
from unittest.mock import Mock

from moto import mock_s3, mock_ssm
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
@mock_ssm
@mock.patch.dict(os.environ, {"bucket": "test_bucket", "AWS_REGION": "eu-west-2"})
@patch('lambda_function.lambda_function._get_datetime_key', '2015/10/08/16/53/')
def test_lambda_handler():
    # AWS setup
    bucket_name = os.environ['bucket']
    region = os.environ['AWS_REGION']
    conn_s3 = boto3.resource('s3', region)
    conn_s3.create_bucket(Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': region})

    username = 'username'
    password = 'password'
    client_ssm = boto3.client('ssm', region)
    client_ssm.put_parameter(Name='/development/opensky-network/username', Value=username)
    client_ssm.put_parameter(Name='/development/opensky-network/password', Value=password)

    # Input setup
    event = {"time": "2015-10-08T16:53:06Z", 'airplane_icao24': '1234'}
    context = None

    # Expected setup
    unix_start = get_unix_start_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    unix_end = get_unix_end_time(datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ'))
    auth = (username, password)
    params = {'begin': unix_start, 'end': unix_end, 'airplane_icao24': event['airplane_icao24']}
    json_data = {"data_key": "data_value"}
    status_code = 200

    with patch('lambda_function.lambda_function.get_data') as mock_get_data:
        mock_get_data.return_value = json_data

        lambda_handler(event, context)
        mock_get_data.assert_called_once()
        mock_get_data.assert_called_with(url, auth=auth, params=params)

    body = conn_s3.Object(bucket_name, f'2015/10/08/16/53/{event["airplane_icao24"]}.json').get()[
    'Body'].read().decode("utf-8")

    assert json.loads(body) == json_data
