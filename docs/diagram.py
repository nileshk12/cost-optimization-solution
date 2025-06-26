from diagrams import Diagram, Cluster, Edge, Node
from diagrams.azure.compute import FunctionApps
from diagrams.azure.database import CosmosDb, CacheForRedis
from diagrams.azure.storage import BlobStorage
from diagrams.azure.integration import APIManagement

# Configure diagram attributes
graph_attr = {
    "fontsize": "14",
    "bgcolor": "#F5F5F5",
    "pad": "0.5"
}

with Diagram(
    "Azure Serverless Cost Optimization Architecture",
    show=False,
    outformat="png",
    filename="architecture_diagram",
    graph_attr=graph_attr
):
    # Client Tier
    with Cluster("Client Tier"):
        clients = Node(
            label="Client Requests\n(HTTP/REST)",
            shape="person",
            style="filled",
            fillcolor="#000000"
        )
        apim = APIManagement("API Management\n(Billing API Gateway)")

    # Compute & Storage Tier
    with Cluster("Compute & Storage Tier"):
        billing_api = FunctionApps("Functions: Billing API")
        redis = CacheForRedis("Redis Cache\n(Hot Data)")
        cosmos = CosmosDb("Cosmos DB\n(Recent Records, ≤3 months)")
        blob = BlobStorage("Blob Storage\n(Archive Tier, >3 months)")

    # Background Jobs Tier
    with Cluster("Background Jobs Tier"):
        jobs = FunctionApps("Functions: Archival & Rehydration")

    # Observability Tier
    with Cluster("Observability Tier"):
        monitor = Node(
            label="Monitor, Log Analytics,\nApp Insights\n(KQL Queries & Alerts)",
            shape="box",
            style="filled",
            fillcolor="#800080"
        )

    # Connections
    clients >> Edge(label="GET /billing?id=X") >> apim
    apim >> Edge(label="HTTP Trigger") >> billing_api
    billing_api >> Edge(label="Cache Read/Write") >> redis
    billing_api >> Edge(label="Read Recent Records") >> cosmos
    billing_api >> Edge(label="Read Archived Records") >> blob
    jobs >> Edge(label="Archive/Rehydrate Records") >> cosmos
    jobs >> Edge(label="Write/Read Archive") >> blob
    jobs >> Edge(label="Track Access Counts") >> redis
    billing_api >> Edge(label="Metrics & Logs", style="dashed") >> monitor
    jobs >> Edge(label="Metrics & Logs", style="dashed") >> monitor
