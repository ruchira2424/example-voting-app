terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ───── Enable Required APIs ─────
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

# ───── Artifact Registry Repository ─────
resource "google_artifact_registry_repository" "voting_app" {
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"
  description   = "Docker images for voting app"

  depends_on = [google_project_service.apis]
}

# ───── Cloud Run: Vote Service ─────
resource "google_cloud_run_v2_service" "vote" {
  name     = "vote-${var.environment}"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/vote:latest"
      
      ports {
        container_port = 80
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
  }

  depends_on = [google_project_service.apis]
}

# ───── Cloud Run: Result Service ─────
resource "google_cloud_run_v2_service" "result" {
  name     = "result-${var.environment}"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/result:latest"
      
      ports {
        container_port = 80
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
  }

  depends_on = [google_project_service.apis]
}

# ───── Cloud Run: Worker Service ─────
resource "google_cloud_run_v2_service" "worker" {
  name     = "worker-${var.environment}"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_name}/worker:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }
  }

  depends_on = [google_project_service.apis]
}

# ───── IAM: Make vote and result public ─────
resource "google_cloud_run_v2_service_iam_member" "vote_public" {
  name     = google_cloud_run_v2_service.vote.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "result_public" {
  name     = google_cloud_run_v2_service.result.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}