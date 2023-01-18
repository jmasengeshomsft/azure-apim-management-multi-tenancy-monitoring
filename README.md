# azure-apim-management-multi-tenancy-monitoring

![image](https://user-images.githubusercontent.com/86074746/211883662-d4c10bc5-4b7a-4b86-be5d-d8ec0a8586a5.png)

## How to Deploy Locally

This demo project is built in Terraform and contains three configurations. 

- **AAD Entities**: To deploy Azure Active Directory entities for tenants. Example: Service Principals, AAD Groups, etc
- **APIM-Monitoring**: To deploy global alerts and action group for the entire APIM. Also, storage account for API reference data is created
- **Tenants**: To deploy tenants (tenant-a and tenant-b)
- **APIS**: To deploy APIs under tenants and products

### Instructions:
- Navigate in the infrastucture directory
- Edit the file named **terraform.tfvars** and set the values as shown below


        apim_rg             = "<apim resource group>"
        apim_region         = "<apim location>"
        apim_name           = "<apim instance nae>"
        admin_email_address = "<default email to sent alerts in dev in conjuction with a logic app>"
        reference_data_storage_account_name = "No existing storage account to hold reference data"


        //tenant-a 
        tenant_a_default_principal_id = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_a_grafana_principal_id = "<A service principal client Id to give accesss to the app insight" //used to access grafana azure monitor data
        tenant_a_rg                   = "<Team A resource group>"
        tenant_a_rg_location          = "<Team A resource group location>"

        //team-b
        tenant_b_default_principal_id = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_b_grafana_principal_id = "<A service principal client Id to give accesss to the app insight" //used to access grafana azure monitor data
        tenant_b_rg                   = "<Team B resource group>"
        tenant_b_rg_location          = "<Team B resource group location>"
        
  - Still in the Infrastructure directory, run 
  
        terraform init
        terraform plan
        terraform apply -auto-approve



# Tenancy Model

The implementation becomes straightforward if we treat API developers as tenants on the APIM platform. **A tenant is a group of users that shares one or many APIs without any access boundary**. A tenant consists of:

-   APIM Product
-   APIM Group
-   APIs
-   APIM Policies
-   Azure Resource Group
-   AAD RBAC
    -   AAD Group
    -   AAD Service Principal Accounts
-   Azure Monitor
    -   Application Insights
    -   Alerts
    -   Action Group
    -   Alerts Processing Rules
    
    
     
    
 <img width="815" alt="image" src="https://user-images.githubusercontent.com/86074746/212952565-164d3a01-4913-41bc-8833-67d91b214737.png">


## Two types of Alerts

In order to minimize the number of alerts, we will use multi-resources and multi-series alerts which can target many resources and dimensions at scale. These alerts are owned by the platform team and are handled by a central action group which plays a broadcast role.

### Tenant alerts:

<img width="800" alt="image" src="https://user-images.githubusercontent.com/86074746/212762994-6c8214f4-c79e-459d-8a73-85d3b81c8d4c.png">

Tenant alert behaviour:

-   Targets one or several APIs belonging to the same tenant.
    -   Requires a tenant action group.
    -   Increases as the number of APIs increases.
    -   Can be tagged and billed to a tenant team easily
    
### Platform alerts

<img width="812" alt="image" src="https://user-images.githubusercontent.com/86074746/212763089-244e4f01-5ace-47ee-8430-a66792e3eb52.png">

Platform alert behaviour:

-   Targets all APIs logs.
    -   Uses the platform action group.
    -   Requires an action that can filter and route alerts to appropriate tenants.
    -   Stays the same as the number of APIs increases.
    -   Requires additional logic to tenant charge back.

## Tenant RBAC Configuration

There are three types of accesses needed for each tenant:

-   **AAD tenant group**: To access Azure Monitor logs in Azure Portal. No individual user is given access to a tenant RG; they must be added to the group.
-   **AAD Service Principal Accounts**: To access Azure Monitor logs programmatically with external systems. An example is Grafana. To query tenant logs programmatically, a tenant service account need:
    -   Reader to the Log Analytics Workspace. Reader role does not allow log data access; its needed to **list** the LAW.
    -   **Log Analytics Reader** to the tenant App insights or the entire tenant RG
-   **AAD Managed Identities**: In case we need to read logs from within Azure. Managed Identities are easier to use than Service Principals.




# Other Recommendations

| \# | Category  | Recommendation                                                                                                                                                           | Benefits                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|----|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Scale     | 1 Application Insights per product. Each product will have multiple APIs and each API can be tagged with a Cloud Role to differentiate their metrics.                    | [Improve the ability to correlate API integrations for troubleshooting](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-map?tabs=net). Reduces the number of App Insights for each product team to manage. Product team manage their own alerts, alert processing rules and ServiceNow routing. Faster to build new APIs and integrate into existing monitoring and troubleshooting runbooks. [Tiered discounts based on data ingestion](https://learn.microsoft.com/en-us/azure/azure-monitor/usage-estimated-costs). |
| 2  | Scale     | Start with default metric alerts that is a baseline for all APIs per product. Teams to build their own alerts for per-API when required.                                 | Lowered alerts and alert processing rules. Flexibility to consolidate alerts across products APIs. For example, set response time for all APIs per product to 20 seconds. It is not per-API alert that’s needed.                                                                                                                                                                                                                                                                                                                     |
| 3  | Security  | RBAC for each Application Insights will be controlled through security groups. Users can be managed through AD and Azure AD based on a customer existing IdP approach. | Improved security, access management and audit. Members are enrolled/de-enrolled through existing Idp processes. Each product can be classified based on risk (e.g., Finance or HR) and access can be restricted based on scope.                                                                                                                                                                                                                                                                                                     |
| 4  | Security  | Use resource-context permissions for Log Analytics Workspace.                                                                                                            | [View logs for only resources](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/manage-access?tabs=portal#access-mode) in all tables that you have access to. Queries in this mode are scoped to only data associated with that resource.                                                                                                                                                                                                                                                                                  |
| 5  | Billing   | Tags based on product team cost center.                                                                                                                                  | Charge back to product teams based on their usage.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 6  | Billing   | Set log analytics level data retention and/or table specific retention to control data retention, cost, and availability.                                                | Reduce cost by setting appropriate data retention requirements. Data retention can be customized per table when required. [Set interactive retention period up to 2 years.](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-archive?tabs=portal-1%2Cportal-2) Total retention period up to 7 years.                                                                                                                                                                                                        |
| 7  | Reporting | Cross-resource queries for reporting.                                                                                                                                    | [Cross-workspace query](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/cross-workspace-query#cross-resource-query-limits) across up to 100 Log Analytics workspaces and Application Insights.                                                                                                                                                                                                                                                                                                                            |
|    |           |                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|    |           |                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|    |           |                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
# Appendix

## Appendix A: Application Insights Design Considerations

### One vs. Many Application Insights

-   For application components that are deployed together. These applications are usually developed by a **single team** and managed by the same set of DevOps/ITOps users.
-   If it makes sense to **aggregate** key performance indicators, such as response durations or failure rates in a dashboard, across all of them by default. You can choose to segment by role name in the metrics explorer.
-   If there's **no need to manage Azure role-based access control differently** between the application components.
-   If you **don't need metrics alert criteria** that are different between the components.
-   If you don't need to manage continuous exports differently between the components.
-   If you **don't need to manage billing/quotas** differently between the components.
-   If it's okay to have an API key have the same access to data from all components. And 10 API keys are sufficient for the needs across all of them.
-   If it's okay to have the same smart detection and work item integration settings across all roles.

### Per-API metrics & logs in shared Application Insights

-   You might need to add custom code to ensure that meaningful values are set into the **Cloud_RoleName** attribute. Without meaningful values set for this attribute, none of the portal experiences will work.
    -   Individual components of the application are determined by their "roleName" or "name" property in recorded telemetry. These components are represented as circles on the map and are referred to as "nodes." HTTP calls between nodes are represented as arrows connecting these nodes, referred to as "connectors" or "edges." The node that makes the call is the "source" of the call, and the receiving node is the "target" of the call.

        ![Screenshot that shows an example of an application map.](media/c91e7b55dfc1ede90e48e4cf2fd19a0f.png)

## Appendix B: Log Analytics Workspace Design Considerations

### One v. Many Workspaces

-   Many customers will create separate workspaces for their **operational and security data for data ownership** and the **extra cost from Microsoft Sentinel**. In some cases, you might be able to save costs by consolidating into a single workspace to qualify for a commitment tier.
-   Each workspace resides in a particular Azure region. You might have **regulatory or compliance requirements** to store data in specific locations.
-   Set **different retention settings for each table** in a workspace. You need a separate workspace if you require different retention settings for different resources that send data to the same tables.

### Cost

-   When ingesting \>= 500GB per day across all resources, use dedicated cluster & set commitment tier.
-   When ingesting \>= 100GB per day across all resources, consider combing to one workspace & set commitment tier.

### RBAC

-   **Resource-context RBAC** - if a user has read access to an Azure resource, they inherit permissions to any of that resource's monitoring data sent to the workspace. This level of access allows users to access information about resources they manage without being granted explicit access to the workspace.
-   **Table level RBAC** - grant or deny access to specific tables in the workspace. In this way, you can implement granular permissions required for specific situations in your environment.

### Dedicated Cluster

-   Customer managed keys, double encryption
-   Cross-workspace queries run faster
-   Availability Zones (East US 2, West US 2)
-   Cost optimization through commitment tier (500, 1000, 2000 or 5000 GB/day)
-   Link up to 1000 workspaces per cluster.
-   Migrate existing Log Analytics Workspaces to a dedicated cluster: When a Log Analytics workspace is linked to a dedicated cluster, new data ingested to the workspace is routed to the new cluster while existing data remains on the existing cluster. If the dedicated cluster is encrypted using customer-managed keys (CMK), only new data is encrypted with the key. The system abstracts this difference, so **you can query the workspace as usual while the system performs cross-cluster queries in the background.**

### Log Ingestion

-   Typical latency to ingest log data is between 20 seconds and 3 minutes.
    -   TimeGenerated (record created at data source)
    -   \_TimeReceived (record received by Azure Monitor ingestion endpoint)
    -   ingestion_time() (record stored in workspace and available for queries)
-   [Log data ingestion time in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-ingestion-time)

### Data Retention / Archive

-   Archiving lets you keep older, less used data in your workspace at a reduced cost.
-   Archived data stays in the same table, alongside the data that's available for interactive queries. When you **set a total retention period that's longer than the interactive retention period**, Log Analytics automatically archives the relevant data immediately at the end of the retention period.
-   If you change the archive settings on a table with existing data, the relevant data in the table is also affected immediately.
-   Interactive Retention period – up to 2 years
-   Total retention period – up to 7 years
-   Archive period – (total retention period **minus** interactive retention period)

![image](https://user-images.githubusercontent.com/86074746/212337118-b9a7571c-b47d-41da-af53-ea7e900499ca.png)

### Restore Logs

-   The restore operation creates the restore table and allocates additional compute resources for querying the restored data using high-performance queries that support full KQL.
-   Restored logs does not have an explicit retention policy. Must be explicitly dismissed through REST API or CLI.
-   Limits
    -   Restore data for a minimum of two days.
    -   Restore up to 60 TB.
    -   Perform up to four restores per workspace per week.
    -   Run up to two restore processes in a workspace concurrently.
    -   Run only one active restore on a specific table at a given time. Executing a second restore on a table that already has an active restore will fail.

## Appendix C: AMPLS Design Considerations

### Limits

-   A virtual network can only connect to **one** AMPLS object. That means the AMPLS object must provide access to all the Azure Monitor resources the virtual network should have access to.
-   An AMPLS object can connect to **300 Log Analytics workspaces** and **1000 Application Insights** components at most.
-   An Azure Monitor resource (Workspace or Application Insights component or Data Collection Endpoint) can connect to **5 AMPLS’** at most.

![image](https://user-images.githubusercontent.com/86074746/212337069-37bdf2c3-5801-4f42-b5cb-0cb8204ffa8d.png)

### Network Design

-   AMPLS requires at least 11 IPs. Smallest supported IPv4 subnet is /27 *(27 allocatable IPs)*.
-   Regional endpoints will require additional IP addresses. For example, Application Insight uses regional endpoints (e.g., eastus-8.in.applicationinsights.azure.com and japanwest-0.in.ai.monitor.azure.com). Each endpoint would be mapped to a private IP address. Careful planning on regional expansion is required to ensure enough space in the subnet.

![image](https://user-images.githubusercontent.com/86074746/212337027-2c83c53a-7e84-47f7-a8b1-145f43e3028e.png)

### DNS

-   Use **a single AMPLS for all networks that share the same DNS**. Due to shared endpoints, it affects not only the network connected to the Private Endpoint but also all other networks sharing the same DNS. When multiple AMPLS are added to the virtual networks using the same DNS, the last update takes precedent.
-   Creating a Private Link affects traffic to **all monitoring resources**, not only the resources in your AMPLS. Effectively, it will cause all query requests as well as ingestion to Application Insights components to go through private IPs. However, it does not mean the Private Link validation applies to all these requests. **Resources not added to the AMPLS can only be reached if the AMPLS access mode is 'Open'** and the target resource accepts traffic from public networks.

### Diagnostic Settings

-   Logs and metrics uploaded to a workspace via Diagnostic Settings go over a secure private Microsoft channel and are not controlled by AMPLS settings.

### Network Isolation

-   **Private Only** - allows the virtual network to reach only Private Link resources (resources in the AMPLS). That's the most secure mode of work, preventing data exfiltration. To achieve that, traffic to Azure Monitor resources out of the AMPLS is blocked.
-   **Open** - allows the virtual network to reach both Private Link resources and resources not in the AMPLS (if they accept traffic from public networks). While the Open access mode doesn't prevent data exfiltration, it still offers the other benefits of Private Links - traffic to Private Link resources is sent through private endpoints, validated, and sent over the Microsoft backbone. The Open mode is useful for a mixed mode of work (accessing some resources publicly and others over a Private Link), or during a gradual onboarding process.

![image](https://user-images.githubusercontent.com/86074746/212336972-80bca119-50c7-435e-aa30-f291f32e2961.png)

### Design with Hub + Spoke

![image](https://user-images.githubusercontent.com/86074746/212336750-f833b621-28bc-4946-94ed-2ed3314c514d.png)


### Azure Resource Manager

-   Configuration changes, including turning AMPLS access settings on or off, are managed by Azure Resource Manager. To control these settings, you should restrict access to resources using the appropriate roles, permissions, network controls, and auditing.
-   Queries sent through the Azure Resource Management (ARM) API can't use Azure Monitor Private Links. These queries can only go through if the **target resource allows queries from public networks**.
