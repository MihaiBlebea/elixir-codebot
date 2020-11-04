terraform {
    required_version = "0.12.20"

    backend "remote" {
        organization = "PurpleTreeTech"

        workspaces {
            name = "elixir-codebot"
        }
    }
}

provider "digitalocean" {
    token   = var.do_token
    version = "1.22.0"
}

data "digitalocean_kubernetes_cluster" "cluster" {
    name = var.kubernetes_cluster_name
}

provider "kubernetes" {
    load_config_file       = false
    host                   = data.digitalocean_kubernetes_cluster.cluster.endpoint
    token                  = data.digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
        data.digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
}

resource "kubernetes_deployment" "elixir_codebot" {
    metadata {
        name      = "codebot-deployment"
        namespace = "mihaiblebea"
        labels    = {
            app  = "elixir-codebot"
            name = "codebot-deployment"
        }
    }

    spec {
        replicas = 1

        selector {
            match_labels = {
                app  = "elixir-codebot"
                name = "codebot-pod"
            }
        }

        template {
            metadata {
                name   = "codebot-pod"
                labels = {
                    app  = "elixir-codebot"
                    name = "codebot-pod"
                }
            }

            spec {
                container {
                    image = var.blog_image
                    name  = "codebot-container"
                    env {
                        name  = "HTTP_PORT"
                        value = var.http_port
                    }
                    env {
                        name = "LIST_URL"
                        value = "http://lists/lead"
                    }
                    port {
                        container_port = var.http_port
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "codebot_node_port" {
    metadata {
        name      = "codebot-service"
        namespace = "mihaiblebea"
    }

    spec {
        selector = {
            name = "codebot-pod"
        }

        port {
            port        = 80
            target_port = var.http_port
            node_port   = var.node_port
        }

        type = "NodePort"
    }
}