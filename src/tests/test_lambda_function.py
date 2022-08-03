from lambda_function.lambda_function import (
     get_unix_start_time,
     get_unix_end_time,
     get_data,
     lambda_handler
)

def test_get_unix_start_time():
    pass

def test_get_unix_end_time():
    pass

def test_lambda_handler():
    event = None
    context = None
    expected = {"data": None}

    actual = lambda_handler(event, context)

    assert actual == expected
