# BazZ Platform — Complete AWS Production Guide
## Production-Grade Setup (Talabat-Scale Architecture)

---

## Architecture Overview

```
Internet
   │
   ▼
Cloudflare DNS (bazzmarket.com)
   │
   ├── www.bazzmarket.com ──────────────── Vercel (website, no change)
   │
   └── api.bazzmarket.com ──────────────── AWS Application Load Balancer
                                                │
                                     ┌──────────┴──────────┐
                                     │   VPC (eu-west-1)   │
                                     │                     │
                                     │  ┌─────────────────┐│
                                     │  │  ECS Fargate    ││
                                     │  │  (API Tasks)    ││
                                     │  └────────┬────────┘│
                                     │           │         │
                                     │  ┌────────┴────────┐│
                                     │  │  RDS PostgreSQL ││
                                     │  │  (Multi-AZ)     ││
                                     │  └─────────────────┘│
                                     │                     │
                                     │  ┌─────────────────┐│
                                     │  │ ElastiCache     ││
                                     │  │ Redis           ││
                                     │  └─────────────────┘│
                                     └─────────────────────┘

Two Environments:
  • dev  → api-dev.bazzmarket.com  → dev ECS → dev RDS
  • prod → api.bazzmarket.com      → prod ECS → prod RDS (Multi-AZ) + Redis
```

---

## Services Used

| Service | Purpose | Dev | Prod |
|---------|---------|-----|------|
| VPC | Private network | Shared | Shared |
| RDS PostgreSQL | Main database | db.t3.medium | db.r6g.large Multi-AZ |
| ECS Fargate | Run API containers | 0.5vCPU/1GB × 1 | 1vCPU/2GB × 2–10 |
| ALB | Load balancer + HTTPS | ✅ | ✅ |
| ECR | Docker image registry | Shared | Shared |
| ElastiCache Redis | Caching + real-time | ❌ | ✅ |
| Secrets Manager | Store env vars | ✅ | ✅ |
| CloudWatch | Logs + monitoring | ✅ | ✅ |
| GitHub Actions | CI/CD auto deploy | ✅ | ✅ |

**Region**: eu-west-1 (Ireland) — all services available, ~50ms to Jordan/Gulf

---

## PART 1 — AWS Account & IAM Setup

### Step 1.1 — Set your default region

1. Go to https://console.aws.amazon.com
2. In the top-right corner, click the region dropdown
3. Select **Europe (Ireland) — eu-west-1**
4. This must be selected before every step below

### Step 1.2 — Create an IAM user for GitHub Actions (CI/CD)

You need a dedicated user so GitHub can deploy to AWS automatically.

1. Go to **IAM** → https://console.aws.amazon.com/iam
2. Click **Users → Create user**
3. **User name**: `bazz-github-deployer`
4. Do NOT enable AWS Console access → click **Next**
5. **Permissions**: click **Attach policies directly**
6. Search and add ALL of these policies:
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonECS_FullAccess`
   - `SecretsManagerReadWrite`
7. Click **Create user**
8. Click on the new user → **Security credentials** tab
9. Click **Create access key**
10. Select **Application running outside AWS**
11. Click **Create access key**
12. **SAVE BOTH VALUES** — you will not see the secret again:
    - Access key ID: `AKIA...`
    - Secret access key: `xxxx...`

---

## PART 2 — VPC & Networking

This creates a private network with 3 layers: public (internet), app (ECS), data (database).

### Step 2.1 — Create the VPC

1. Go to **VPC** → https://console.aws.amazon.com/vpc
2. Click **Your VPCs → Create VPC**
3. Select **VPC and more** (this creates everything automatically)
4. Fill in:
   - **Name tag auto-generation**: `bazz`
   - **IPv4 CIDR**: `10.0.0.0/16`
   - **Number of Availability Zones**: **2**
   - **Number of public subnets**: **2**
   - **Number of private subnets**: **2**
   - **NAT gateways**: **In 1 AZ** (saves cost vs 2)
   - **VPC endpoints**: None
5. Click **Create VPC**
6. Wait ~2 minutes for everything to be created
7. You will now have:
   - VPC: `bazz-vpc`
   - Public subnets: `bazz-subnet-public1-eu-west-1a`, `bazz-subnet-public2-eu-west-1b`
   - Private subnets: `bazz-subnet-private1-eu-west-1a`, `bazz-subnet-private2-eu-west-1b`
   - Internet Gateway, NAT Gateway, Route Tables

### Step 2.2 — Create extra private subnets for the database

Databases need their own isolated subnet group.

1. Still in **VPC → Subnets → Create subnet**
2. **VPC**: select `bazz-vpc`
3. Click **Add new subnet** twice and create:

   **Subnet 1:**
   - Name: `bazz-db-subnet-1a`
   - Availability Zone: `eu-west-1a`
   - IPv4 CIDR: `10.0.30.0/24`

   **Subnet 2:**
   - Name: `bazz-db-subnet-1b`
   - Availability Zone: `eu-west-1b`
   - IPv4 CIDR: `10.0.31.0/24`

4. Click **Create subnet**

### Step 2.3 — Create Security Groups

Security groups are firewalls that control who can talk to what.

Go to **VPC → Security groups → Create security group** and create each one below:

---

**Security Group 1: ALB (Load Balancer)**
- **Name**: `bazz-alb-sg`
- **VPC**: `bazz-vpc`
- **Inbound rules**:
  - Type: HTTP | Port: 80 | Source: 0.0.0.0/0
  - Type: HTTPS | Port: 443 | Source: 0.0.0.0/0
- **Outbound rules**: Keep default (All traffic)
- Click **Create security group**

---

**Security Group 2: ECS Tasks (API)**
- **Name**: `bazz-ecs-sg`
- **VPC**: `bazz-vpc`
- **Inbound rules**:
  - Type: Custom TCP | Port: 3000 | Source: select `bazz-alb-sg` (the ALB security group above)
- **Outbound rules**: Keep default (All traffic, so ECS can reach RDS and internet)
- Click **Create security group**

---

**Security Group 3: RDS Database**
- **Name**: `bazz-rds-sg`
- **VPC**: `bazz-vpc`
- **Inbound rules**:
  - Type: PostgreSQL | Port: 5432 | Source: select `bazz-ecs-sg`
- **Outbound rules**: Keep default
- Click **Create security group**

---

**Security Group 4: Redis**
- **Name**: `bazz-redis-sg`
- **VPC**: `bazz-vpc`
- **Inbound rules**:
  - Type: Custom TCP | Port: 6379 | Source: select `bazz-ecs-sg`
- **Outbound rules**: Keep default
- Click **Create security group**

---

## PART 3 — Elastic Container Registry (ECR)

ECR is where your Docker images are stored. One registry, two image tags.

### Step 3.1 — Create ECR repository

1. Go to **ECR** → https://console.aws.amazon.com/ecr
2. Click **Create repository**
3. Fill in:
   - **Visibility**: Private
   - **Repository name**: `bazz-api`
   - **Image tag mutability**: Mutable
   - **Image scan on push**: Enable ✅
4. Click **Create repository**
5. **Copy the repository URI** — looks like:
   `123456789.dkr.ecr.eu-west-1.amazonaws.com/bazz-api`
   
   **Save this** — you need it in GitHub Actions and ECS.

---

## PART 4 — AWS Secrets Manager

Store all environment variables securely. Never put them in code.

### Step 4.1 — Create secrets for Dev environment

1. Go to **Secrets Manager** → https://console.aws.amazon.com/secretsmanager
2. Click **Store a new secret**
3. **Secret type**: Other type of secret
4. Click **+ Add row** for each variable below. Fill in all of them:

| Key | Value |
|-----|-------|
| `DATABASE_URL` | `postgresql://bazz:PASSWORD@DEV_RDS_ENDPOINT:5432/bazz_dev` (fill in after RDS is created) |
| `NODE_ENV` | `development` |
| `PORT` | `3000` |
| `JWT_SECRET` | generate a long random string: `openssl rand -base64 64` |
| `CORS_ORIGINS` | `https://bazzmarket.com,https://www.bazzmarket.com,https://bazz-admin.vercel.app,http://localhost:3001` |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | paste your full Firebase JSON |

5. Click **Next**
6. **Secret name**: `bazz/dev`
7. Click **Next → Next → Store**

### Step 4.2 — Create secrets for Production environment

Repeat exactly the same steps, but:
- Use the PROD RDS endpoint for `DATABASE_URL`
- Set `NODE_ENV` to `production`
- Set `CORS_ORIGINS` to only `https://bazzmarket.com,https://www.bazzmarket.com,https://bazz-admin.vercel.app`
- Add `REDIS_URL` once Redis is created (later)
- **Secret name**: `bazz/prod`

> **Note**: After creating RDS in Part 5, come back and update the `DATABASE_URL` values in both secrets.

---

## PART 5 — RDS PostgreSQL Databases

### Step 5.1 — Create the DB Subnet Group (used by both databases)

1. Go to **RDS** → https://console.aws.amazon.com/rds
2. Click **Subnet groups → Create DB subnet group**
3. Fill in:
   - **Name**: `bazz-db-subnet-group`
   - **Description**: BazZ database subnet group
   - **VPC**: `bazz-vpc`
4. **Add subnets**:
   - Availability zone: `eu-west-1a` → Subnet: `bazz-db-subnet-1a`
   - Availability zone: `eu-west-1b` → Subnet: `bazz-db-subnet-1b`
5. Click **Create**

---

### Step 5.2 — Create Dev Database

1. Go to **RDS → Create database**
2. **Choose a database creation method**: Standard create
3. **Engine**: PostgreSQL
4. **Engine version**: PostgreSQL 16 (latest)
5. **Templates**: Dev/Test
6. Fill in:
   - **DB instance identifier**: `bazz-dev-db`
   - **Master username**: `bazz`
   - **Master password**: create a strong password → **save it**
   - **Confirm password**: same
7. **Instance configuration**:
   - **DB instance class**: Burstable classes → `db.t3.medium`
8. **Storage**:
   - **Storage type**: gp3
   - **Allocated storage**: 20 GB
   - **Enable storage autoscaling**: ✅ Yes, max 100 GB
9. **Availability & durability**:
   - **Multi-AZ deployment**: Do not create a standby instance (dev doesn't need it)
10. **Connectivity**:
    - **Compute resource**: Don't connect to an EC2 compute resource
    - **VPC**: `bazz-vpc`
    - **DB subnet group**: `bazz-db-subnet-group`
    - **Public access**: No
    - **VPC security group**: Remove default → Add `bazz-rds-sg`
    - **Availability Zone**: eu-west-1a
    - **Port**: 5432
11. **Database authentication**: Password authentication
12. **Additional configuration** (expand it):
    - **Initial database name**: `bazz_dev`
    - **Backup retention**: 7 days
    - **Enable deletion protection**: OFF (for dev)
13. Click **Create database** — takes ~5 minutes

**After it's created:**
- Click the database → **Connectivity & security** tab
- Copy the **Endpoint** (looks like `bazz-dev-db.xxxxxxx.eu-west-1.rds.amazonaws.com`)
- Go back to **Secrets Manager → bazz/dev** → update `DATABASE_URL`:
  `postgresql://bazz:YOUR_PASSWORD@bazz-dev-db.xxxxxxx.eu-west-1.rds.amazonaws.com:5432/bazz_dev`

---

### Step 5.3 — Create Production Database

1. Go to **RDS → Create database** again
2. **Choose a database creation method**: Standard create
3. **Engine**: PostgreSQL 16
4. **Templates**: **Production**
5. Fill in:
   - **DB instance identifier**: `bazz-prod-db`
   - **Master username**: `bazz`
   - **Master password**: different strong password → **save it**
6. **Instance configuration**:
   - **DB instance class**: Memory optimized → `db.r6g.large` (2 vCPU, 13 GB — handles thousands of users)
7. **Storage**:
   - **Storage type**: gp3
   - **Allocated storage**: 100 GB
   - **Enable storage autoscaling**: ✅ Yes, max 500 GB
8. **Availability & durability**:
   - **Multi-AZ deployment**: **Create a standby instance** ✅ (auto-failover if one AZ goes down)
9. **Connectivity**: Same as dev:
   - **VPC**: `bazz-vpc`
   - **DB subnet group**: `bazz-db-subnet-group`
   - **Public access**: No
   - **VPC security group**: `bazz-rds-sg`
   - **Port**: 5432
10. **Additional configuration**:
    - **Initial database name**: `bazz_prod`
    - **Backup retention**: 30 days
    - **Enable automated backups**: ✅
    - **Backup window**: 03:00 UTC (quiet time)
    - **Enable Performance Insights**: ✅ (helps you see slow queries)
    - **Enable Enhanced Monitoring**: ✅ (60 second interval)
    - **Enable deletion protection**: ✅ ON (protects prod from accidental delete)
11. Click **Create database** — takes ~10 minutes

**After it's created:**
- Copy the **Writer endpoint**
- Update `DATABASE_URL` in **Secrets Manager → bazz/prod**:
  `postgresql://bazz:YOUR_PASSWORD@bazz-prod-db.xxxxxxx.eu-west-1.rds.amazonaws.com:5432/bazz_prod`

---

## PART 6 — ElastiCache Redis (Production Only)

Redis is used for caching, rate limiting at scale, and future real-time features.

### Step 6.1 — Create Redis subnet group

1. Go to **ElastiCache** → https://console.aws.amazon.com/elasticache
2. Click **Subnet groups → Create subnet group**
3. Fill in:
   - **Name**: `bazz-redis-subnet-group`
   - **VPC ID**: `bazz-vpc`
   - **Availability zones**: eu-west-1a and eu-west-1b
   - **Subnets**: select the private subnets for each AZ
4. Click **Create**

### Step 6.2 — Create Redis cluster

1. Click **Redis caches → Create Redis cache**
2. **Creation method**: Easy create → **No** (use custom)
3. **Cluster mode**: Disabled (simpler, enough for your scale)
4. Fill in:
   - **Name**: `bazz-redis`
   - **Engine version**: 7.x (latest)
   - **Port**: 6379
5. **Node type**: `cache.r6g.medium` (or `cache.t4g.medium` for lower cost start)
6. **Number of replicas**: 1 (so there's a standby in another AZ)
7. **Subnet group**: `bazz-redis-subnet-group`
8. **Security groups**: `bazz-redis-sg`
9. Click **Create**

**After it's created:**
- Copy the **Primary endpoint** (looks like `bazz-redis.xxxxx.ng.0001.euw1.cache.amazonaws.com:6379`)
- Go to **Secrets Manager → bazz/prod** → add `REDIS_URL`:
  `redis://bazz-redis.xxxxx.ng.0001.euw1.cache.amazonaws.com:6379`

---

## PART 7 — ECS Fargate Setup

ECS runs your API containers. Think of it as Railway but you control everything.

### Step 7.1 — Create ECS Cluster

1. Go to **ECS** → https://console.aws.amazon.com/ecs
2. Click **Clusters → Create cluster**
3. Fill in:
   - **Cluster name**: `bazz-cluster`
   - **Infrastructure**: AWS Fargate ✅ (serverless containers)
4. Click **Create**

---

### Step 7.2 — Create IAM Role for ECS Tasks

ECS containers need permission to read your secrets.

1. Go to **IAM → Roles → Create role**
2. **Trusted entity type**: AWS service
3. **Use case**: Elastic Container Service → **Elastic Container Service Task**
4. Click **Next**
5. Search and add:
   - `SecretsManagerReadWrite`
   - `CloudWatchLogsFullAccess`
   - `AmazonECSTaskExecutionRolePolicy`
6. Click **Next**
7. **Role name**: `bazz-ecs-task-role`
8. Click **Create role**

---

### Step 7.3 — Create CloudWatch Log Groups

1. Go to **CloudWatch → Log groups → Create log group**
2. Create two log groups:
   - **Name**: `/ecs/bazz-dev` → **Retention**: 30 days
   - **Name**: `/ecs/bazz-prod` → **Retention**: 90 days

---

### Step 7.4 — Create Task Definition for Dev

A task definition is the blueprint for your container.

1. Go to **ECS → Task definitions → Create new task definition**
2. **Task definition family**: `bazz-api-dev`
3. **Launch type**: AWS Fargate
4. **OS/Architecture**: Linux/X86_64
5. **Task size**:
   - **CPU**: 0.5 vCPU
   - **Memory**: 1 GB
6. **Task role**: `bazz-ecs-task-role`
7. **Task execution role**: `bazz-ecs-task-role`
8. **Container** section — click **Add container**:
   - **Name**: `bazz-api`
   - **Image URI**: `123456789.dkr.ecr.eu-west-1.amazonaws.com/bazz-api:dev`
     (your ECR URI from Part 3 + `:dev` tag)
   - **Port mappings**: Container port `3000`, Protocol `TCP`
   - **Environment variables** — Click **Add from Secrets Manager**:
     - Select your secret `bazz/dev`
     - This will inject all key-value pairs automatically
   - **Logging**:
     - Log driver: `awslogs`
     - awslogs-group: `/ecs/bazz-dev`
     - awslogs-region: `eu-west-1`
     - awslogs-stream-prefix: `api`
9. **Health check**:
   - Command: `CMD-SHELL,curl -f http://localhost:3000/health || exit 1`
   - Interval: 30, Timeout: 5, Retries: 3, Start period: 60
10. Click **Create**

### Step 7.5 — Create Task Definition for Production

Repeat Step 7.4 with these differences:
- **Task definition family**: `bazz-api-prod`
- **CPU**: 1 vCPU
- **Memory**: 2 GB
- **Image URI**: `123456789.dkr.ecr.eu-west-1.amazonaws.com/bazz-api:latest`
- **Secrets**: link to `bazz/prod`
- **Log group**: `/ecs/bazz-prod`

---

## PART 8 — Application Load Balancer (ALB)

The ALB routes HTTPS traffic to your ECS containers.

### Step 8.1 — Request SSL Certificate

Before creating ALBs, you need HTTPS certificates.

1. Go to **Certificate Manager (ACM)** → https://console.aws.amazon.com/acm
2. Click **Request a certificate → Request a public certificate**
3. **Fully qualified domain names** — add both:
   - `api.bazzmarket.com`
   - `api-dev.bazzmarket.com`
4. **Validation method**: DNS validation
5. Click **Request**
6. Click into the certificate → **Create records in Route 53** — BUT since you use Cloudflare, you need to do this manually:
   - Copy the **CNAME name** and **CNAME value** shown for each domain
   - Go to **Cloudflare → bazzmarket.com → DNS**
   - Add CNAME record: Name = the CNAME name (remove `.bazzmarket.com` at end) | Target = CNAME value | **Proxy: OFF (grey cloud)**
   - Do this for both `api` and `api-dev`
7. Wait 5–15 minutes for AWS to validate → status changes to **Issued**

---

### Step 8.2 — Create Dev ALB

1. Go to **EC2 → Load Balancers → Create load balancer**
2. Select **Application Load Balancer → Create**
3. Fill in:
   - **Name**: `bazz-dev-alb`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4
4. **Network mapping**:
   - **VPC**: `bazz-vpc`
   - **Mappings**: Check BOTH AZs, select the **public** subnets for each
5. **Security groups**: Remove default → add `bazz-alb-sg`
6. **Listeners and routing**:
   - **Listener 1**: Protocol HTTP, Port 80
   - **Listener 2**: Protocol HTTPS, Port 443 → you'll add a certificate next
7. **Default SSL/TLS certificate**: select the certificate you created in 8.1
8. Click **Create load balancer**

**Create Target Group for Dev:**
1. During ALB creation, click **Create target group** for the HTTPS listener:
   - **Target type**: IP addresses
   - **Name**: `bazz-dev-tg`
   - **Protocol**: HTTP (ALB handles SSL termination)
   - **Port**: 3000
   - **VPC**: `bazz-vpc`
   - **Health check path**: `/health`
   - **Healthy threshold**: 2
   - **Unhealthy threshold**: 3
   - **Interval**: 30 seconds
   - Click **Create target group**
2. Back in the ALB creation, select this target group for the HTTPS listener

**Add HTTP → HTTPS redirect:**
1. After ALB is created, go to its **Listeners** tab
2. Click the HTTP:80 listener → **Edit**
3. Add action: **Redirect to HTTPS** (port 443, 301 permanent)

---

### Step 8.3 — Create Production ALB

Repeat Step 8.2 with these differences:
- **Name**: `bazz-prod-alb`
- **Target group name**: `bazz-prod-tg`
- Same security group, same VPC public subnets

---

## PART 9 — ECS Services

A service keeps your containers running and connects them to the load balancer.

### Step 9.1 — Create Dev ECS Service

1. Go to **ECS → Clusters → bazz-cluster → Services → Create**
2. **Launch type**: Fargate
3. **Task definition**: `bazz-api-dev` (latest revision)
4. **Service name**: `bazz-dev-service`
5. **Desired tasks**: `1`
6. **Networking**:
   - **VPC**: `bazz-vpc`
   - **Subnets**: select the **PRIVATE** subnets (bazz-subnet-private1, bazz-subnet-private2)
   - **Security groups**: `bazz-ecs-sg`
   - **Public IP**: **DISABLED** (private subnet, no public IP needed)
7. **Load balancing**:
   - **Load balancer type**: Application Load Balancer
   - **Load balancer**: `bazz-dev-alb`
   - **Container**: `bazz-api:3000`
   - **Listener**: 443:HTTPS
   - **Target group**: `bazz-dev-tg`
8. **Service auto scaling**: OFF for dev
9. Click **Create**

---

### Step 9.2 — Create Production ECS Service

Repeat with:
- **Task definition**: `bazz-api-prod`
- **Service name**: `bazz-prod-service`
- **Desired tasks**: `2` (always 2 running for HA)
- Same networking (private subnets, bazz-ecs-sg)
- **Load balancer**: `bazz-prod-alb`
- **Target group**: `bazz-prod-tg`

**Enable Auto Scaling for Production:**
1. After service is created → **Service → Update**
2. **Service auto scaling**: Turn on
3. **Minimum tasks**: 2
4. **Maximum tasks**: 10
5. **Policy type**: Target tracking
6. **Metric**: ECS service average CPU utilization
7. **Target value**: 70% (scale up when CPU hits 70%)
8. Click **Update**

---

## PART 10 — DNS Setup (Cloudflare)

### Step 10.1 — Point your API domains to ALBs

1. Go to **EC2 → Load Balancers**
2. Click `bazz-dev-alb` → copy the **DNS name** (looks like `bazz-dev-alb-123.eu-west-1.elb.amazonaws.com`)
3. Click `bazz-prod-alb` → copy its **DNS name**

4. Go to **Cloudflare → bazzmarket.com → DNS → Add record**:

   **Dev API:**
   - Type: CNAME
   - Name: `api-dev`
   - Target: `bazz-dev-alb-xxx.eu-west-1.elb.amazonaws.com`
   - Proxy: **OFF (grey cloud)** ← important, same as main site

   **Production API:**
   - Type: CNAME
   - Name: `api`
   - Target: `bazz-prod-alb-xxx.eu-west-1.elb.amazonaws.com`
   - Proxy: **OFF (grey cloud)**

5. Save both. DNS propagates in ~5 minutes.

---

## PART 11 — GitHub Actions CI/CD

This automatically deploys when you push code. Push to `develop` → deploys to dev. Push to `main` → deploys to production.

### Step 11.1 — Add GitHub Secrets

1. Go to your GitHub repo → **Settings → Secrets and variables → Actions**
2. Click **New repository secret** for each:

| Secret Name | Value |
|-------------|-------|
| `AWS_ACCESS_KEY_ID` | The access key from Part 1.2 |
| `AWS_SECRET_ACCESS_KEY` | The secret key from Part 1.2 |
| `AWS_REGION` | `eu-west-1` |
| `ECR_REPOSITORY` | `123456789.dkr.ecr.eu-west-1.amazonaws.com/bazz-api` |

### Step 11.2 — Create the workflow files

These files are created in your repo at `.github/workflows/`.
(See the workflow files in your repo — they are created automatically by this guide.)

---

## PART 12 — Verify Everything Works

### Step 12.1 — Test Dev environment

```bash
# Should return {"status":"ok","timestamp":"..."}
curl https://api-dev.bazzmarket.com/health

# Test order tracking
curl https://api-dev.bazzmarket.com/api/orders/track/BZ-0001
```

### Step 12.2 — Test Production environment

```bash
curl https://api.bazzmarket.com/health
```

### Step 12.3 — Update Vercel

1. Go to Vercel → your web project → **Settings → Environment Variables**
2. Update `VITE_API_URL` to `https://api.bazzmarket.com`
3. Redeploy

---

## Cost Summary (eu-west-1)

| Service | Dev/month | Prod/month |
|---------|-----------|------------|
| RDS db.t3.medium | ~$30 | — |
| RDS db.r6g.large Multi-AZ | — | ~$230 |
| ECS Fargate (1 task 0.5vCPU) | ~$8 | — |
| ECS Fargate (2 tasks 1vCPU) | — | ~$45 |
| ALB | ~$18 | ~$18 |
| ElastiCache Redis | — | ~$80 |
| NAT Gateway | ~$35 | shared |
| Data transfer | ~$5 | ~$20 |
| **Total** | **~$96/mo** | **~$393/mo** |

> As you grow to millions of users (Talabat-scale), you scale up ECS tasks and RDS instance size. The architecture supports this without any redesign.

---

## What Happens When You Deploy

```
Developer pushes code
        │
        ▼
GitHub Actions triggers
        │
        ├── Build Docker image
        │
        ├── Push to ECR (bazz-api:dev or :latest)
        │
        └── Update ECS service
                │
                ▼
        ECS pulls new image
                │
                ▼
        New container starts → health check passes
                │
                ▼
        Old container stopped (zero downtime rolling deploy)
                │
                ▼
        API updated ✅
```
