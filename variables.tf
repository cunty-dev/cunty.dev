variable "project" {
	type = string
}

variable "credentials" {
	type = string
	sensitive = true
}

variable "region" {
	type = string
}

variable "zone" {
	type = string
}