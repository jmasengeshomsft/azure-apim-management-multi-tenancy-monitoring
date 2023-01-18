# azure-apim-management-multi-tenancy-monitoring
## How to deploy locally

You must have a healthy instance of APIM in order to work this these demos. This project is built in Terraform and contains three configurations.

- **AAD Entities**: To deploy Azure Active Directory entities for tenants. Example: Service Principals, AAD Groups, etc
- **APIM-Monitoring**: To deploy global alerts and action group for the entire APIM. Also, storage account for API reference data is created
- **Tenants**: To deploy tenants (tenant-a and tenant-b)
- **APIS**: To deploy APIs under tenants and products

## Instructions:

### AAD Entities

- Navigate in the **infrastucture/aad-entities** directory
- Create a file name **terraform.tfvars** using the example provided under **infrastructure/terraform.tfvarsexample**. You can also provide values in the variables.tf file in this folder. 
- Run

       terraform init
       terraform plan
       terraform apply -auto-approve


### APIM Monitoring Resources

- Navigate in the **infrastucture/apim-monitoring** directory
- Create a file name **terraform.tfvars** using the example provided under **infrastructure/terraform.tfvarsexample**. You can also provide values in the variables.tf file in this folder. 
- Run

       terraform init
       terraform plan
       terraform apply -auto-approve



### APIM Teams (Tenants or Products)

- Navigate in the **infrastucture/tenants** directory
- Create a file name **terraform.tfvars** using the example provided under **infrastructure/terraform.tfvarsexample**. You can also provide values in the variables.tf file in this folder. 
- Run

       terraform init
       terraform plan
       terraform apply -auto-approve

### APIs

- Navigate in the **infrastucture/aad-entities** directory
- Create a file name **terraform.tfvars** using the example provided under **infrastructure/terraform.tfvarsexample**. You can also provide values in the variables.tf file in this folder. 
- Run

       terraform init
       terraform plan
       terraform apply -auto-approve



An example of variables for each folder. 


        apim_rg                             = "<apim resource group>"
        apim_region                         = "<apim location>"
        apim_name                           = "<apim instance nae>"
        law_name                            = "<name of the log analytics workspace. A new instance is created for you in the apim-monitoring configuration>"
        law_rg                              = "resource group for the log analycs workspace. Defaults to apim resource group"
        admin_email_address                 = "<default email to sent alerts in dev in conjuction with a logic app>"
        reference_data_storage_account_name = "No existing storage account to hold reference data"

        //tenant-a 
        tenant_a_default_principal_id       = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_a_grafana_app_name           = "<name of the service princial used to query app insights from grafana. Its created in the aad-entities configuration"
        tenant_a_default_email_address      = "Action group email for tenant a"
        tenant_a_rg                         = "<Team A resource group>"
        tenant_a_rg_location                = "<Team A resource group location>"

        //team-b
        tenant_b_default_principal_id       = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_a_grafana_app_name           = "<name of the service princial used to query app insights from grafana. Its created in the aad-entities configuration"
        tenant_a_default_email_address      = "Action group email for tenant a"
        tenant_b_rg                         = "<Team B resource group>"
        tenant_b_rg_location                = "<Team B resource group location>"
        

In the APIM resource group, you will get these new resources after a successful deployment (names will vary based your inputs)

<img width="997" alt="image" src="https://user-images.githubusercontent.com/86074746/213020400-9a3dfeed-494d-47db-95b8-24e8f1f50a0b.png">
