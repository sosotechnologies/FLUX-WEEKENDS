#  Variables
#  Region
variable "aws_region" {
  description = "Region"
  type = string
  default = "us-east-1"  
}
#  Variable
variable "environment" {
  description = "Environment Variable"
  type = string
  default = "prod"
}
#  Division
variable "business_divsion" {
  description = "Business Division"
  type = string
  default = "SAP"
}
