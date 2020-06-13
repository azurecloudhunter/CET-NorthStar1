function Register-AzOpsResourceProvider {

    [CmdletBinding()]
    param (
        [Parameter()]
        $filename,
        [Parameter()]
        $scope
    )

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        if ( ($scope.subscription) -and (Get-AzContext).Subscription.Id -ne $scope.subscription) {
            Write-Verbose "Switching Subscription context from $($(Get-AzContext).Subscription.Name) to $scope.subscription "
            Set-AzContext -SubscriptionId $scope.subscription
        }

        $resourceproviders = (get-Content  $filename | ConvertFrom-Json)
        foreach ($resourceprovider  in $resourceproviders | Where-Object -FilterScript { $_.RegistrationState -eq 'Registered' }  ) {
            if ($resourceprovider.ProviderNamespace) {

                Write-Verbose "Registering Provider $($prvoviderfeature.ProviderNamespace)"

                Register-AzResourceProvider -Confirm:$false -pre -ProviderNamespace $resourceprovider.ProviderNamespace
            }

        }
    }

}