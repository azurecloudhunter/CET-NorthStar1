function Invoke-AzOpsGitPush {

    [CmdletBinding()]
    param ()

    begin {
        $changeSet = @()
        $deleteSet = @()
        $addModifySet = @()
    }

    process {
        Write-Host "Command: git branch"
        Invoke-Expression -Command "git branch"

        Write-Host "Command: git pull"
        Invoke-Expression -Command "git pull"

        Write-Host "Command: git branch"
        Invoke-Expression -Command "git branch"

        Write-Host "Command: git remote -v"
        Invoke-Expression -Command "git remote -v"

        Write-Host "Command: git rev-parse --all"
        Invoke-Expression -Command "git rev-parse --all"

        Write-Host "Command: git diff origin/master --ignore-space-at-eol --name-status"
        $changeSet += (Invoke-Expression -Command "git diff origin/master --ignore-space-at-eol --name-status")

        Write-Host "ChangeSet: $($changeSet.count)"

        # Note: Filename is split by tabs not spaces coming out of Git

        foreach ($change in $changeSet) {
            $filename = ($change -split "`t")[-1]

            Write-Verbose "Git DiffSet: $filename"
            if (($change -split "`t" | Select-Object -first 1) -eq 'D') {
                $deleteSet += $filename
            }
            elseif (($change -split "`t" | Select-Object -first 1) -eq 'A' -or 'M' -or 'R') {
                $addModifySet += $filename
            }
        }

        Write-Host "DeleteSet: $($deleteSet.count)"
        Write-Host "AddModifySet: $($addModifySet.count)"

        Write-Host "Processing *.subscription.json"
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.subscription.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }

        Write-Host "Processing *.providerfeatures.json"
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.providerfeatures.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }

        Write-Host "Processing *.resourceproviders.json"
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.resourceproviders.json$' } | Sort-Object -Property $_ | ForEach-Object { New-AzOpsStateDeployment -filename $_ }

        # Write-Verbose "Processing *.resourcegroup.json"
        # $addModifySet | Where-Object -FilterScript { $_ -match '/*.resourcegroup.json$' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }

        Write-Host "Processing *.parameters.json"
        $addModifySet | Where-Object -FilterScript { $_ -match '/*.parameters.json$' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }

        <#
        # All files with .paraemters are same. no special condition needed for AzState
        Write-Verbose "Processing .AzState Changes"
        $addmodifyset | Where-Object -filterScript { $_ -match '(?:^|\W).AzState(?:$|\W)' } | Sort-Object -Property $_ | Foreach-Object { New-AzOpsStateDeployment -filename $_ }
        #>
    }

}