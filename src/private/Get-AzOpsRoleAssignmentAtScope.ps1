function Get-AzOpsRoleAssignmentAtScope {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        $scope
    )

    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        Write-Verbose -Message " - Processing $scope"
    }

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        Write-Verbose -Message " - Retrieving Role Assignment at Scope $scope"

        $currentRoleAssignmentsInAzure = Get-AzRoleAssignment -Scope $scope.scope | Where-Object -FilterScript { $_.Scope -eq $scope.scope }
        Write-Verbose -Message " - Retrieved Role Assignment at Scope - Total Count $($currentRoleAssignmentsInAzure.count)"

        foreach ($roleassignment in $currentRoleAssignmentsInAzure) {
            Write-Verbose -Message " - Iterating through Role definitition at scope $scope for $($roleassignment.RoleAssignmentId)"
            ConvertTo-AzOpsState -assignment  $roleassignment
        }
    }

    end {
        Write-Verbose -Message " - Finished Processing $scope"
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " end")
    }

}