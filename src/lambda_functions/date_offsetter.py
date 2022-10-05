import datetime
import logging

logger = logging.getLogger()
logging.basicConfig(level=logging.INFO)  # To see output in local console
logger.setLevel(logging.INFO)  # To see output in Lambda

def lambda_handler(event, context):

    logger.info(f"event: {event}")
    logger.info(f"context: {context}")

    if event.get('offset', None) is None:
        logger.info("No offset key given, exiting")
        return event

    logger.info("Calculating date offset")
    input_datetime = datetime.datetime.strptime(event['time'], '%Y-%m-%dT%H:%M:%SZ')
    td = datetime.timedelta(days=event.get('offset').get('days'))
    output_datetime = input_datetime + td
    event["time"] = output_datetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    return event