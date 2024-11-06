variable "dns-global" {
    type = set(string)
    default = [ "10.14.24.10" ] 
}

variable "rg" {
    type = string
}

variable "hub-network" {
    type = string
}

variable "hub-name" {
    type = string
}

variable "hub-nexthop" {
  type = string
}

variable "hub-id" {
    type = string
}

variable "subscription_id" {
    type = string
}

