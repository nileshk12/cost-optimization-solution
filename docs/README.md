# Testing Guide for Azure Serverless Cost Optimization Solution

This guide provides a comprehensive testing walkthrough for the Azure serverless cost optimization solution. It ensures correct functioning of all components including Azure Cosmos DB, Blob Storage Archive Tier, Redis Cache, Azure Functions, API Management, and observability via Azure Monitor with Log Analytics and Application Insights.

The guide assumes:
- A Linux VM with Python 3.8.10
- MobaXterm on a Windows PC for file transfers
- Infrastructure is **not yet deployed**

---

## 🧰 Prerequisites

### 🔧 Linux VM Setup

Ensure the following tools are installed:

- **Python 3.8.10**
  ```
  python3 --version
  python3 -m pip --version
**Terraform**

```
sudo apt-get update
sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.9.2/terraform_1.9.2_linux_amd64.zip
unzip terraform_1.9.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
```
**Azure CLI**
```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```
**Azure Login**
```
az login
az account set --subscription "<your-subscription-id>"
```
**Project Directory**
Assumes project is located at:
```
~/cost-optimization-solution/
├── terraform/
├── src/
├── kql_queries/
└── docs/
```
### 📦 Python Dependencies
Install required Python packages:
```
python3 -m pip install azure-functions azure-cosmos redis azure-storage-blob
```
### ✅ Testing Steps
**1. 🚀 Deploy the Infrastructure**
```
cd ~/cost-optimization-solution/terraform
terraform init
terraform plan
terraform apply
```
Type yes when prompted to apply the plan.

**Terraform Outputs:**
```
terraform output -json > outputs.json
```
### 2. 🔧 Deploy Azure Functions

Ensure ~/cost-optimization-solution/src includes:

billing_api.py – HTTP-triggered

archive_writer.py – Timer-triggered (for archival)

rehydration_job.py – Timer-triggered (for rehydration)

Update placeholders with actual values from outputs.json.

**Install Azure Function tools:**
```
python3 -m pip install azure-functions-core-tools
```
**Deploy:**
```
cd ~/cost-optimization-solution/src
func azure functionapp publish <function_app_name> --python
```
### 3. 🧪 Test the Billing API
**Insert Test Record:**

```
from azure.cosmos import CosmosClient
client = CosmosClient("<cosmos_db_endpoint>", "<cosmos_db_key>")
container = client.get_database_client("billing").get_container_client("records")
container.create_item({"id": "test1", "data": "sample", "timestamp": "2025-06-26"})
```
**Test via Curl:**
```
curl -H "X-API-Version: 1.0" "https://<function_app_name>.azurewebsites.net/api/billing?id=test1"
```
Expected: {"id": "test1", "data": "sample"}

**Verify Backends:**

**Redis:** redis-cli -h <redis_hostname> -a <redis_key> ping

**Cosmos DB:** Check via Azure Portal

**Blob Storage:** az storage blob list --account-name <name> --container-name billingarchive

### 4. 📦 Test Archival and Rehydration Jobs

**Insert Old Record:**

```
container.create_item({"id": "test2", "data": "old", "timestamp": "2024-12-01"})
```
**Trigger Archival Job:**

**Manually:** Azure Portal → Function → archive_writer → Run

Or wait for the timer

**Verify Blob Storage:**
```
az storage blob list --account-name <storage_account_name> --container-name billingarchive --auth-mode key
```
**Simulate Access & Trigger Rehydration:**
```
redis-cli -h <redis_hostname> -a <redis_key> INCRBY test2_access 10
```
Trigger rehydration_job manually from the Portal.

**Verify Rehydrated Record:**
```
items = list(container.read_all_items())
print([item for item in items if item["id"] == "test2"])
```
### 5. 📊 Validate Monitoring and Alerts
**Use KQL Queries in Log Analytics:**
Example: /kql_queries/redis_miss_rate.kql
```
AzureMetrics
| where ResourceProvider == "MICROSOFT.CACHE"
| where MetricName == "cachemisses"
| summarize MissRate = avg(Total) by bin(TimeGenerated, 1h)
| where MissRate > 0.5
```
**Check Alerts:**

Go to Azure Monitor (in billing-rg)

Simulate high Cosmos DB RU or Redis misses

Verify notifications (email, portal)

### +🧹 Cleanup
To avoid ongoing charges:
```
cd ~/cost-optimization-solution/terraform
terraform destroy
```
Type yes when prompted.

### 📁 Directory Structure
```
cost-optimization-solution/
├── terraform/           # Terraform configs
├── src/                 # Azure Function code
├── kql_queries/         # Monitoring queries
└── docs/                # Documentation (README, Architecture)
```
### 📌 Notes
Ensure environment variables or local.settings.json are correctly populated for Azure Functions.

Terraform state is stored locally—use remote backend (like Azure Storage) for production.

Always validate resource costs before deploying in a live subscription.

