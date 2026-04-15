# Claude Code Skills - Automated Setup Script (Windows)
# This script creates symbolic links for skills, agents, and rules

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Skills - Automated Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Warning: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Symbolic links may fail. Consider:" -ForegroundColor Yellow
    Write-Host "1. Running PowerShell as Administrator" -ForegroundColor Yellow
    Write-Host "2. Enabling Developer Mode (Settings > For Developers)" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CLAUDE_DIR = Join-Path $env:USERPROFILE ".claude"

Write-Host "Repository: $SCRIPT_DIR" -ForegroundColor Green
Write-Host "Claude Code: $CLAUDE_DIR" -ForegroundColor Green
Write-Host ""

# Create Claude directories if not exist
$directories = @("skills", "agents", "rules", "hooks")
foreach ($dir in $directories) {
    $path = Join-Path $CLAUDE_DIR $dir
    if (-not (Test-Path $path)) {
        Write-Host "Creating directory: $path" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# Function to create symbolic link
function New-SymlinkSafe {
    param(
        [string]$Target,
        [string]$Link
    )
    
    # Remove existing link/file if exists
    if (Test-Path $Link) {
        Remove-Item $Link -Force -Recurse
    }
    
    try {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
        Write-Host "  ✓ $(Split-Path $Link -Leaf)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ✗ $(Split-Path $Link -Leaf) - $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Install skills
Write-Host "Installing Skills..." -ForegroundColor Cyan
$skillsDir = Join-Path $SCRIPT_DIR "skills"
$successCount = 0
$failCount = 0

Get-ChildItem $skillsDir -Directory | ForEach-Object {
    $target = $_.FullName
    $link = Join-Path (Join-Path $CLAUDE_DIR "skills") $_.Name
    
    if (New-SymlinkSafe -Target $target -Link $link) {
        $successCount++
    } else {
        $failCount++
    }
}

Write-Host ""

# Install agents
Write-Host "Installing Agents..." -ForegroundColor Cyan
$agentsDir = Join-Path $SCRIPT_DIR "agents"

Get-ChildItem $agentsDir -File | ForEach-Object {
    $target = $_.FullName
    $link = Join-Path (Join-Path $CLAUDE_DIR "agents") $_.Name
    
    if (New-SymlinkSafe -Target $target -Link $link) {
        $successCount++
    } else {
        $failCount++
    }
}

Write-Host ""

# Install rules
Write-Host "Installing Rules..." -ForegroundColor Cyan
$rulesDir = Join-Path $SCRIPT_DIR "rules"

Get-ChildItem $rulesDir -File | ForEach-Object {
    $target = $_.FullName
    $link = Join-Path (Join-Path $CLAUDE_DIR "rules") $_.Name
    
    if (New-SymlinkSafe -Target $target -Link $link) {
        $successCount++
    } else {
        $failCount++
    }
}

Write-Host ""

# Install hooks
Write-Host "Installing Hooks..." -ForegroundColor Cyan
$hooksDir = Join-Path $SCRIPT_DIR "hooks"

if (Test-Path $hooksDir) {
    Get-ChildItem $hooksDir -File -Filter "*.sh" | ForEach-Object {
        $target = $_.FullName
        $link = Join-Path (Join-Path $CLAUDE_DIR "hooks") $_.Name

        if (New-SymlinkSafe -Target $target -Link $link) {
            $successCount++
        } else {
            $failCount++
        }
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "Success: $successCount | Failed: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check Python dependencies
$pythonSkills = @("product-planner", "llm-app-planner")
$hasPython = Get-Command python -ErrorAction SilentlyContinue

if ($hasPython) {
    Write-Host "Checking Python dependencies..." -ForegroundColor Cyan
    
    foreach ($skill in $pythonSkills) {
        $reqFile = Join-Path $skillsDir "$skill\requirements.txt"
        if (Test-Path $reqFile) {
            Write-Host "  - $skill: Found requirements.txt" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "To install Python dependencies:" -ForegroundColor Yellow
    Write-Host "  cd ~/.claude/skills/product-planner && pip install -r requirements.txt" -ForegroundColor Gray
    Write-Host "  cd ~/.claude/skills/llm-app-planner && pip install -r requirements.txt" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "Python not found. Skipping dependency check." -ForegroundColor Yellow
    Write-Host ""
}

# Verify installation
Write-Host "Verifying installation..." -ForegroundColor Cyan
$installedSkills = Get-ChildItem (Join-Path $CLAUDE_DIR "skills") | Measure-Object
Write-Host "  ✓ $($installedSkills.Count) skills installed" -ForegroundColor Green

$installedAgents = Get-ChildItem (Join-Path $CLAUDE_DIR "agents") | Measure-Object
Write-Host "  ✓ $($installedAgents.Count) agents installed" -ForegroundColor Green

$installedRules = Get-ChildItem (Join-Path $CLAUDE_DIR "rules") | Measure-Object
Write-Host "  ✓ $($installedRules.Count) rules installed" -ForegroundColor Green

$installedHooks = Get-ChildItem (Join-Path $CLAUDE_DIR "hooks") -ErrorAction SilentlyContinue | Measure-Object
Write-Host "  ✓ $($installedHooks.Count) hooks installed" -ForegroundColor Green

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Restart Claude Code CLI" -ForegroundColor White
Write-Host "2. Test a skill: /product-planner ""AI education platform""" -ForegroundColor White
Write-Host "3. See all skills: ls ~/.claude/skills" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: https://github.com/hyunseung1119/My_ClaudeCode_Skill" -ForegroundColor Blue
Write-Host ""
