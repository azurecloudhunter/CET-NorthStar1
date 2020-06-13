#Bootstrap New Tenant
New-AzTenantDeployment -Name 'Enterprise-Scale-Template' -location 'north europe' -TemplateFile 'examples\Enterprise-Scale-Template-Deployment.json'

#Show Tenant Level Deployment
Get-AzTenantDeployment | Select-Object DeploymentName, ProvisioningState, Timestamp,location |sort-object Timestamp -Descending

#Run Discovery
Initialize-AzOpsRepository -Verbose -SkipResourceGroup

#Commit Changes to AzOps
git add --intent-to-add .\azops

#Stage changes
git add ./azops