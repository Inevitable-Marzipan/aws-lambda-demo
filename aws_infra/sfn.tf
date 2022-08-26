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
        "Bucket": "${aws_s3_bucket.config_bucket.id}",
        "Key": "${aws_s3_object.config_object.id}"
      },
      "Resource": "arn:aws:states:::aws-sdk:s3:getObject",
      "End": true,
      "ResultSelector": {
        "myJson.$": "States.StringToJson($.Body)"
      }
    }
  },
  "Comment": "S3 -> JSON",
  "TimeoutSeconds": 60
}

EOF

  depends_on = [aws_iam_role_policy_attachment.policy_attach_step_function]

}