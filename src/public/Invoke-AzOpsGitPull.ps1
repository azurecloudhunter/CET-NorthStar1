function Invoke-AzOpsGitPull {
    
    [CmdletBinding()]
    param ()

    begin {}

    process {
        Write-Verbose " - git fetch"
        Start-AzOpsNativeExecution {
            git fetch
        }

        Write-Verbose " - git fetch"
        $branch = Start-AzOpsNativeExecution {
            git branch --remote | grep 'origin/system'
        } -IgnoreExitcode

        if ($branch) {
            Write-Verbose " - git checkout"
            Start-AzOpsNativeExecution {
                git checkout system
            } 
        }
        else {
            Write-Verbose " - git checkout -b"
            Start-AzOpsNativeExecution {
                git checkout -b system
            }
        }

        Write-Verbose " - Invoke-AzOpsGitPullRefresh"
        Invoke-AzOpsGitPullRefresh

        Write-Verbose " - git add"
        Start-AzOpsNativeExecution {
            git add 'azops/'
        }

        Write-Verbose " - git status"
        $status = Start-AzOpsNativeExecution {
            git status --short
        }

        if ($status) {
            Write-Verbose " - git commit"
            Start-AzOpsNativeExecution {
                git commit -m 'System commit'
            }

            Write-Verbose " - git push"
            Start-AzOpsNativeExecution {
                git push origin system
            }

            Write-Verbose " - Invoke-RestMethod - Get"
            $params = @{
                Uri     = ($env:GITHUB_API_URL + "/repos/" + $env:GITHUB_REPOSITORY + "/labels")
                Headers = @{
                    "Authorization" = ("Bearer " + $env:GITHUB_TOKEN)
                }
            }
            $response = Invoke-RestMethod -Method "Get" @params | Where-Object -FilterScript { $_.name -like "system" }

            if (!$response) {
                Write-Verbose " - Invoke-RestMethod - Create"
                $params = @{
                    Uri     = ($env:GITHUB_API_URL + "/repos/" + $env:GITHUB_REPOSITORY + "/labels")
                    Headers = @{
                        "Authorization" = ("Bearer " + $env:GITHUB_TOKEN)
                        "Content-Type"  = "application/json"
                    }
                    Body    = (@{
                            "name"        = "system"
                            "description" = "[AzOps] Do not delete"
                            "color"       = "db9436"
                        } | ConvertTo-Json)
                }
                $response = Invoke-RestMethod -Method "Post" @params
            }

            Write-Verbose " - Invoke-RestMethod - Get"
            $params = @{
                Uri     = ($env:GITHUB_API_URL + "/repos/" + $env:GITHUB_REPOSITORY + "/pulls?state=open&head=system")
                Headers = @{
                    "Authorization" = ("Bearer " + $env:GITHUB_TOKEN)
                }
            }
            $response = Invoke-RestMethod -Method "Get" @params

            if (!$response) {
                Write-Verbose " - gh pr create"
                Start-AzOpsNativeExecution {
                    gh pr create --title $env:INPUT_GITHUB_PULL_REQUEST --body "Auto-generated PR triggered by Azure Resource Manager `nNew or modified resources discovered in Azure" --label "system"
                }
            }
        }
    }

    end {}

}