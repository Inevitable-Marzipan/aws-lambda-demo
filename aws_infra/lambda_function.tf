data "archive_file" "python_file" {
  type        = "zip"
  source_dir  = "${path.module}/../python/"
  output_path = "${path.module}/../python/hello-python.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename      = "${local.lambda_src_path}/lambda_function/hello-python.zip"
  function_name = "Test_Lambda_Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.policy_attach]
}