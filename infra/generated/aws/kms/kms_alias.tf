resource "aws_kms_alias" "tfer--alias-002F-aws-002F-dynamodb" {
  name = "alias/aws/dynamodb"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-ebs" {
  name = "alias/aws/ebs"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-elasticfilesystem" {
  name = "alias/aws/elasticfilesystem"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-es" {
  name = "alias/aws/es"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-glue" {
  name = "alias/aws/glue"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-kinesisvideo" {
  name = "alias/aws/kinesisvideo"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-lightsail" {
  name          = "alias/aws/lightsail"
  target_key_id = "f8e5b0b0-825f-488e-8a30-9c5e0bfd8316"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-rds" {
  name = "alias/aws/rds"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-redshift" {
  name = "alias/aws/redshift"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-s3" {
  name = "alias/aws/s3"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-sns" {
  name          = "alias/aws/sns"
  target_key_id = "92b0da4a-5822-4c43-ba87-edf40cbd8145"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-ssm" {
  name = "alias/aws/ssm"
}

resource "aws_kms_alias" "tfer--alias-002F-aws-002F-xray" {
  name = "alias/aws/xray"
}
