# azure-apim-management-multi-tenancy-monitoring

![image](https://user-images.githubusercontent.com/86074746/211883662-d4c10bc5-4b7a-4b86-be5d-d8ec0a8586a5.png)

## How to Deploy Locally

- Navigate in the infrastucture directory
- Create a file named terraform.tfvars and set the values as show below

        apim_rg             = "<apim resource group>"
        apim_region         = "<apim location>"
        apim_name           = "<apim instance nae>"
        admin_email_address = "<default email to sent alerts in dev in conjuction with a logic app>"

        //tenant-a 
        tenant_a_default_principal_id = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_a_rg                   = "<Team A resource group>"
        tenant_a_rg_location          = "<Team A resource group location>"

        //team-b
        tenant_b_default_principal_id = "<A user, group object or service principal client Id to give accesss to the app insights>"
        tenant_b_rg                   = "<Team B resource group>"
        tenant_b_rg_location          = "<Team B resource group location>"

