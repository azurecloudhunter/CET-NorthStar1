function Invoke-AzOpsGitPull {
    
    [CmdletBinding()]
    param (
    )

    process {
        Write-Verbose -Message ("Initiating function " + $MyInvocation.MyCommand + " process")

        #iterate through management group and subscription

        Write-Verbose "AzOpsState: $(join-path $env:GITHUB_WORKSPACE -ChildPath $($env:AzOpsState))"
        #Get-AzOpsStateForManagementGroupsAndSubscriptions -AzOpsState $env:AzOpsState -Verbose:$VerbosePreference
        $rootscope = New-AzOpsScope -Scope ($global:AzOpsAzManagementGroup | Where-Object -FilterScript { $_.Id -eq $TenantRootId -and $null -eq $_.ParentId }).Id        
        #Create AzOpsState Structure recursively
        Save-AzOpsManagementGroupChildren -scope ($rootscope.scope)
        Get-AzOpsResourceDefinitionAtScope -scope $rootscope -SkipPolicy:$SkipPolicy -SkipResourceGroup:$SkipResourceGroup

        #if git clean

        if ($env:GITHUB_EVENT_PATH) {        
        
            $event = Get-Content $env:GITHUB_EVENT_PATH | ConvertFrom-Json
        
            Write-Verbose "Event.sender.login: $($event.sender.login)"
            git config -l

            Write-Verbose "--------------------------------------------------------------------------"
            $REPO_URL = $event.repository.clone_url.Replace('https://', 'x-oauth-basic@')
            git config --global user.email $env:REPO_ACCESS_TOKEN_EMAIL
            git config --global user.name $event.sender.login
            git config --global core.pager cat
            git remote set-url origin ("https://$env:REPO_ACCESS_TOKEN" + ":" + $REPO_URL)
            git config -l
            Write-Verbose "--------------------------------------------------------------------------"
        
        }    
        else {
            $event = Get-Content 'tests\AzOpsCURL.json' | ConvertFrom-Json        
        }

        if ($event.client_payload.data.alertContext.AffectedConfigurationItems) {                
            Write-Verbose "We currently only support 'ResourceID' schema for webhooks. The change will not be processed"
        }
    
        if ($event.client_payload.ResourceIDs) {
            Write-Verbose "Using client_payload schema of manual CURL request"
            foreach ($resourceId in $event.client_payload.ResourceIDs) {
                Write-Verbose "Found Notification for $resourceId"       
                $scope = New-AzOpsScope -scope $resourceId            
                if ($scope.scope) {
                    Write-Verbose "AzOpsScope: $scope"
                    Get-AzOpsResourceDefinitionAtScope -scope $scope 
                }
                else {
                    Write-Error "Scope for $resourceId not found."
                }
            }
        }
        else {
            Write-Warning "Unable to process GITHUB_EVENT_PATH : $($env:GITHUB_EVENT_PATH)"
            Write-Warning "$(Get-Content $env:GITHUB_EVENT_PATH)"
        }  

        # Create pull request
        New-AzOpsPullRequest    
    }

}