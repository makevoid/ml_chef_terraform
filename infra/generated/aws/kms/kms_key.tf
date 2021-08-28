resource "aws_kms_key" "tfer--92b0da4a-002D-5822-002D-4c43-002D-ba87-002D-edf40cbd8145" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Default key that protects my SNS data when no other key is defined"
  enable_key_rotation      = "true"
  is_enabled               = "true"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = "{\"Id\":\"auto-sns-1\",\"Statement\":[{\"Action\":[\"kms:Decrypt\",\"kms:GenerateDataKey*\",\"kms:CreateGrant\",\"kms:ListGrants\",\"kms:DescribeKey\"],\"Condition\":{\"StringEquals\":{\"kms:CallerAccount\":\"379937780633\",\"kms:ViaService\":\"sns.eu-central-1.amazonaws.com\"}},\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Resource\":\"*\",\"Sid\":\"Allow access through SNS for all principals in the account that are authorized to use SNS\"},{\"Action\":[\"kms:Describe*\",\"kms:Get*\",\"kms:List*\",\"kms:RevokeGrant\"],\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::379937780633:root\"},\"Resource\":\"*\",\"Sid\":\"Allow direct access to key metadata to the account\"}],\"Version\":\"2012-10-17\"}"
}

resource "aws_kms_key" "tfer--f8e5b0b0-002D-825f-002D-488e-002D-8a30-002D-9c5e0bfd8316" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Default master key that protects my Lightsail signing keys when no other key is defined"
  enable_key_rotation      = "true"
  is_enabled               = "true"
  key_usage                = "ENCRYPT_DECRYPT"
  policy                   = "{\"Id\":\"auto-lightsail-1\",\"Statement\":[{\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:ReEncrypt*\",\"kms:GenerateDataKey*\",\"kms:DescribeKey\"],\"Condition\":{\"StringEquals\":{\"kms:CallerAccount\":\"379937780633\",\"kms:ViaService\":\"lightsail.eu-central-1.amazonaws.com\"}},\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Resource\":\"*\",\"Sid\":\"Allow access through Lightsail for all principals in the account that are authorized to use Lightsail\"},{\"Action\":[\"kms:Describe*\",\"kms:Get*\",\"kms:List*\"],\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::379937780633:root\"},\"Resource\":\"*\",\"Sid\":\"Allow direct access to key metadata to the account\"},{\"Action\":[\"kms:Describe*\",\"kms:Get*\",\"kms:List*\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lightsail.amazonaws.com\"},\"Resource\":\"*\",\"Sid\":\"Allow Lightsail with service principal name lightsail.amazonaws.com to describe the key directly\"}],\"Version\":\"2012-10-17\"}"
}
