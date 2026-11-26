resource "google_service_account" "executor" {
  account_id   = var.name
  description  = "lace-team=${var.team_id}"
  display_name = "Lace team role ${var.name}"
  project      = var.project_id
}
resource "google_service_account_iam_member" "executor_federation" {
  member             = var.executor_member
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.executor.name
}
resource "google_project_iam_member" "executor" {
  for_each = toset(concat(var.roles, var.observer_roles))
  member   = "serviceAccount:${google_service_account.executor.email}"
  project  = var.project_id
  role     = each.value
}
resource "google_service_account" "planner" {
  account_id   = "${var.name}-plan"
  description  = "lace-team=${var.team_id}"
  display_name = "Lace team role ${var.name}-plan"
  project      = var.project_id
}
resource "google_service_account_iam_member" "planner_federation" {
  member             = var.planner_member
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.planner.name
}
resource "google_project_iam_member" "planner" {
  for_each = toset(var.planner_roles)
  member   = "serviceAccount:${google_service_account.planner.email}"
  project  = var.project_id
  role     = each.value
}
