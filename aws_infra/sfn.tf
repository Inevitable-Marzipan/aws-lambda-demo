resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "openskynetwork-state-machine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<EOF
{
  "StartAt": "GetObject",
  "States": {
    "GetObject": {
      "Type": "Task",
      "Parameters": {
        "Bucket": "openskynetwork-config-bucket",
        "Key": "step_function.json"
      },
      "Resource": "arn:aws:states:::aws-sdk:s3:getObject",
      "ResultSelector": {
        "airplane_icao24s.$": "States.StringToJson($.Body)"
      },
      "End": true,
      "ResultPath": "$.config"
    }
  },
  "Comment": "S3 -> JSON",
  "TimeoutSeconds": 60
}
EOF

  depends_on = [aws_iam_role_policy_attachment.policy_attach_step_function]

}