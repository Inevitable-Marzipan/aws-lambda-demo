import datetime

def lambda_handler(event, context):

    if event.get('offset', None) is None:
        return event

    input_datetime = datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ')
    td = datetime.timedelta(days=event.get('offset').get('days'))
    output_datetime = input_datetime + td
    event["time"] = output_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    return event