data "archive_file" "python_file" {
  type        = "zip"
  source_dir  = "${local.lambda_src_path}/python/"
  output_path = "${local.lambda_src_path}/python/hello-python.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename         = data.archive_file.python_file.output_path
  function_name    = "Test_Lambda_Function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.python_file.output_base64sha256
  #layers           = [aws_lambda_layer_version.lambda_layer.arn]
  depends_on       = [aws_iam_role_policy_attachment.policy_attach]
}