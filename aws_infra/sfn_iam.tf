resource "aws_iam_role" "step_function_role" {
  name               = "Step_Function_Role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "states.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": "StepFunctionAssumeRole"
   }
 ]
}
EOF
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "iam_policy_step_function"
  path        = "/"
  description = "AWS IAM Policy for step function"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
  {
    "Action": "s3:GetObject",
    "Resource": ["arn:aws:s3:::${resource.aws_s3_bucket.config_bucket.id}/${resource.aws_s3_object.config_object.id}"],
    "Effect": "Allow"
  },
  {
    "Action": "lambda:InvokeFunction",
    "Effect": "Allow",
    "Resource": "${aws_lambda_function.lambda_func.arn}"
}
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_step_function" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}