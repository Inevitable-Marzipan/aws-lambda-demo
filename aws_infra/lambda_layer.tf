# Used as filename for the lambda layer zip
resource "random_uuid" "lambda_src_hash" {
  keepers = {
    "${local.lambda_src_path}/requirements.txt" : filemd5("${local.lambda_src_path}/requirements.txt")
  }
}

# Installs packages using pip
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${local.lambda_src_path}/requirements.txt -t ${local.lambda_src_path}/dependencies/ --upgrade"
  }

  # Only re-run this if the dependencies or their versions
  # have changed since the last deployment with Terraform
  triggers = {
    # dependencies_versions = filemd5("${local.lambda_src_path}/requirements.txt")
    # source_code_hash = random_uuid.lambda_src_hash.result # This is a suitable option too
  }
}

data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${local.lambda_src_path}/dependencies/"
  output_path = "${path.module}/.tmp/${random_uuid.lambda_src_hash.result}.zip"

  # This is necessary, since archive_file is now a
  # `data` source and not a `resource` anymore.
  # Use `depends_on` to wait for the "install dependencies"
  # task to be completed.
  depends_on = [null_resource.install_dependencies]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.lambda_layer_zip.output_path
  layer_name = "lambda_layer"
}