# In the Name of God

# Project Overview

This project is a prototype implementation that contains **10 main parts**. It is intended as a working model and has room for improvement — especially in error handling and concurrency in some stages.

## Purpose

The main goals of this project are:

* Provision **3 virtual machines** for the infrastructure.
* Prepare required prerequisites for creating a Kubernetes cluster.
* Create a Kubernetes cluster and provide storage for OpenEBS.
* Deploy a **PostgreSQL cluster** with at least **3 replicas** using the CloudNativePG operator.
* Install an **Elastic Stack** (single-node in this project) together with **Filebeat** to collect infrastructure logs and **Kibana** for visualization.
* Implement automated log filters to separate logs per deployment (filters created dynamically by Ansible).
* Create a small dashboard that shows **pod counts** and **total log counts**.
* Deploy a **Prometheus** stack for cluster monitoring.
* Implement alerting through a **Telegram bot**.

## Notes about this version

* This is a **prototype** (proof-of-concept).
* Significant improvements are possible and recommended (better error control, concurrency handling, and robustness).

---

# What Ansible Covers

Ansible playbooks and roles in this project automate the following tasks:

1. **Prerequisite checks** on hosts: ensures minimum versions are present (Ansible **>= 2.18**, Python **>= 3.13**).
2. **Terraform orchestration** to provision the virtual machines used by the project.
3. Prepare and export **dynamic variables** that later roles consume.
4. **Transfer files** needed to create the cluster (this project uses **kubeKey**). Cluster configuration files are rendered from templates.
5. Verify kernel/tools prerequisites such as **conntrack** and **socat** before cluster bootstrapping.
6. Bootstrap the Kubernetes cluster and install required Helm charts (for example **openebs** and the database operator).
7. Deploy the **PostgreSQL** cluster (minimum 3 nodes) via the operator.
8. Transfer files required to install the **Elastic Stack**.
9. Install the **Elastic Stack**, then **Filebeat** and **Kibana**.
10. Create datasets and **dynamic filters** for all deployments; create a concise dashboard (pods and log counts).
11. Install and configure the **Prometheus** stack for monitoring.
12. Configure **alerting** using a Telegram bot.

---

# High-level Flow

1. Run Terraform to create 3 VMs.
2. Use Ansible to check prerequisites and copy cluster setup files (kubeKey, templates, manifests).
3. Ensure kernel modules/tools (conntrack, socat) are present.
4. Initialize the Kubernetes cluster and install storage (OpenEBS) and the DB operator.
5. Deploy the PostgreSQL cluster (3+ replicas).
6. Install Elastic + Filebeat + Kibana and push necessary configuration.
7. Create filters and a compact dashboard for log separation and overview.
8. Install Prometheus and configure monitoring.
9. Set up Telegram alerts.

---

# Important Requirements & Notes

* **vCenter must be reachable** during VM provisioning — otherwise the run will fail.
* If the script (playbook) has already been executed once, the VM creation step **will not run again** unless you remove the Terraform state files. To force VM reprovisioning, delete the files in:

```
./roles/02-terraform/files/terraform_output/
```

* This implementation assumes a single-node Elastic stack for simplicity (can be extended to multi-node for production).

---

# Quick File / Role Responsibilities (concise)

* `roles/02-terraform/` — Terraform files and state output (VM creation).
* `roles/*` — Ansible roles that perform checks, file transfers, templating, Helm installs, and service configuration.
* `files/` and `templates/` — kubeKey tarball, cluster manifests, Helm values, and other artifacts transferred to targets.

---

# How to Use (very brief)

1. Ensure you have network access to vCenter and the required credentials.
2. Confirm Ansible and Python versions on controller: `ansible --version` (>= 2.18) and `python --version` (>= 3.13).
3. Run the main playbook. If you want to recreate VMs, delete Terraform states in `./roles/02-terraform/files/terraform_output/` first.

---

If you want, I can also produce a `README.md` with badges, commands and a minimal example of `ansible-playbook` invocation — tell me what else to include.

