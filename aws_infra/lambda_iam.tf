data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name               = "Lambda_Function_Role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "iam_policy_lambda_function"
  path        = "/"
  description = "AWS IAM Policy for lambda function"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
  {
    "Action": ["ssm:GetParameter*"],
    "Resource": ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/development/opensky-network/*"],
    "Effect": "Allow"
  },
  {
    "Action": "s3:PutObject",
    "Resource": ["arn:aws:s3:::${resource.aws_s3_bucket.data_bucket.id}/*"],
    "Effect": "Allow"
  }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_lambda" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}