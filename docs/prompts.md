
The main prompt used to generate the code using chat LLM tools 
```
You are a senior DevOps consultant.
I am working on a cost optimization challenge where the current architecture is built on Azure serverless services. A serverless app stores billing records in Azure Cosmos DB. Each record is around 300 KB, and the DB holds over 2 million records. Records older than 3 months are rarely accessed but cannot be deleted. The app is read-heavy and uses the same API interface for clients.
The problem is:
- Cosmos DB is getting very expensive due to large storage and read operations.
- I want to reduce costs without changing the API, without data loss, and without causing downtime.
I want you to design and generate a complete, production-ready solution that:
1. Uses Azure Blob Storage Archive Tier to store old records
2. Uses Azure Redis Cache as a hybrid caching layer for recent & hot data
3. Implements internal API versioning strategy to enable intelligent read routing (Cosmos → Redis → Blob fallback)
4. Includes rehydration logic to promote archived records back into Cosmos if accessed frequently again
5. Is fully automated using Terraform with modular structure
6. Has a professional observability setup:
   - Azure Monitor, Log Analytics, App Insights
   - KQL queries to detect high Redis miss rate, Cosmos DB spikes, Blob fallback usage
   - Sample alerts and diagnostics
7. Provides clean pseudocode for the read API logic and archival jobs
8. Delivers:
   - A GitHub-style folder structure with all the files (main.tf, archive_writer.py, billing_api.py, README, etc.)
   - A professional architecture diagram (text or ASCII okay)
   - A 1-page PDF summary that explains the architecture and benefits
9. Focuses on real engineering decisions, not generic cloud ideas
Optional but appreciated:
- Sample dashboards or alerts
- Scripts for setting up observability resources in Terraform
Make the output complete and ready for submission as a consulting deliverable. Structure the content into folders and files.
```
