/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  hub_and_spoke_roles = [
    "roles/compute.instanceAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
  ]
}

/******************************************
  Projects for log sinks
*****************************************/

module "org_audit_logs" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = var.audit_project_overwrite != null ? var.audit_project_overwrite : "${local.project_prefix}-c-logging"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = local.parent # google_folder.common.id
  activate_apis            = ["logging.googleapis.com", "bigquery.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-logging"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  # JC Note: Unknown budget issue / bug. Not setting budget for now.
  budget_alert_pubsub_topic   = var.project_budget.org_audit_logs_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.org_audit_logs_alert_spent_percents
  budget_amount               = null # var.project_budget.org_audit_logs_budget_amount
}

# JC Note: Note currently using an Org wide Billing Export. This project will contain the Cloud Services billing exports
module "org_billing_logs" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = var.billing_project_overwrite != null ? var.billing_project_overwrite : "${local.project_prefix}-c-billing-logs"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = local.parent # google_folder.folder_prod.id
  activate_apis            = ["logging.googleapis.com", "bigquery.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-billing-logs"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  # JC Note: Unknown budget issue / bug. Not setting budget for now.
  budget_alert_pubsub_topic   = var.project_budget.org_billing_logs_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.org_billing_logs_alert_spent_percents
  budget_amount               = null # var.project_budget.org_billing_logs_budget_amount
}

# /******************************************
#   Project for Org-wide Secrets
# *****************************************/
# JC Notes: Not currently using a separate project for secrets.

# module "org_secrets" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 14.0"

#   random_project_id        = true
#   random_project_id_length = 4
#   default_service_account  = "deprivilege"
#   name                     = "${local.project_prefix}-c-secrets"
#   org_id                   = local.org_id
#   billing_account          = local.billing_account
#   folder_id                = google_folder.folder_prod.id
#   activate_apis            = ["logging.googleapis.com", "secretmanager.googleapis.com", "billingbudgets.googleapis.com"]

#   labels = {
#     environment       = "production"
#     application_name  = "org-secrets"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "abcd"
#     env_code          = "p"
#   }
#   budget_alert_pubsub_topic   = var.project_budget.org_secrets_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.org_secrets_alert_spent_percents
#   budget_amount               = var.project_budget.org_secrets_budget_amount
# }

# JC Note: We use the base network project for our interconnect.

# /******************************************
#   Project for Interconnect
# *****************************************/

# module "interconnect" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 14.0"

#   random_project_id        = true
#   random_project_id_length = 4
#   default_service_account  = "deprivilege"
#   name                     = "${local.project_prefix}-c-interconnect"
#   org_id                   = local.org_id
#   billing_account          = local.billing_account
#   folder_id                = local.parent # google_folder.folder_prod.id
#   activate_apis            = ["billingbudgets.googleapis.com", "compute.googleapis.com"]

#   labels = {
#     environment       = "production"
#     application_name  = "org-interconnect"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "abcd"
#     env_code          = "p"
#   }
#   # JC Note: Unknown budget issue / bug. Not setting budget for now.
#   budget_alert_pubsub_topic   = var.project_budget.org_billing_logs_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.org_billing_logs_alert_spent_percents
#   budget_amount               = null # var.project_budget.org_billing_logs_budget_amount
# }

/******************************************
  Project for SCC Notifications
*****************************************/
# JC Note: We manage audit logs / pub/subs in one project org-audit-logs
# module "scc_notifications" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 14.0"

#   random_project_id        = true
#   random_project_id_length = 4
#   default_service_account  = "deprivilege"
#   name                     = "${local.project_prefix}-c-scc"
#   org_id                   = local.org_id
#   billing_account          = local.billing_account
#   folder_id                = local.parent # google_folder.folder_prod.id
#   activate_apis            = ["logging.googleapis.com", "pubsub.googleapis.com", "securitycenter.googleapis.com", "billingbudgets.googleapis.com"]

#   labels = {
#     environment       = "production"
#     application_name  = "org-scc"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "abcd"
#     env_code          = "p"
#   }
#   # JC Note: Unknown budget issue / bug. Not setting budget for now.
#   budget_alert_pubsub_topic   = var.project_budget.org_billing_logs_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.org_billing_logs_alert_spent_percents
#   budget_amount               = null # var.project_budget.org_billing_logs_budget_amount
# }

# /******************************************
#   Project for DNS Hub
# *****************************************/
# JC Note: The InfoBlox DNS Appliances are in the same project as the Interconnects.
# module "dns_hub" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 14.0"

#   random_project_id        = true
#   random_project_id_length = 4
#   default_service_account  = "deprivilege"
#   name                     = "${local.project_prefix}-c-dns-hub"
#   org_id                   = local.org_id
#   billing_account          = local.billing_account
#   folder_id                = google_folder.folder_prod.id

#   activate_apis = [
#     "compute.googleapis.com",
#     "dns.googleapis.com",
#     "servicenetworking.googleapis.com",
#     "logging.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "billingbudgets.googleapis.com"
#   ]

#   labels = {
#     environment       = "production"
#     application_name  = "org-dns-hub"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "abcd"
#     env_code          = "p"
#   }
#   budget_alert_pubsub_topic   = var.project_budget.dns_hub_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.dns_hub_alert_spent_percents
#   budget_amount               = var.project_budget.dns_hub_budget_amount
# }

/******************************************
  Project for Base Network Hub
*****************************************/

module "base_network_hub" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"
  count   = var.enable_hub_and_spoke ? 1 : 0

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = var.base_network_project_overwrite != null ? var.base_network_project_overwrite : "${local.project_prefix}-c-base-net-hub"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = local.parent

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudasset.googleapis.com"
  ]

  labels = {
    environment       = "production"
    application_name  = "org-base-net-hub"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.base_net_hub_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.base_net_hub_alert_spent_percents
  budget_amount               = var.project_budget.base_net_hub_budget_amount
}

resource "google_project_iam_member" "network_sa_base" {
  for_each = toset(var.enable_hub_and_spoke ? local.hub_and_spoke_roles : [])

  project = module.base_network_hub[0].project_id
  role    = each.key
  member  = "serviceAccount:${local.networks_step_terraform_service_account_email}"
}

# /******************************************
#   Project for Restricted Network Hub
# *****************************************/
# JC Note: No current plans for a restricted network hub. 
# module "restricted_network_hub" {
#   source  = "terraform-google-modules/project-factory/google"
#   version = "~> 14.0"
#   count   = var.enable_hub_and_spoke ? 1 : 0

#   random_project_id        = true
#   random_project_id_length = 4
#   default_service_account  = "deprivilege"
#   name                     = "${local.project_prefix}-c-restricted-net-hub"
#   org_id                   = local.org_id
#   billing_account          = local.billing_account
#   folder_id                = google_folder.folder_prod.id

#   activate_apis = [
#     "compute.googleapis.com",
#     "dns.googleapis.com",
#     "servicenetworking.googleapis.com",
#     "logging.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "billingbudgets.googleapis.com"
#   ]

#   labels = {
#     environment       = "production"
#     application_name  = "org-restricted-net-hub"
#     billing_code      = "1234"
#     primary_contact   = "example1"
#     secondary_contact = "example2"
#     business_code     = "abcd"
#     env_code          = "p"
#   }
#   budget_alert_pubsub_topic   = var.project_budget.restricted_net_hub_alert_pubsub_topic
#   budget_alert_spent_percents = var.project_budget.restricted_net_hub_alert_spent_percents
#   budget_amount               = var.project_budget.restricted_net_hub_budget_amount
# }

# resource "google_project_iam_member" "network_sa_restricted" {
#   for_each = toset(var.enable_hub_and_spoke ? local.hub_and_spoke_roles : [])

#   project = module.restricted_network_hub[0].project_id
#   role    = each.key
#   member  = "serviceAccount:${local.networks_step_terraform_service_account_email}"
# }


# # JC Note: These projects are part of the current state and will need to be moved to the correct locations in the repo.

# /******************************************
#   Projects for Forseti
# *****************************************/

# module "nih_ops_forseti" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~> 14.0"
#   random_project_id           = "true"
#   impersonate_service_account = var.terraform_service_account
#   default_service_account     = "deprivilege"
#   name                        = "nih-ops-forseti"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = google_folder.folder_prod.id
#   #skip_gcloud_download        = var.skip_gcloud_download
#   activate_apis               = [
#     "admin.googleapis.com",
#     "appengine.googleapis.com",
#     "bigquery.googleapis.com",
#     "cloudbilling.googleapis.com",
#     "cloudresourcemanager.googleapis.com",
#     "sql-component.googleapis.com",
#     "sqladmin.googleapis.com",
#     "compute.googleapis.com",
#     "iam.googleapis.com",
#     "container.googleapis.com",
#     "servicemanagement.googleapis.com",
#     "serviceusage.googleapis.com",
#     "logging.googleapis.com",
#     "cloudasset.googleapis.com",
#     "storage-api.googleapis.com",
#     "groupssettings.googleapis.com",
#     "oslogin.googleapis.com",
#     "dns.googleapis.com",
#     "servicenetworking.googleapis.com",
#   ]
#   }

# /******************************************
#   Projects for monitoring workspaces
# *****************************************/

# module "org_monitoring_prod" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~> 14.0"
#   random_project_id           = "true"
#   impersonate_service_account = var.terraform_service_account
#   name                        = "nih-ops-monitoring-prod"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = google_folder.folder_prod.id
#   activate_apis               = ["logging.googleapis.com", "monitoring.googleapis.com"]

#   #skip_gcloud_download = var.skip_gcloud_download

#   labels = {
#     environment      = "prod"
#     application_name = "nih-ops-monitoring"
#   }
# }

# module "org_monitoring_dev" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~>14.0"
#   random_project_id           = "true"
#   impersonate_service_account = var.terraform_service_account
#   name                        = "nih-ops-monitoring-dev"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = google_folder.folder_dev.id
#   activate_apis               = ["logging.googleapis.com", "monitoring.googleapis.com"]

#   #skip_gcloud_download = var.skip_gcloud_download

#   labels = {
#     environment      = "dev"
#     application_name = "nih-ops-monitoring"
#   }
# } 

# /******************************************
#   Project for Custom Governance (dev)
# *****************************************/

# module "nih_ops_cgov_dev" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~> 14.0"
#   random_project_id           = "true"
#   impersonate_service_account = var.terraform_service_account
#   default_service_account     = "deprivilege"
#   name                        = "nih-ops-cgov-dev"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = google_folder.folder_dev.id
#   #skip_gcloud_download        = var.skip_gcloud_download
#   activate_apis               = [
#     "cloudresourcemanager.googleapis.com"
#   ]
# }
