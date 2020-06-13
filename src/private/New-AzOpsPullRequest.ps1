function New-AzOpsPullRequest {

    [CmdletBinding()]
    param ()

    begin {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " begin")
        #Check if git exists
        $GitExists = git
        if (-not($GitExists)) {
            Write-Error -Message "Git is not installed on the machine" ; break
        }
    }

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")
        if ("$(git status --porcelain)") {
            Write-Verbose "Git Working Tree is dirty"

            Write-Verbose "Git Branch -a"
            git branch -a

            Write-Verbose "git pull"
            git pull

            Write-Verbose "Git Branch -a"
            git branch -a

            Write-Verbose "Git remote -v"
            git remote -v

            Write-Verbose "(git status --porcelain)"
            (git status --porcelain)


            $changeset = (git status --porcelain)
            Write-Verbose "#######################################################################################"
            $changeset
            Write-Verbose "#######################################################################################"
            foreach ($change in $changeset) {

                $filename = ($change.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries ) | Select-Object -Last 1)
                Write-Verbose "Processing $filename"

                if ((Get-Item $filename).FullName -like "$((get-item $global:AzOpsState).FullName)/*") {
                    $scope = New-AzOpsScope -path ((get-item ($change.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries ) | Select-Object -Last 1)).FullName)
                    if ($scope.statepath) {

                        $remote = ""
                        if ($scope.managementgroup) {
                            $remote += $scope.managementgroup
                        }
                        if ($scope.subscription) {
                            $remote += "-$($scope.subscription)"
                        }
                        if ($scope.resourcegroup) {
                            $remote += "-$($scope.resourcegroup)"
                        }

                        Write-Verbose "Checking if Remote Branch exist? $remote"

                        if (git ls-remote --exit-code --quiet --heads origin $remote) {
                            Write-Verbose "Remote Branch Do Exist"

                            Write-Verbose "Adding current changes"
                            git add -A

                            Write-Verbose "Stash current changes"
                            git stash

                            Write-Verbose "Checkout $remote branch"
                            git checkout $("origin/$remote")

                            Write-Verbose "Git branch -v"
                            git branch -v

                            Write-Verbose "Git pull from $remote branch"
                            git pull

                            Write-Verbose "Stash apply"
                            git stash apply

                            Write-Verbose "Git status before pop apply"
                            git status

                            Write-Verbose "Git Reset"
                            git reset

                            Write-Verbose "Git status after pop apply "
                            git status

                        }
                        else {
                            Write-Verbose "Remote Branch $remote Do not exist"
                            git checkout -b $remote origin/master
                            git push --set-upstream origin $remote
                        }

                        Write-Verbose "Git status before"
                        git status

                        Write-Verbose "Git add $filename"
                        git add $filename

                        Write-Verbose "Git status"
                        git status

                        #To Do add formatting and context from event payload
                        Write-Verbose "Git commit -m Automated PR from Build"
                        git commit -m "Automated PR from Build"

                        Write-Verbose "Git status"
                        git status

                        Write-Verbose "Git push origin HEAD:$remote"
                        git push origin HEAD:$remote

                        Write-Verbose "gh pr create"
                        gh pr create --repo $env:GITHUB_REPOSITORY --base master --title "Automated Pull Request" --body "Updated AzOps files because a change in the Azure environment was detected:  \n$($changeset -join '\n')"
                    }
                    else {
                        Write-Error "Unable to determine scope for $filename"
                    }
                }
                else {
                    Write-Verbose "Not in AzOps State folder $filename"
                }


            }
        }
        else {
            Write-Verbose "Git Working Tree Clean. Nothing to Commit"
        }

    }

}