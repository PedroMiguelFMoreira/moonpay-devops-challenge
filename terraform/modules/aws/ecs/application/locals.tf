locals {
  target_groups    = [
    "green",
    "blue"
  ]
  default_inline_policies = [
    {
      version : "2012-10-17"
      name : "logs"
      statement : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          "Resource" : [
            "arn:aws:logs:*:*:*"
          ]
        }
      ]
    }
  ]
}