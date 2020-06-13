function Register-AzOpsProviderFeature {

    [CmdletBinding()]
    param (
        [Parameter()]
        $filename,
        [Parameter()]
        $scope
    )

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        if ($scope.Subscription -match ".") {
            #Get subscription id from scope (since subscription id is not available for resource groups and resources)
            if (($scope.subscription) -and $CurrentAzContext.Subscription.Id -ne $scop.subscription) {
                Write-Verbose -Message " - Switching Subscription context from $($CurrentAzContext.Subscription.Name)/$($CurrentAzContext.Subscription.Id) to $($scope.subscription)/$($scope.name) "
                try {
                    Set-AzContext -SubscriptionId $scope.subscription -ErrorAction Stop | Out-Null
                }
                catch {
                    throw "Couldn't switch context $_"
                }
            }
        }

        $ProviderFeatures = (get-Content  $filename | ConvertFrom-Json)
        foreach ($ProviderFeature in $ProviderFeatures) {
            if ($ProviderFeature.FeatureName -and $ProviderFeature.ProviderName ) {
                Write-Verbose "Registering Feature $($ProviderFeature.FeatureName) in Provider $($ProviderFeature.ProviderName) namespace"
                Register-AzProviderFeature -Confirm:$false -ProviderNamespace $ProviderFeature.ProviderName -FeatureName $ProviderFeature.FeatureName
            }
        }
    }

}