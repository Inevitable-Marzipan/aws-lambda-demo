resource "aws_cloudwatch_event_rule" "sfn_cron_rule" {
  name                = "TriggerStepFunction"
  description         = "Cron schedule to trigger Step Funtion"
  schedule_expression = "cron(59 23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "sfn" {
  rule      = aws_cloudwatch_event_rule.sfn_cron_rule.name
  target_id = "TriggerSfn"
  arn       = aws_sfn_state_machine.sfn_state_machine.arn
  role_arn  = aws_iam_role.cw_event_role.arn
}
