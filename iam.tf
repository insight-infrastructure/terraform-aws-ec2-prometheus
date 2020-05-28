resource "random_pet" "this" {
  length = 1
}

resource "aws_iam_role" "this" {
  name               = "${module.label.id}Role${title(random_pet.this.id)}}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = module.label.tags
}

resource "aws_iam_instance_profile" "this" {
  name = "${module.label.name}InstanceProfile${title(random_pet.this.id)}"
  role = aws_iam_role.this.name
}

resource "aws_iam_policy" "json_policy" {
  name   = "${module.label.name}Policy${title(random_pet.this.id)}"
  policy = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EbsVolumeAttach",
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume"
            ],
            "Resource": "[${aws_ebs_volume.this.*.arn[0]},${aws_instance.this.*.arn[0]}]"
        },
        {
            "Sid": "EbsVolumeDescribe",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        },
        {
          "Sid":"ReadWrite",
          "Effect":"Allow",
          "Action":["s3:GetObject", "s3:PutObject"],
          "Resource":["arn:aws:s3:::${aws_s3_bucket.logs.bucket}/*"]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "json_policy" {
  role = aws_iam_role.this.id

  policy_arn = aws_iam_policy.json_policy.arn
}