resource "aws_iam_role" "cw_event_role" {
  name               = "CW_Event_Role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cw_event_policy" {
  name        = "iam_policy_cw_events"
  path        = "/"
  description = "AWS IAM Policy for CW Event"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": [
                "arn:aws:states:::${resource.aws_sfn_state_machine.sfn_state_machine.id}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_cw_events" {
  role       = aws_iam_role.cw_events_role.name
  policy_arn = aws_iam_policy.cw_event_policy.arn
}