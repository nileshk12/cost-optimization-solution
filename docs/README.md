# Cost Optimization Solution for Azure Serverless Application

This repository contains a production-ready solution to optimize costs for an Azure serverless application storing billing records. The architecture leverages Azure Cosmos DB, Azure Blob Storage Archive Tier, Azure Redis Cache, and Azure Functions, with Terraform automation and comprehensive observability.

## Setup Instructions
1. **Clone the Repository**:
   ```
   git clone <repository-url>
   cd cost-optimization-solution





Initialize Terraform:

cd terraform
terraform init
terraform apply



Deploy Functions:





Deploy billing_api.py, archive_writer.py, and rehydration_job.py to the respective Azure Functions using the Azure CLI or portal.



Configure Monitoring:





Import KQL queries from /kql_queries into Log Analytics.



Set up alerts using /alerts/sample_alerts.json.

Running the Solution





API Access: Use the billing-api Function endpoint with X-API-Version: 1.0 header.



Archival Job: Runs daily via a timer trigger to archive records older than 3 months.



Rehydration Job: Runs hourly to check for frequently accessed archived records.

Monitoring





KQL Queries: Monitor Redis miss rates, Cosmos DB RU spikes, and Blob fallbacks.



Alerts: Configured in Azure Monitor for proactive notifications.

