# Backend###
variable "client_id_b" {}
variable "secret_id_b" {}
variable "tenant_id_b" {}
variable "subscription_id_b" {}

# FrontEnd
variable client_id_f {}
variable secret_id_f {}
variable tenant_id_f {}
variable subscription_id_f {}



variable "counts" {
    default = 2
}

variable "RGName-Prefix" {
  default = "RG"
}


variable "ADNSG" {}

variable "vnet" {}

variable "prefix" {}

