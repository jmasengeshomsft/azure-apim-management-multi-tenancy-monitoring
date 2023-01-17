# azure-apim-management-multi-tenancy-monitoring

## How to Deploy Locally

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

In the APIM resource group, you will get these new resources after a successful deployment (names will vary based your inputs)

<img width="997" alt="image" src="https://user-images.githubusercontent.com/86074746/213020400-9a3dfeed-494d-47db-95b8-24e8f1f50a0b.png">
