function Invoke-AzOpsGitRefresh {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Pre", "Post")]
        [string]$Mode,
        [Parameter(Mandatory = $true)]
        [string]$BaseBranch,
        [Parameter(Mandatory = $true)]
        [string]$HeadBranch,
        [Parameter(Mandatory = $false)]
        [switch]$SkipResourceGroup,
        [Parameter(Mandatory = $false)]
        [switch]$InvalidateCache
    )

    process {
        switch ($mode) {
            "Pre" {
                Write-Host "Command: git branch"
                Invoke-Expression -Command "git branch" | Out-Null
                Write-Host "-----"

                Write-Host "Command: git fetch"
                Invoke-Expression -Command "git fetch origin" | Out-Null
                Write-Host "-----"

                Write-Host "Command: git checkout"
                Invoke-Expression -Command "git checkout origin/master" | Out-Null
                Write-Host "-----"

                Write-Host "Command: git pull"
                Invoke-Expression -Command "git pull origin master" | Out-Null
                Write-Host "-----"

                Write-Host "Command: Initialize-AzOpsRepository"
                Initialize-AzOpsRepository -InvalidateCache:$InvalidateCache -SkipResourceGroup:$SkipResourceGroup
                Write-Host "-----"

                Write-Host "Command: git add"
                Invoke-Expression -Command "git add --intent-to-add azops/"
                Write-Host "-----"

                Write-Host "Command: git diff"
                $changes = Invoke-Expression -Command "git diff --ignore-space-at-eol --name-only"
                Write-Host "-----"

                Write-Host "Changes:"
                Write-Host $changes
                Write-Host "-----"

                Write-Host "Command: git reset"
                Invoke-Expression -Command "git reset --hard" | Out-Null
                Write-Host "-----"

                Write-Host "Command: git branch"
                $state = Invoke-Expression -Command "git branch --list $HeadBranch"
                Write-Host "-----"

                if ($state) {
                    Write-Host "Command: git checkout"
                    Invoke-Expression -Command "git checkout $HeadBranch" | Out-Null
                    Write-Host "-----"
                }
                else {
                    Write-Host "Command: git checkout"
                    Invoke-Expression -Command "git checkout -b $HeadBranch origin/$HeadBranch" | Out-Null
                    Write-Host "-----"
                }

                if ($changes) {
                    $changes = $changes -join ","
                }

                return $changes
            }
            "Post" {
                Write-Host "Command: git fetch"
                Invoke-Expression -Command "git fetch origin"
                Write-Host "-----"

                Write-Host "Command: git checkout"
                Invoke-Expression -Command "git checkout $HeadBranch"
                Write-Host "-----"

                Write-Host "Command: git pull"
                Invoke-Expression -Command "git pull origin $HeadBranch"
                Write-Host "-----"

                Write-Host "Command: git merge"
                Invoke-Expression -Command "git merge origin/$BaseBranch --no-commit"

                Write-Host "Command: Initialize-AzOpsRepository"
                Initialize-AzOpsRepository -InvalidateCache:$InvalidateCache -SkipResourceGroup:$SkipResourceGroup
                Write-Host "-----"

                Write-Host "Command: git add"
                Invoke-Expression -Command "git add azops/"
                Write-Host "-----"

                Write-Host "Command: git commit"
                Invoke-Expression -Command "git commit -m 'System commit'"
                Write-Host "-----"

                Write-Host "Command: git push"
                Invoke-Expression -Command "git push origin $HeadBranch"
                Write-Host "-----"
            }
        }

    }

}
