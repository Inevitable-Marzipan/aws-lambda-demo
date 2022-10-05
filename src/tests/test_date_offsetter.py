from lambda_functions.date_offsetter import lambda_handler


def test_lambda_handler_zero_offset():
    
    event = {"time": "2015-10-08T16:53:06Z"}
    context = None
    expected_output = event

    actual = lambda_handler(event, context)

    assert actual == expected_output

def test_lambda_handler_day_offset():

    event = {"time": "2015-10-08T16:53:06Z",
             "offset": {
                "days": -1
             }}
    context = None
    expected_output = {
        "time": "2015-10-07T16:53:06Z",
        "offset": {
                "days": -1
        }}

    actual = lambda_handler(event, context)

    assert actual == expected_output