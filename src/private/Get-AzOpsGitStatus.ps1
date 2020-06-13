function Get-AzOpsGitStatus {

    [CmdletBinding()]
    param ()

    begin {
        $Status = Invoke-Expression -Command "git -c core.quotepath=false status --short"
        $Directory = Join-Path -Path (Get-Location).Path -ChildPath ".git"

        $IndexAdded = @()
        $IndexModified = @()
        $IndexDeleted = @()
        $IndexUnmerged = @()
        $WorkingAdded = @()
        $WorkingModified = @()
        $WorkingDeleted = @()
        $WorkingUnmerged = @()
        $WorkingUntracked = @()
    }

    process {
        switch -Regex ($Status) {
            '^(?<index>[^#])(?<working>.) (?<path1>.*?)(?: -> (?<path2>.*))?$' {
                switch ($matches['index']) {
                    'A' { $IndexAdded += $matches['path1']; break }
                    'R' { $IndexModified += $matches['path1']; break }
                    'C' { $IndexModified += $matches['path1']; break }
                    'D' { $IndexDeleted += $matches['path1']; break }
                    'U' { $IndexUnmerged += $matches['path1']; break }
                }
                switch ($matches['working']) {
                    'A' { $WorkingAdded += $matches['path1']; break }
                    'M' { $WorkingModified += $matches['path1']; break }
                    'D' { $WorkingDeleted += $matches['path1']; break }
                    'U' { $WorkingUnmerged += $matches['path1']; break }
                    '?' { $WorkingUntracked += $matches['path1']; break }
                }
            }
        }
        $Index = [PSCustomObject] @{
            Added    = ($IndexAdded -join ",")
            Modified = ($IndexModified -join ",")
            Deleted  = ($IndexDeleted -join ",")
            Unmerged = ($IndexUnmerged -join ",")
        }
        $Working = [PSCustomObject] @{
            Added     = ($WorkingAdded -join ",")
            Modified  = ($WorkingModified -join ",")
            Deleted   = ($WorkingDeleted -join ",")
            Unmerged  = ($WorkingUnmerged -join ",")
            Untracked = ($WorkingUntracked -join ",")
        }
        $Status = [PSCustomObject] @{
            Directory    = $directory
            Repository   = (Split-Path (Split-Path $directory -Parent) -Leaf)
            Branch       = (Get-AzOpsGitBranch).Current
            Upstream     = $null
            Index        = $Index
            HasIndex     = $null
            Working      = $Working
            HasWorking   = $null
            Untracked    = $Working.Untracked
            HasUntracked = $null
        }
    }

    end { 
        return $Status
    }

}