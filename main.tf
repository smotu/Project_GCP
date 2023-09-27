terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
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
    tag     = ["mishras95/apache:test"]
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
  location = "asia-south1-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "kubernetes_deployment" "apache" {
  metadata {
    name = "apache"
    labels = {
      App = "apache"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = ""apache""
      }
    }
    template {
      metadata {
        labels = {
          App = ""apache""
        }
      }
      spec {
        container {
          image = "mishras95/apache:test"
          name  = "apache"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "apache-lb" {
  metadata {
    name = "apachelb"
  }
  spec {
    selector = {
      App = kubernetes_deployment.apache.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }

