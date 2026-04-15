# Claude Code Skills - Uninstall Script (Windows)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Skills - Uninstall" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$CLAUDE_DIR = Join-Path $env:USERPROFILE ".claude"

Write-Host "WARNING: This will remove all symlinks to skills, agents, and rules." -ForegroundColor Yellow
Write-Host "The original repository files will NOT be deleted." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Uninstall cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Removing symlinks..." -ForegroundColor Cyan

$removedCount = 0

# Remove skill symlinks
Get-ChildItem (Join-Path $CLAUDE_DIR "skills") -Attributes ReparsePoint | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "  ✓ Removed skill: $($_.Name)" -ForegroundColor Green
    $removedCount++
}

# Remove agent symlinks
Get-ChildItem (Join-Path $CLAUDE_DIR "agents") -Attributes ReparsePoint | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "  ✓ Removed agent: $($_.Name)" -ForegroundColor Green
    $removedCount++
}

# Remove rule symlinks
Get-ChildItem (Join-Path $CLAUDE_DIR "rules") -Attributes ReparsePoint | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "  ✓ Removed rule: $($_.Name)" -ForegroundColor Green
    $removedCount++
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Uninstall Complete!" -ForegroundColor Green
Write-Host "Removed $removedCount symlinks" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To reinstall, run: .\setup.ps1" -ForegroundColor Blue
