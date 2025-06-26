# Architecture Diagram for Azure Serverless Cost Optimization Solution

This document provides a text-based (ASCII) architecture diagram for the Azure serverless cost optimization solution, illustrating the components and their interactions.

The diagram highlights:
- Azure Cosmos DB for recent records
- Azure Blob Storage Archive Tier for older records
- Azure Redis Cache for caching
- Azure Functions for APIs and background jobs
- Azure API Management for client requests
- Azure Monitor with Log Analytics and Application Insights for observability

## ASCII Architecture Diagram
```
+------------------------+
| Client Requests |
| [HTTP/REST API Calls] |
+-----------+------------+
|
v
+-----------+------------+
| Azure API Management |
| - Routes to Billing API|
| - Enforces X-API-Version|
+-----------+------------+
|
v
+-----------+------------+
| Azure Functions: |
| Billing API |
| - Read: Redis → Cosmos |
| → Blob fallback |
+-----+-------+----------+
| |
| |
v v
+-----+--+ +--+----------------+ +-------------------------+
| Redis | | Azure Cosmos DB | | Azure Blob Storage |
| Cache | | - ≤ 3 months | | - > 3 months |
| - Hot | | - Recent records | | - Archive Tier |
| - Fast | +------------------+ +-------------------------+
+--------+ ^ |
| v
| +-----------+------------+
+------------| Azure Functions: |
| Archival & Rehydration |
| - Archive >3m to Blob |
| - Rehydrate to Cosmos |
+-----------+------------+
|
v
+-----------+------------+
| Azure Monitor + |
| Log Analytics + |
| App Insights |
| - KQL: Redis/Cosmos/Blob|
| - Alerts on anomalies |
+------------------------+
```
## Diagram Explanation

- **Client Requests**: External clients send HTTP/REST requests to retrieve billing records.
- **Azure API Management (APIM)**: Routes requests to the Billing API and enforces the `X-API-Version` header.
- **Azure Functions: Billing API**: Handles read requests through Redis → Cosmos DB → Blob fallback.
- **Azure Redis Cache**: Caches hot records for low-latency access and reduced Cosmos costs.
- **Azure Cosmos DB**: Stores recent (≤3 months) records.
- **Azure Blob Storage (Archive Tier)**: Stores older records (>3 months) for cost efficiency.
- **Azure Functions: Archival/Rehydration Jobs**:
  - **Archival Job**: Moves old records from Cosmos DB to Blob.
  - **Rehydration Job**: Brings back frequently accessed records from Blob to Cosmos DB.
- **Azure Monitor, Log Analytics, Application Insights**: Observability using KQL for cache misses, Cosmos RU spikes, and Blob access; includes alerts.

## Generating the Graphical Diagram

### Using `diagram.py` (Python script)

1. Install dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y python3-pip graphviz
   python3 -m pip install diagrams==0.23.4

2. Run the script:

```bash
cd ~/cost-optimization-solution/docs
python3 diagram.py
