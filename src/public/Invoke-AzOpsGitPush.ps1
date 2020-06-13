function Invoke-AzOpsGitPush {

    [CmdletBinding()]
    param ()

    begin {
        $diff = Invoke-AzOpsGitPushRefresh -Operation "Before" -BaseBranch $env:GITHUB_BASE_REF -HeadBranch $env:GITHUB_HEAD_REF
        
        # Validate state
        if ($null -ne $diff) {
            $output = @()
            $diff.Split(",") | ForEach-Object { $output += ( "``" + $_ + "``"); $output += "`n" }
            $params = @{
                Headers = @{
                    "Authorization" = ("Bearer " + $env:GITHUB_TOKEN )
                }
                Body    = (@{
                        "body" = "$(Get-Content -Path "./src/Comments.md" -Raw) `n Changes: `n`n$output"
                    } | ConvertTo-Json)
            }
            Invoke-RestMethod -Method "Get" -Uri $env:INPUT_GITHUB_COMMENTS @params
            exit 1
        }

        Write-Verbose " - Invoke-AzOpsGlobalVariables"
        Initialize-AzOpsGlobalVariables
    }

    process {
        Write-Verbose " - git pull"
        Start-AzOpsNativeExecution {
            git pull
        }

        Write-Verbose " - git rev-parse"
        Start-AzOpsNativeExecution {
            git rev-parse --all
        }
        
        $changeSet = @()
        $deleteSet = @()
        $addModifySet = @()

        $changeSet = Start-AzOpsNativeExecution {
            Write-Verbose " - git diff"
            git diff origin/master --ignore-space-at-eol --name-status
        }

        foreach ($change in $changeSet) {
            $filename = ($change -split "`t")[-1]
            if (($change -split "`t" | Select-Object -first 1) -eq 'D') {
                $deleteSet += $filename
            }
            elseif (($change -split "`t" | Select-Object -first 1) -eq 'A' -or 'M' -or 'R') {
                $addModifySet += $filename
            }
        }

        Write-Verbose " - Change Set - $changeSet"
        Write-Verbose " - Delete Set - $deleteSet"
        Write-Verbose " - Add Set - $addModifySet"

        $addModifySet | Where-Object -FilterScript { $_ -match '/*.subscription.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.providerfeatures.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.resourceproviders.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }
        #$addModifySet | Where-Object -FilterScript { $_ -match '/*.resourcegroup.json$' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.parameters.json$' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }
        #$addmodifyset | Where-Object -filterScript { $_ -match '(?:^|\W).AzState(?:$|\W)' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }
    }

    end {
        Invoke-AzOpsGitPushRefresh -Operation "After" -BaseBranch $env:GITHUB_BASE_REF -HeadBranch $env:GITHUB_HEAD_REF
    }

}