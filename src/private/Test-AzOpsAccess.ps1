<#
.SYNOPSIS
    The cmdlet verifies that required variables are set for the AzOps functions and modules
.DESCRIPTION
    The cmdlet verifies that required variables are set for the AzOps functions and modules
.EXAMPLE
    Test-AzOpsAccess
.INPUTS
    None
.OUTPUTS
    None
#>
function Test-AzOpsAccess {
    [CmdletBinding()]
    [OutputType()]
    param (
    )
    #Variables to verify
    $VariablesToCheck = 'AzOpsState','AzOpsAzManagementGroup','AzOpsSubscriptions'
    #Iterate through each variable and throw error if not set
    foreach ($Variable in $VariablesToCheck) {
       if (-not(Get-Variable -Scope Global -Name $Variable -ErrorAction Ignore)) {
            throw "Required variable $variable is not set. Run Initialize-AzOpsGlobalVariables to initialize variables."
       }
    }
}