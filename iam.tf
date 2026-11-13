
# Allow EC2 instances to assume IAM roles.
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create a separate IAM role for each application tier.
resource "aws_iam_role" "tier" {
  for_each = local.tiers

  name               = "${var.name_prefix}-${each.key}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

# Attach each IAM role to an EC2 instance through a profile.
resource "aws_iam_instance_profile" "tier" {
  for_each = local.tiers

  name = "${var.name_prefix}-${each.key}-profile"
  role = aws_iam_role.tier[each.key].name
}

# Weather application can read, write, and scan its DynamoDB table.
data "aws_iam_policy_document" "weather" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Scan"]
    resources = [aws_dynamodb_table.weather.arn]
  }
}

# Advisor application can read only the Gemini API key parameter.
data "aws_iam_policy_document" "advisor" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.gemini.arn]
  }
}

# Apply the DynamoDB permissions to the weather role.
resource "aws_iam_role_policy" "weather" {
  name   = "${var.name_prefix}-weather-policy"
  role   = aws_iam_role.tier["weather"].id
  policy = data.aws_iam_policy_document.weather.json
}

# Apply the Parameter Store permission to the advisor role.
resource "aws_iam_role_policy" "advisor" {
  name   = "${var.name_prefix}-advisor-policy"
  role   = aws_iam_role.tier["advisor"].id
  policy = data.aws_iam_policy_document.advisor.json
}
