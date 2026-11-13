
# The weather tier's cache and history.
# DynamoDB uses on-demand billing, and old records expire automatically.

resource "aws_dynamodb_table" "weather" {
  name         = "${var.name_prefix}-weather-lookups"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "zip"

  attribute {
    name = "zip"
    type = "S"
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = false
  }
}

# Create a secure location in AWS Parameter Store
# where the Gemini API key will be stored later.

resource "aws_ssm_parameter" "gemini" {
  name  = "/${var.name_prefix}/gemini-api-key"
  type  = "SecureString"
  value = "not-set-yet"

  lifecycle {
    ignore_changes = [value]
  }
}
