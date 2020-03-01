resource "random_pet" "this" {}

//locals {
//  name =
//}

module "label" {
  source = "github.com/robc-io/terraform-null-label.git?ref=0.16.1"

  name = var.name

  tags = {
    NetworkName = var.network_name
    Owner       = var.owner
    Terraform   = true
    VpcType     = "main"
  }

  environment = var.environment
  namespace   = var.namespace
  stage       = var.stage
}

module "ami" {
  source = "github.com/insight-infrastructure/terraform-aws-ami.git?ref=master"
}

resource "aws_eip" "this" {
  tags = merge({
    Name = "wazuh-server"
  }, module.label.tags)
  depends_on = [
  aws_instance.this]
}

resource "aws_eip_association" "this" {
  instance_id = aws_instance.this.id
  public_ip   = aws_eip.this.public_ip
}

resource "aws_key_pair" "this" {
  count      = var.public_key_path == "" ? 0 : 1
  public_key = file(var.public_key_path)
}

resource "aws_ebs_volume" "this" {
  count = var.ebs_volume_size > 0 ? 1 : 0

  availability_zone = aws_instance.this.availability_zone

  size = var.ebs_volume_size
  type = "gp2"

  tags = merge({ Mount : "data" }, module.label.tags)
}

resource "aws_volume_attachment" "this" {
  count = var.ebs_volume_size > 0 ? 1 : 0

  device_name = var.volume_path

  volume_id = aws_ebs_volume.this.*.id[0]

  instance_id  = aws_instance.this.id
  force_detach = true
}

data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "logs" {
  //  bucket = "${module.label.name}-logs-${data.aws_caller_identity.this.account_id}"
  bucket = "logs-${data.aws_caller_identity.this.account_id}"
  acl    = "private"
  tags   = module.label.tags
}

resource "aws_iam_role" "this" {
  name               = "${module.label.name}Role"
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
  name = "${module.label.name}InstanceProfile"
  role = aws_iam_role.this.name
}

resource "aws_iam_policy" "json_policy" {
  name   = "${module.label.name}Policy"
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

resource "aws_instance" "this" {
  ami           = module.ami.ubuntu_1804_ami_id
  instance_type = var.instance_type

  root_block_device {
    volume_size = var.root_volume_size
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile = aws_iam_instance_profile.this.id
  key_name             = var.public_key_path == "" ? var.key_name : aws_key_pair.this.*.key_name[0]

  tags = module.label.tags
}

module "ansible" {
  source           = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=master"
  ip               = aws_eip_association.this.public_ip
  user             = "ubuntu"
  private_key_path = var.private_key_path

  playbook_file_path = "${path.module}/ansible/main.yml"
  playbook_vars      = {}

  requirements_file_path = "${path.module}/ansible/requirements.yml"
}
