from unittest import mock
from lambda_function.lambda_function import (
     get_unix_start_time,
     get_unix_end_time,
     get_data,
     lambda_handler
)

import datetime
import json
from unittest.mock import patch

from tests.conftest import MockResponse

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
    expected_data = {'data': 'data'}
    status_code = 200
    with patch('lambda_function.lambda_function.requests') as mock_requests:
        mock_requests.get.return_value = MockResponse(expected_data, status_code)
        actual = get_data(url)
    
        assert actual == expected_data
        mock_requests.get.assert_called_once()
        mock_requests.get.assert_called_with(url)

def test_lambda_handler():
    event = None
    context = None
    expected = {"data": None}

    actual = lambda_handler(event, context)

    assert actual == expected
