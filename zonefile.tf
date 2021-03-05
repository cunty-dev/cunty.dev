terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.58.0"
    }
  }
}
provider "google" {
  credentials = var.credentials
  project = var.project
  region  = var.region
  zone    = var.zone
}
# A resource block declares a resource of a given type 
# ("google_dns_managed_zone") with a given local name ("cunty"). 
# The name is used to refer to this resource from elsewhere 
# in the same Terraform module, but has no significance 
# outside that module's scope.
#
# The resource type and name together serve as an identifier 
# for a given resource and so must be unique within a module.
resource "google_dns_managed_zone" "cunty" {
  name        = "cunty"
  dns_name    = "cunty.dev."
  description = "There is only one@cunty.dev"
}

# !! The provider treats this resource as an authoritative record set. 
# This means existing records (including the default records) for 
# the given type will be overwritten when you create this resource 
# in Terraform. In addition, the Google Cloud DNS API requires
# NS records to be present at all times, so Terraform will not 
# actually remove NS records during destroy but will report that it did.

# resource "google_dns_record_set" "..." {}