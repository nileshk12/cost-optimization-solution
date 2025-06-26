
## Implementation Details

### Cost Optimization Approach
- **Storage Tiering**: Records older than 3 months are moved to Blob Storage Archive Tier, costing ~$0.0018/GB/month compared to Cosmos DB’s $0.25/GB/month, saving ~90% on storage costs for 600 GB of archived data (2M records × 300 KB).[](https://spot.io/resources/azure-pricing/azure-database-pricing-examples-and-5-ways-to-reduce-your-costs/)[](https://www.cloudoptimo.com/blog/azure-cloud-pricing-explained-a-complete-guide-to-cost-estimation-and-optimization/)
- **Caching**: Redis Cache stores hot records, reducing Cosmos DB read units (RUs) by up to 50% for frequently accessed data.
- **Serverless**: Azure Functions use the Consumption plan, ensuring costs scale with usage.[](https://learn.microsoft.com/en-us/azure/architecture/web-apps/serverless/architectures/web-app)
- **Free Tier**: Cosmos DB free tier (400 RU/s, 5 GB storage) is utilized for small-scale testing.[](https://azure.microsoft.com/en-us/pricing/details/cosmos-db/autoscale-provisioned/)

### API Versioning and Read Routing
- The `X-API-Version` header (default: `1.0`) allows future extensions without breaking clients.
- Read routing logic:
  1. Check Redis Cache for the record.
  2. Fallback to Cosmos DB if not in Redis.
  3. Fallback to Blob Storage Archive Tier if not in Cosmos DB, with rehydration after 5 accesses.

### Rehydration Logic
- A Redis counter (`access:<record_id>`) tracks Blob Storage accesses.
- Records accessed >5 times are rehydrated to Cosmos DB and cached in Redis.

### Observability Setup
- **Azure Monitor/Log Analytics**: Tracks metrics and logs for all components.
- **Application Insights**: Monitors Function performance and dependencies.
- **KQL Queries**:
  - `redis_miss_rate.kql`: Detects when cache miss rate exceeds 80%.
  - `cosmos_spikes.kql`: Identifies Cosmos DB RU consumption spikes (>10,000 RU/h).
  - `blob_fallback_usage.kql`: Monitors excessive Blob Storage fallbacks (>10/h).
- **Alerts**: Configured for high Redis miss rates and Cosmos DB spikes.

### Engineering Decisions
- **Cosmos DB**: Chosen for its low-latency reads and change feed integration with Azure Functions.[](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/serverless-computing-database)
- **Blob Storage Archive Tier**: Selected for its low cost ($0.0018/GB/month) for rarely accessed data.[](https://www.cloudoptimo.com/blog/azure-cloud-pricing-explained-a-complete-guide-to-cost-estimation-and-optimization/)
- **Redis Cache**: Standard tier (C1) balances cost and performance for caching.
- **Terraform**: Modular structure ensures reusability and maintainability.
- **Consumption Plan**: Azure Functions scale dynamically, minimizing costs during low traffic.[](https://learn.microsoft.com/en-us/azure/architecture/web-apps/serverless/architectures/web-app)
- **KQL Queries**: Designed for actionable insights, avoiding generic metrics.

## Benefits
- **Cost Savings**: ~90% reduction in storage costs for archived data, ~50% reduction in read costs via caching.
- **Scalability**: Serverless components auto-scale with demand.
- **Reliability**: No downtime or data loss, with automated archival/rehydration.
- **Observability**: Proactive monitoring with KQL queries and alerts ensures cost and performance optimization.