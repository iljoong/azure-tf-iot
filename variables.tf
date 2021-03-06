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
  default = "koreacentral"
}

variable "tag" {
  default = "demo"
}

# admin username & password for MS SQL
variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  default = "add_here"
}

variable "webapp_template_path" {
  default = "./azwebapp_deploy.json"
}

variable "fxapp_template_path" {
  default = "./azfxapp_deploy.json"
}

# deploy `assets\fxapp.zip` to blob storage
variable "fxapp_package_url" {
  default = "_add_here_"
}

# function app url of after `fxurl` deployment
variable "fx_url" {
  default = "_add_here_"
}

# my PC public ip, get it by `curl ipinfo.io`
variable "local_ip" {
  default = "_add_here_"
}