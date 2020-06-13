function Invoke-AzOpsGitPullRefresh {

    [CmdletBinding()]
    param ()

    begin {}

    process {
        Initialize-AzOpsRepository -InvalidateCache -Rebuild
    }

    end {}

}
