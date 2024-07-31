resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  policy_arn = aws_iam_policy.terraform_policy.arn
  role      = aws_iam_role.ecs_task_execution_role.name
}


resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  policy_arn = aws_iam_policy.terraform_policy.arn
  role      = aws_iam_role.ecs_task_role.name
}

