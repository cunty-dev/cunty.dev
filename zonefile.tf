terraform {
  backend "remote" {
    organization = "cloud84"
    workspaces {
      name = "cunty-dev"
    }
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.58.0"
    }
  }
}
provider "google" {
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

# !?!
#
# The provider treats this resource ("google_dns_record_set")
# as an authoritative record set. This means existing records
# (including the default records) for the given type will be
# overwritten when you create this resource in Terraform.
# In addition, the Google Cloud DNS API requires
# NS records to be present at all times, so Terraform will not
# actually remove NS records during destroy but will report that it did.
#
# resource "google_dns_record_set" "..." {}

# Fastmail email
resource "google_dns_record_set" "mx" {
  name         = google_dns_managed_zone.cunty.dns_name
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "MX"
  ttl          = 3600

  rrdatas = [
    "10 in1-smtp.messagingengine.com.",
    "20 in2-smtp.messagingengine.com.",
  ]
}

# Fastmail SPF (optional)
resource "google_dns_record_set" "spf" {
  name         = google_dns_managed_zone.cunty.dns_name
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "TXT"
  ttl          = 3600

  # The quotes are part of the data, so must be escaped.
  rrdatas = [
    "\"v=spf1 include:spf.messagingengine.com ?all\"",
  ]
}

# Fastmail DKIM (optional)
resource "google_dns_record_set" "cname" {
  count        = 3
  name         = "fm${count.index + 1}._domainkey.cunty.dev."
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "CNAME"
  ttl          = 3600

  rrdatas = [ "fm${count.index + 1}.${google_dns_managed_zone.cunty.dns_name}dkim.fmhosted.com." ]
}

# GitHub Verified Domain
resource "google_dns_record_set" "www_cunty_dev_github_veri" {
  name         = "_github-challenge-cunty-dev.www.cunty.dev."
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = ["e2096a1681"]
}

resource "google_dns_record_set" "cunty_dev_github_veri" {
  name         = "_github-challenge-cunty-dev.cunty.dev."
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = ["65215259de"]
}

# Point cunty.dev (apex domain) to GitHub Pages
resource "google_dns_record_set" "apex_cunty_dev" {
  name         = google_dns_managed_zone.cunty.dns_name
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "A"
  ttl          = 3600

  rrdatas = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

# Point www.cunty.dev to GitHub Pages
resource "google_dns_record_set" "www_cunty_dev" {
  name         = "www.${google_dns_managed_zone.cunty.dns_name}"
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "CNAME"
  ttl          = 3600

  rrdatas = [ "cunty-dev.github.io." ]
}

# Verify cunty.dev for Google Cloud Identity
resource "google_dns_record_set" "google_site_verification" {
  name         = "@"
  managed_zone = google_dns_managed_zone.cunty.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = ["google-site-verification=LPbtg2Y3GHUCV1D7-PYOcf7U0o3CNIIYk83BLYWWXtw"]
}
