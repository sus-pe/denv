# This goes to $env:USERPROFILE\Documents\PowerShell\

Import-Module posh-git
$env:EDITOR = "nvim"
oh-my-posh init pwsh --config ~/.denv_oh_my_posh.omp.json | Invoke-Expression
Import-Module Terminal-Icons

Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -key Tab -Function Complete
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -EditMode window

Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

function denv-git-clone-worktree {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url,

        [Parameter(Position = 1)]
        [string]$TargetDir
    )

    # Derive target folder if not specified
    if (-not $TargetDir) {
        $TargetDir = (Split-Path -Leaf $Url)
    }
    Write-Host "📦 Cloning bare repository from $Url ..."
    git clone --bare $Url $TargetDir

    Push-Location $TargetDir
    Write-Host "⚙️  Configuring full fetch for all branches and tags ..."
    git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
    git config --add remote.origin.fetch '+refs/tags/*:refs/tags/*'

    Write-Host "🔄 Fetching all branches and tags ..."
    git fetch --all --prune --tags

    Write-Host "✅ Done! Repository cloned into '$TargetDir'"
    Pop-Location
}

function Start-CyberRain {
    param(
        [int]$DelayMs = 50
    )

    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray()
    $hostUI = $Host.UI.RawUI

    # detect current terminal size
    $size   = $hostUI.WindowSize
    $Height = $size.Height
    $Columns = $size.Width

    # one vertical stream per column
    $streams = for ($i = 0; $i -lt $Columns; $i++) {
        Get-Random -Min 0 -Max $Height
    }

    $origPos = $hostUI.CursorPosition
    [console]::CursorVisible = $false

    try {
        while ($true) {

            # refresh size in case window is resized mid-run
            $size   = $hostUI.WindowSize
            $Height = $size.Height
            $Columns = $size.Width

            for ($col = 0; $col -lt $Columns; $col++) {

                $c = $chars[(Get-Random -Min 0 -Max $chars.Length)]
                $row = $streams[$col] % $Height

                # leader (bright)
                $hostUI.CursorPosition = @{X=$col; Y=$row}
                Write-Host $c -NoNewline -ForegroundColor White

                # body (dim trail)
                $trailRow = ($row - 1 + $Height) % $Height
                $hostUI.CursorPosition = @{X=$col; Y=$trailRow}
                Write-Host $c -NoNewline -ForegroundColor DarkGreen

                # fade tail (erase further behind)
                $eraseRow = ($row - 3 + $Height) % $Height
                $hostUI.CursorPosition = @{X=$col; Y=$eraseRow}
                Write-Host " " -NoNewline

                $streams[$col]++
            }

            Start-Sleep -Milliseconds $DelayMs
        }
    }
    finally {
        [console]::CursorVisible = $true
        $hostUI.CursorPosition = $origPos
    }
}

function denv-git-add-worktree {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Branch
    )
    git worktree add --checkout --no-detach --guess-remote $Branch $Branch
}

