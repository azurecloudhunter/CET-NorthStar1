function Get-AzOpsGitBranch {

    [CmdletBinding()]
    param ()

    begin {
        $Branch = Invoke-Expression -Command "git branch --all"
        $Current = @()
        $Local = @()
        $Remote = @()
    }

    process {
        switch -Regex ($Branch) {
            "^(?<current>(\*).*)" {
                # Current
                $Current += $matches["current"]
            }
            "^(?<local>(\s|\*).(?!remotes).*)" {
                # Local
                $Local += $matches["local"]
            }
            "^(?<remote>(\s).(remotes).*)" {
                # Remote
                $Remote += $matches["remote"]
            }
        }

        $Branch = [PSCustomObject] @{
            Current = $Current
            Local   = $Local
            Remote  = $Remote
        }
    }

    end {
        return $Branch
    }

}