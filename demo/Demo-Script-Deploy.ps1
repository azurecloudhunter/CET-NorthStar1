
$upstreamRepoURL = 'https://github.com/Azure/CET-NorthStar.git'
#Ensure Correct Git Folder
git remote -v 

if ((git remote get-url upstream) -ne $upstreamRepoURL){
    git remote remove upstream
    git remote add upstream $upstreamRepoURL
}

#Git Checkout master
git checkout master

#Update master from upstream
git pull upstream master -X theirs -f

#Remove azops folder
rm .\azops -Confirm:$false -Recurse -Force -ErrorAction:SilentlyContinue

#Import module
Import-Module .\src\AzOps.psd1 -force
Get-ChildItem -Path .\src -Include *.ps1 -Recurse | ForEach-Object { .$_.FullName }

#Clean up Tenant Level Deployments
Get-AzTenantDeployment | Foreach-Object -Parallel { Remove-AzTenantDeployment -Name $_.DeploymentName -Confirm:$false}

#Clean up Management Group
if (Get-AzManagementGroup -GroupName 'ES' -ErrorAction SilentlyContinue) {
    Write-Verbose "Cleaning up 'ES' Management Group"
    Remove-AzOpsManagementGroup -groupName  'ES' -Verbose
}
if (Get-AzManagementGroup -GroupName 'Northstar-IAB' -ErrorAction SilentlyContinue) {
    Write-Verbose "Cleaning up 'Northstar-IAB' Management Group"
    Remove-AzOpsManagementGroup -groupName  'Northstar-IAB' -Verbose
}

#Bootstrap New Tenant
New-AzTenantDeployment -Name 'Enterprise-Scale-Template' -location 'north europe' -TemplateFile 'examples\Enterprise-Scale-Template-Deployment.json'

#Show Tenant Level Deployment
Get-AzTenantDeployment | Select-Object DeploymentName, ProvisioningState, Timestamp,location | Sort-Object Timestamp -Descending

