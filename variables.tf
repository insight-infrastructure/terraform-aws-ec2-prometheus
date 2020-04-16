########
# Label
########
variable "name" {
  description = "The name for the label"
  type        = string
  default     = "prometheus"
}

variable "environment" {
  description = "The environment"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace to deploy into"
  type        = string
  default     = "prod"
}

variable "stage" {
  description = "The stage of the deployment"
  type        = string
  default     = "blue"
}

variable "network_name" {
  description = "The network name, ie kusama / mainnet"
  type        = string
  default     = "main"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = ""
}

######
# Data
######
variable "eip_id" {
  description = "The elastic ip id to attach to active instance"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The id of the subnet"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security groups"
  type        = list(string)
}

#####
# ec2
#####
variable "key_name" {
  description = "The key pair to import"
  type        = string
  default     = ""
}

variable "monitoring" {
  description = "Boolean for cloudwatch"
  type        = bool
  default     = false
}

//variable "ebs_volume_size" {
//  description = "EBS volume size"
//  type        = string
//  default     = 0
//}

//variable "volume_path" {
//  description = "Volume path"
//  type        = string
//  default     = "/dev/xvdf"
//}

variable "root_volume_size" {
  description = "Root volume size"
  type        = string
  default     = 8
}

variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.small"
}

variable "public_key_path" {
  description = "The path to the public ssh key"
  type        = string
}

variable "private_key_path" {
  description = "The path to the private ssh key"
  type        = string
}

#####
# EBS
#####
variable "ebs_volume_id" {
  type        = string
  default     = ""
  description = "The volume id of the ebs volume to mount"
}

variable "ebs_volume_size" {
  description = "The size of volume - leave as zero or empty for no volume"
  type        = number
  default     = 0
}

variable "volume_path" {
  description = "The path of the EBS volume"
  type        = string
  default     = "/dev/xvdf"
}


#########
# Ansible
#########
variable "playbook_vars" {
  description = "Extra playbook vars"
  type        = map(string)
  default     = {}
}

variable "playbook_vars_file" {
  description = "Path to vars file"
  type        = string
  default     = ""
}

variable "alertmanager_receivers" {
  description = "list of recievers per docs https://prometheus.io/docs/alerting/configuration/#example"
  type        = list(map(string))
  default     = [{}]
}


//variable "private_key_path" {
//  description = "Path to the private ssh key"
//  type        = string
//  default     = ""
//}
//
//variable "playbook_file_path" {
//  description = "The path to the playbook"
//  type        = string
//  default     = ""
//}
//
//variable "user" {
//  description = "The user for configuring node with ansible"
//  type        = string
//  default     = "ubuntu"
//}



variable "root_domain_name" {
  description = "The name of the root domain name"
  type        = string
  default     = ""
}

variable "hostname" {
  description = "Boolean to create a hostname - ie hostname.example.com"
  type        = string
  default     = ""
}

