function Invoke-AzOpsGitPushRefresh {

    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Operation,
        [Parameter(Mandatory = $true)]
        [string]$BaseBranch,
        [Parameter(Mandatory = $true)]
        [string]$HeadBranch
    )

    begin {}

    process {
        switch ($operation) {
            "Before" {
                Write-Verbose " - git fetch"
                Start-AzOpsNativeExecution {
                    git fetch origin --quiet
                }
                
                Write-Verbose " - git checkout"
                Start-AzOpsNativeExecution {
                    git checkout origin/master --quiet
                }
        
                Write-Verbose " - git pull"
                Start-AzOpsNativeExecution {
                    git pull origin master --quiet
                }
        
                Write-Verbose " - Initialize-AzOpsRepository"
                Initialize-AzOpsRepository -InvalidateCache -SkipResourceGroup -Rebuild

                Write-Verbose " - git add"
                Start-AzOpsNativeExecution {
                    git add --intent-to-add azops/
                } | Out-Null 
                
                Write-Verbose " - git diff"
                $Diff = Start-AzOpsNativeExecution { 
                    git diff --ignore-space-at-eol --name-only
                }
                
                Write-Verbose " - git reset"
                Start-AzOpsNativeExecution {
                    git reset --hard --quiet
                }
                
                Write-Verbose " - git branch"
                $Branch = Start-AzOpsNativeExecution {
                    git branch --list $HeadBranch
                }
        
                if ($Branch) {
                    Write-Verbose " - git checkout"
                    Start-AzOpsNativeExecution {
                        git checkout $HeadBranch --quiet
                    }
                }
                else {
                    Write-Verbose " - git checkout -b"
                    Start-AzOpsNativeExecution {
                        git checkout -b $HeadBranch origin/$HeadBranch --quiet
                    }
                }
        
                if ($Diff) {
                    $Diff = $Diff -join ","
                }

                return $Diff
            }
            "After" {
                Write-Verbose " - git fetch origin"
                Start-AzOpsNativeExecution {
                    git fetch origin
                }

                Write-Verbose " - git checkout"
                Start-AzOpsNativeExecution {
                    git checkout $HeadBranch
                }

                Write-Verbose " - git pull"
                Start-AzOpsNativeExecution {
                    git pull origin $HeadBranch
                }

                Write-Verbose " - git merge"
                Start-AzOpsNativeExecution {
                    git merge origin/$BaseBranch --no-commit
                }
                
                Write-Verbose " - Initialize-AzOpsRepository"
                Initialize-AzOpsRepository -InvalidateCache -Rebuild
        
                Write-Verbose " - git add"
                Start-AzOpsNativeExecution {
                    git add azops/
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
                        git push origin $HeadBranch
                    }
                }
            }
        }
    }

    end {}

}
