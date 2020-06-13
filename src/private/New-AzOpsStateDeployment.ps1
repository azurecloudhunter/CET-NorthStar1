function New-AzOpsStateDeployment {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $filename
    )

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        if ($filename) {

            Write-Verbose "New-AzOpsStateDeployment for $filename"
            $Item = Get-Item -Path $filename
            $scope = New-AzOpsScope -path $Item
            $templateParametersJson = Get-Content $filename | Convertfrom-json

            if ($scope.type -eq 'subscriptions' -and $filename -match '/*.subscription.json$') {

                Write-Verbose "Upsert subscriptions for $filename"
                $subscription = Get-AzSubscription -SubscriptionName $scope.subscriptionDisplayName -ErrorAction SilentlyContinue

                if ($null -eq $subscription) {
                    Write-Verbose "Creating new subscription"

                    if ((Get-AzEnrollmentAccount)) {
                        if ($global:AzOpsEnrollmentAccountPrincipalName) {
                            Write-Verbose "Querying EnrollmentAccountObjectId for $($global:AzOpsEnrollmentAccountPrincipalName)"
                            $EnrollmentAccountObjectId = (Get-AzEnrollmentAccount | Where-Object -FilterScript { $_.PrincipalName -eq $Global:AzOpsEnrollmentAccountPrincipalName }).ObjectId
                        }
                        else {
                            Write-Verbose "Using first enrollement account"
                            $EnrollmentAccountObjectId = (Get-AzEnrollmentAccount)[0].ObjectId
                        }

                        Write-Verbose "EnrollmentAccountObjectId: $EnrollmentAccountObjectId"

                        $subscription = New-AzSubscription -Name $scope.Name -OfferType $global:offerType -EnrollmentAccountObjectId $EnrollmentAccountObjectId
                        Write-Verbose "Creating new subscription Success!"

                        $ManagementGroupName = $scope.managementgroup
                        Write-Verbose "Assigning subscription to managementgroup $ManagementGroupName"
                        New-AzManagementGroupSubscription -GroupName $ManagementGroupName -SubscriptionId $subscription.SubscriptionId
                    }
                    else {
                        Write-Error "No Azure Enrollment account found for current Azure context"
                        Write-Error "Create new Azure role assignment for service principle used for pipeline: New-AzRoleAssignment -ObjectId <application-Id> -RoleDefinitionName Owner -Scope /providers/Microsoft.Billing/enrollmentAccounts/<object-Id>"
                    }
                }
                else {
                    Write-Verbose "Existing subscription found with ID: $($subscription.Id) Name: $($subscription.Name)"
                    Write-Verbose "Checking if it is in desired management group"
                    $ManagementGroupName = $scope.managementgroup
                    Write-Verbose "Assigning subscription to managementgroup $ManagementGroupName"
                    New-AzManagementGroupSubscription -GroupName $ManagementGroupName -SubscriptionId $subscription.SubscriptionId

                }


            }
            if ($scope.type -eq 'subscriptions' -and $filename -match '/*.providerfeatures.json$') {
                Register-AzOpsProviderFeature -filename $filename -scope $scope
            }
            if ($scope.type -eq 'subscriptions' -and $filename -match '/*.resourceproviders.json$') {

                Register-AzOpsResourceProvider -filename $filename -scope $scope
            }
            if ($filename -match '/*.parameters.json$') {
                Write-Verbose -Message " - Template deployment"

                $MasterTemplateSupportedTypes = @(
                    "Microsoft.Resources/resourceGroups",
                    "Microsoft.Authorization/policyAssignments",
                    "Microsoft.Authorization/policyDefinitions",
                    "Microsoft.Authorization/PolicySetDefinitions",
                    "Microsoft.Authorization/roleDefinitions",
                    "Microsoft.Authorization/roleAssignments",
                    "Microsoft.PolicyInsights/remediations",
                    "Microsoft.ContainerService/ManagedClusters",
                    "Microsoft.KeyVault/vaults",
                    "Microsoft.Network/virtualWans",
                    "Microsoft.Network/virtualHubs",
                    "Microsoft.Network/virtualNetworks",
                    "Microsoft.Network/azureFirewalls",
                    "/providers/Microsoft.Management/managementGroups",
                    "/subscriptions"
                )

                if (($scope.subscription) -and (Get-AzContext).Subscription.Id -ne $scope.subscription) {
                    Write-Verbose "Switching Subscription context from $($(Get-AzContext).Subscription.Name) to $scope.subscription "
                    Set-AzContext -SubscriptionId $scope.subscription
                }

                $templatename = (Get-Item $filename).BaseName.Replace('.parameters', '.json')
                $templatePath = (Join-Path (Get-Item $filename).Directory.FullName -ChildPath $templatename )
                if (Test-Path $templatePath) {
                    $templatePath = (Join-Path (Get-Item $filename).Directory.FullName -ChildPath $templatename )
                }
                else {

                    $effectiveResourceType = ''
                    #Check if generic template is supporting the resource type for the deployment.
                    if((Get-Member -InputObject $templateParametersJson.parameters.input.value -Name ResourceType))
                    {
                        $effectiveResourceType = $templateParametersJson.parameters.input.value.ResourceType
                    }
                    elseif((Get-Member -InputObject $templateParametersJson.parameters.input.value -Name Type))
                    {
                        $effectiveResourceType = $templateParametersJson.parameters.input.value.Type
                    }
                    else {
                        $effectiveResourceType = ''
                    }
                                        
                    if ($effectiveResourceType -and ($MasterTemplateSupportedTypes -Contains $effectiveResourceType)) {
                        $templatePath = $env:AzOpsMasterTemplate
                    }
                }

                if (Test-Path $templatePath) {
                    $deploymentName = (Get-Item $filename).BaseName.replace('.parameters', '').Replace(' ', '_')

                    if ($deploymentName.Length -gt 64) {
                        $deploymentName = $deploymentName.SubString($deploymentName.IndexOf('-') + 1)
                    }
                    Write-Verbose -Message " - Template is $templatename / $templatepath and Deployment Name is $deploymentName"
                    if ($scope.resourcegroup) {
                        Write-Verbose "Validating at template at resource group scope"
                        Test-AzResourceGroupDeployment -ResourceGroupName $scope.resourcegroup -TemplateFile $templatePath -TemplateParameterFile $filename -verbose -OutVariable $templateErrors
                        if (-not $templateErrors) {
                            New-AzResourceGroupDeployment -ResourceGroupName $scope.resourcegroup -TemplateFile $templatePath -TemplateParameterFile $filename -Name $deploymentName -verbose
                        }
                    }
                    elseif ($scope.subscription) {
                        Write-Verbose "Attempting at template at subscription scope with default region $($Global:AzOpsDefaultDeploymentRegion)"
                        New-AzSubscriptionDeployment -Location $Global:AzOpsDefaultDeploymentRegion -TemplateFile $templatePath -TemplateParameterFile $filename -Name $deploymentName -verbose
                    }
                    elseif ($scope.managementgroup) {
                        Write-Verbose "Attempting at template at Management Group scope with default region $($Global:AzOpsDefaultDeploymentRegion)"
                        New-AzManagementGroupDeployment -ManagementGroupId $scope.managementgroup -Name $deploymentName  -Location  $Global:AzOpsDefaultDeploymentRegion -TemplateFile $templatePath -TemplateParameterFile $filename -Verbose
                    }
                    elseif ($scope.type -eq 'root') {
                        Write-Verbose "Attempting at template at Tenant Deployment Group scope with default region $($Global:AzOpsDefaultDeploymentRegion)"
                        New-AzTenantDeployment -Name $deploymentName  -Location  $Global:AzOpsDefaultDeploymentRegion -TemplateFile $templatePath -TemplateParameterFile $filename -Verbose
                    }
                }
            }
            else {
                Write-Verbose "Template Path for $templatePath for $filename not found"
            }
        }
        else {
            Write-Verbose "Filename is null"
        }

    }

}