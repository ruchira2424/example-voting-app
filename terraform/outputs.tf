output "vote_url" {
  description = "Vote service URL"
  value       = "https://vote-dev-768488519065.us-central1.run.app"
}

output "result_url" {
  description = "Result service URL"
  value       = "https://result-dev-768488519065.us-central1.run.app"
}

output "worker_name" {
  description = "Worker service name"
  value       = google_cloud_run_v2_service.worker.name
}