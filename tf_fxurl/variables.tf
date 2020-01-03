# azure service principal info
variable "subscription_id" {
  default = "add_here"
}

# client_id or app_id
variable "client_id" {
  default = "add_here"
}

variable "client_secret" {
  default = "add_here"
}

# tenant_id or directory_id
variable "tenant_id" {
  default = "add_here"
}

# service variables
variable "prefix" {
  default = "tfdemo"
}

variable "location" {
  default = "koreasouth"
}

variable "tag" {
  default = "demo"
}

variable "fxapp_template_path" {
  default = "./azfxapp_deploy.json"
}

# upload `.\assets\fxurl.zip` to blob storage and update values
variable "fxpackageurl" {
  default = "_add_here_"
}