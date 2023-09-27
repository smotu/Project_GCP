terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}


provider "google" {
  project     = "fleet-resolver-397903"
  region      = "asia-south1-a"
}


resource "docker_image" "apache" {
  name = "apache"
  build {
    context = "."
    tag     = ["apache:test"]
#    build_arg = {
#      foo : "" 
#    }
    label = {
      author : "sagar"
    }
  }
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

