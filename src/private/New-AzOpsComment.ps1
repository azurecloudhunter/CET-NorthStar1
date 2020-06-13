function New-AzOpsComment {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        $Changes
    )

    begin {
        $output = @()
        $changes.Split(",") | ForEach-Object {
            $output += ( "``" + $_ + "``")
            $output += "`n"
        }
        $message = "
**AzOps**

Status: _Out of Sync_

Description:

_The repository does not contain the latest Azure Resource Manager state, remediation is required before merging of the Pull Request can complete._

Changes:

$output

Remediation:

- Switch branch

    ```git checkout -b azops/update origin/master```

- Import & execute AzOps cmdlets

    ```Import-Module ./src/AzOps.psd1 -Force```
    ```Initialize-AzOpsRepository -SkipResourceGroup```

- Commit and push updated state

    ```git add azops/```
    ```git status```
    ```git commit -m 'Update azops/'```
    ```git push origin azops/update```

- Create new pull request

- (Admin) Merge pull request

- Re-run status checks

"
    }

    process {
        $params = @{
            Method  = "Post"
            Uri     = ($env:GITHUB_CONTEXT | ConvertFrom-Json -Depth 25).event.pull_request._links.comments.href
            Headers = @{
                "Authorization" = ("Bearer " + $env:GITHUB_TOKEN)
            }
            Body    = (@{
                    "body" = $message
                } | ConvertTo-Json)
        }
        Invoke-RestMethod @params
    }

    end { }

}