# DynamoDB Table for image uploads
resource "aws_dynamodb_table" "upload_table" {
  name           = "image_uploads"
  billing_mode   = "PAY_PER_REQUEST"  # No need to manage read/write capacity
  hash_key       = "filename"         # Primary key is 'filename'
  attribute {
    name = "filename"
    type = "S"  # String type
  }
  attribute {
    name = "upload_time"
    type = "S"  # String type (ISO 8601 formatted time or timestamp)
  }
  attribute {
    name = "status"
    type = "S"  # String type (e.g., "pending", "optimized")
  }

    # Create an index to search by status
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "upload_time"
    projection_type = "ALL"
  }


}
