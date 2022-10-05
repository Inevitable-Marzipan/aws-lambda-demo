data "archive_file" "opensky_network_scraper_file" {
  type        = "zip"
  source_file  = "${local.lambda_src_path}/lambda_functions/opensky_network_scraper.py"
  output_path = "${local.lambda_src_path}/opensky_network_scraper.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename         = data.archive_file.opensky_network_scraper_file.output_path
  function_name    = "OpenSkyNetworkScraper"
  role             = aws_iam_role.lambda_role.arn
  handler          = "opensky_network_scraper.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.opensky_network_scraper_file.output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  depends_on       = [aws_iam_role_policy_attachment.policy_attach_lambda]
  timeout          = 20

  environment {
    variables = {
      bucket = "${resource.aws_s3_bucket.data_bucket.id}"
    }

  }
}

data "archive_file" "date_offsetter_file" {
  type        = "zip"
  source_file  = "${local.lambda_src_path}/lambda_functions/date_offsetter.py"
  output_path = "${local.lambda_src_path}/date_offsetter.zip"
}

resource "aws_lambda_function" "date_offsetter_lambda_func" {
  filename         = data.archive_file.date_offsetter_file.output_path
  function_name    = "DateOffsetter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "date_offsetter.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.date_offsetter_file.output_base64sha256
  depends_on       = [aws_iam_role_policy_attachment.policy_attach_lambda]

}