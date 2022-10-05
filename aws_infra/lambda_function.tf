data "archive_file" "python_file" {
  type        = "zip"
  source_file  = "${local.lambda_src_path}/lambda_functions/opensky_network_scraper.py"
  output_path = "${local.lambda_src_path}/opensky_network_scraper.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename         = data.archive_file.python_file.output_path
  function_name    = "OpenSkyNetworkScraper"
  role             = aws_iam_role.lambda_role.arn
  handler          = "opensky_network_scraper.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.python_file.output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  depends_on       = [aws_iam_role_policy_attachment.policy_attach_lambda]
  timeout          = 20

  environment {
    variables = {
      bucket = "${resource.aws_s3_bucket.data_bucket.id}"
    }

  }
}