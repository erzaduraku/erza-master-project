# DCADD Master Project — Exercise 7

Terraform-based AWS infrastructure for a highly available web application. This project provisions a multi-AZ VPC, private EC2 instances behind an Application Load Balancer, and automated deployment via GitHub Actions.

**Author:** Erza Duraku  
**Course:** DCADD Master Project  
**AWS Region:** `eu-central-1`

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│  VPC 10.0.0.0/16                                        │
│                                                         │
│  ┌──────────────── Public Subnets ─────────────────┐   │
│  │  10.0.1.0/24 (1a)  10.0.2.0/24 (1b)  10.0.3.0/24 │   │
│  │       ALB              NAT Gateway               │   │
│  └──────────────────────────────────────────────────┘   │
│                         │                               │
│  ┌──────────────── Private Subnets ────────────────┐   │
│  │  10.0.11.0/24 (1a)  10.0.12.0/24  10.0.13.0/24  │   │
│  │              Auto Scaling Group (EC2)             │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  IGW ── public route table (0.0.0.0/0 → IGW)           │
│  NAT ── private route table (0.0.0.0/0 → NAT GW)      │
└─────────────────────────────────────────────────────────┘
```

| Component | Description |
|-----------|-------------|
| **VPC** | `10.0.0.0/16` with DNS hostnames enabled |
| **Subnets** | 3 public + 3 private across `eu-central-1a/b/c` |
| **ALB** | Internet-facing, HTTP on port 80 |
| **ASG** | 2–6 instances (`t3.micro`), desired capacity 3 |
| **NAT Gateway** | Outbound internet for private subnets (Git clone, updates) |
| **Web App** | Deployed via user data from [group1-master-webapp](https://github.com/erzaduraku/group1-master-webapp) |

---

## Project Structure

```
.
├── providers.tf          # AWS provider, S3 remote backend
├── variables.tf          # Input variables and defaults
├── networking.tf         # VPC, subnets, IGW, NAT, route tables
├── security.tf           # ALB and EC2 security groups
├── compute.tf            # Launch template and Auto Scaling Group
├── data.tf               # Amazon Linux 2023 AMI lookup
├── loadbalancing.tf      # ALB, target group, listener
├── outputs.tf            # ALB DNS name and network outputs
├── user_data.sh          # EC2 bootstrap script
└── .github/workflows/
    └── terraform.yml     # CI/CD pipeline
```

---

## Prerequisites

### AWS (manual setup before first deploy)

1. **S3 bucket** for Terraform state  
   - Bucket: `erza-terraform-state`  
   - Region: `us-east-1` (state backend region)

2. **IAM user** with permissions to manage EC2, VPC, ELB, Auto Scaling, and S3 state access

3. **GitHub repository secrets** (for CI/CD):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

> **Note:** Never commit AWS credentials. Keys belong in environment variables or GitHub Secrets only.

### Local tools

- [Terraform](https://developer.hashicorp.com/terraform/downloads) `>= 1.5.0`
- AWS credentials configured via environment variables or `aws configure`

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/erzaduraku/erza-master-project.git
cd erza-master-project
```

### 2. Configure AWS credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-central-1"
```

### 3. Initialize and plan

```bash
terraform init
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

### 5. Access the application

```bash
terraform output alb_dns_name
```

Open `http://<alb_dns_name>` in your browser.

---

## CI/CD Pipeline

GitHub Actions runs on every push and pull request to `main`:

| Event | Action |
|-------|--------|
| Pull request | `terraform fmt`, `init`, `validate`, `plan` |
| Merge to `main` | `terraform apply -auto-approve` |

Infrastructure changes follow a **branch → PR → review → merge** workflow. Terraform state is stored remotely in S3 and is not committed to Git.

---

## Configuration

Key variables (see `variables.tf` for full list):

| Variable | Default | Description |
|----------|---------|-------------|
| `group_name` | `erza` | Resource name prefix |
| `environment` | `DEV` | Environment tag |
| `project_name` | `DCADD_MASTER` | Project tag |
| `aws_region` | `eu-central-1` | AWS deployment region |
| `instance_type` | `t3.micro` | EC2 instance type |
| `asg_min_size` | `2` | ASG minimum instances |
| `asg_desired_capacity` | `3` | ASG desired instances |
| `asg_max_size` | `6` | ASG maximum instances |

Override via `terraform.tfvars` (gitignored) or environment variables (`TF_VAR_*`).

---

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Public URL of the Application Load Balancer |
| `vpc_id` | VPC identifier |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |

---

## Cleanup

To avoid ongoing AWS charges (especially the NAT Gateway), destroy resources when finished:

```bash
terraform destroy
```

The S3 state bucket and IAM user are not removed automatically.

---

## Security

- EC2 instances run in **private subnets** with no public IPs
- EC2 security group allows HTTP **only from the ALB**
- ALB security group allows HTTP from the internet on port 80
- Default tags applied: `Environment`, `CreatedBy`, `Project`

---

## License

This project was created for academic purposes as part of the DCADD Master Project curriculum.
