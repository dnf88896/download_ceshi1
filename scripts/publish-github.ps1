param(
    [string]$Owner = "dnf88896",
    [string]$Repo = "voices38-pragmata",
    [string]$Tag = "v1.0.0",
    [string]$RepoDir = "E:\pragmata\PRAGMATA-voices38\voices38-pragmata-pages",
    [string]$PartsDir = "E:\pragmata\PRAGMATA-voices38\voices38-pragmata-pages\release-parts"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI 'gh' is not installed or is not on PATH. Install it first, then rerun this script."
}

Push-Location $RepoDir
try {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoDir ".git"))) {
        git init
        git branch -M main
    }

    git add .gitignore README.md index.html RELEASE_NOTES.md scripts
    git commit -m "Add GitHub Pages download site" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No new page changes to commit, continuing..."
    }

    if (-not (git remote get-url origin 2>$null)) {
        gh repo create "$Owner/$Repo" --public --source "$RepoDir" --remote origin --push
    }
    else {
        git push -u origin main
    }

    try {
        gh api -X POST "repos/$Owner/$Repo/pages" -F "source[branch]=main" -F "source[path]=/" | Out-Null
    }
    catch {
        gh api -X PUT "repos/$Owner/$Repo/pages" -F "source[branch]=main" -F "source[path]=/" | Out-Null
    }

    $assets = @()
    $manifest = Join-Path $PartsDir "SHA256SUMS.txt"
    if (Test-Path -LiteralPath $manifest) {
        $assets += $manifest
    }
    $assets += Get-ChildItem -LiteralPath $PartsDir -Filter "*.iso.part*" | Sort-Object Name | ForEach-Object { $_.FullName }

    if ($assets.Count -eq 0) {
        throw "No release assets found in $PartsDir. Run scripts\split-iso.ps1 first."
    }

    if (gh release view $Tag --repo "$Owner/$Repo" 1>$null 2>$null) {
        gh release upload $Tag --repo "$Owner/$Repo" @assets --clobber
    }
    else {
        gh release create $Tag @assets --repo "$Owner/$Repo" --title "voices38-pragmata.iso" --notes-file RELEASE_NOTES.md
    }

    Write-Host "Page:    https://$Owner.github.io/$Repo/"
    Write-Host "Release: https://github.com/$Owner/$Repo/releases/tag/$Tag"
}
finally {
    Pop-Location
}

