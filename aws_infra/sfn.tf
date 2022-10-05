resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "openskynetwork-state-machine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "StartAt": "InjectDateOffset",
  "States": {
    "InjectDateOffset": {
      "Type": "Pass",
      "Next": "DateOffsetterLambda",
      "Result": {
        "days": -1
      },
      "ResultPath": "$.offset"
    },
    "DateOffsetterLambda": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "arn:aws:lambda:eu-west-2:930612219184:function:DateOffsetter"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException"
          ],
          "IntervalSeconds": 2,
          "MaxAttempts": 6,
          "BackoffRate": 2
        }
      ],
      "Next": "GetConfig"
    },
    "GetConfig": {
      "Type": "Task",
      "Parameters": {
        "Bucket": "openskynetwork-config-bucket",
        "Key": "step_function.json"
      },
      "Resource": "arn:aws:states:::aws-sdk:s3:getObject",
      "ResultSelector": {
        "airplane_icao24s.$": "States.StringToJson($.Body)"
      },
      "ResultPath": "$.config",
      "Next": "Map"
    },
    "Map": {
      "Type": "Map",
      "End": true,
      "Iterator": {
        "StartAt": "OpenskyNetworkScraperLambda",
        "States": {
          "OpenskyNetworkScraperLambda": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "OutputPath": "$.Payload",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName": "arn:aws:lambda:eu-west-2:930612219184:function:OpenSkyNetworkLambdaFunction"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException"
                ],
                "IntervalSeconds": 2,
                "MaxAttempts": 6,
                "BackoffRate": 2
              }
            ],
            "End": true
          }
        }
      },
      "ItemsPath": "$.config.airplane_icao24s",
      "MaxConcurrency": 10,
      "Parameters": {
        "time.$": "$.time",
        "airplane_icao24.$": "$$.Map.Item.Value"
      }
    }
  },
  "Comment": "S3 -> JSON",
  "TimeoutSeconds": 60
}
EOF

  depends_on = [aws_iam_role_policy_attachment.policy_attach_step_function]

}