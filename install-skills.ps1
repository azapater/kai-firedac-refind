<#
.SYNOPSIS
    Copies the pack's skills into a location your agent reads.

.DESCRIPTION
    Skills are plain folders containing a SKILL.md. Installing one means putting
    that folder where the agent looks. This script does the copy and prints where
    the files went.

    .agents/skills is the cross-client convention: Kai, Codex CLI and Gemini CLI
    all read it. Claude Code uses .claude/skills, Gemini CLI also accepts
    .gemini/skills. Anything else: check that agent's documentation and pass the
    destination with -Path.

.PARAMETER Scope
    User    install for every project (default)
    Project install into one project folder, given by -Path

.PARAMETER Agent
    agents (default), claude, gemini, or cursor. Decides the folder name only.

.PARAMETER Path
    Project root when -Scope Project, or an explicit destination folder when
    -Scope Custom.

.PARAMETER Force
    Overwrite skills that are already installed.

.EXAMPLE
    .\install-skills.ps1
    Installs to $HOME\.agents\skills (Kai, Codex, Gemini CLI).

.EXAMPLE
    .\install-skills.ps1 -Agent claude
    Installs to $HOME\.claude\skills.

.EXAMPLE
    .\install-skills.ps1 -Scope Project -Path C:\src\MyApp
    Installs to C:\src\MyApp\.agents\skills so the team gets them from version control.

.EXAMPLE
    .\install-skills.ps1 -Scope Custom -Path D:\some\other\skills
    Installs straight into a folder you name.
#>
[CmdletBinding()]
param(
    [ValidateSet('User', 'Project', 'Custom')]
    [string]$Scope = 'User',

    [ValidateSet('agents', 'claude', 'gemini', 'cursor')]
    [string]$Agent = 'agents',

    [string]$Path,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$source = Join-Path $PSScriptRoot 'skills'
if (-not (Test-Path $source)) {
    throw "No skills folder next to this script. Run it from the root of the pack."
}

$folder = switch ($Agent) {
    'agents' { '.agents\skills' }
    'claude' { '.claude\skills' }
    'gemini' { '.gemini\skills' }
    'cursor' { '.cursor\skills' }
}

switch ($Scope) {
    'User' {
        $destination = Join-Path $HOME $folder
    }
    'Project' {
        if (-not $Path) { throw "-Scope Project needs -Path pointing at the project root." }
        if (-not (Test-Path $Path)) { throw "Project folder not found: $Path" }
        $destination = Join-Path (Resolve-Path $Path) $folder
    }
    'Custom' {
        if (-not $Path) { throw "-Scope Custom needs -Path pointing at the destination folder." }
        $destination = $Path
    }
}

if (-not (Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
}
$destination = (Resolve-Path $destination).Path

$installed = @()
$skipped = @()

foreach ($skill in Get-ChildItem -Path $source -Directory) {
    $target = Join-Path $destination $skill.Name

    if ((Test-Path $target) -and -not $Force) {
        $skipped += $skill.Name
        continue
    }

    if (Test-Path $target) {
        Remove-Item -Path $target -Recurse -Force
    }

    Copy-Item -Path $skill.FullName -Destination $target -Recurse -Force
    $installed += $skill.Name
}

Write-Host ""
Write-Host "Destination: $destination"

if ($installed.Count -gt 0) {
    Write-Host "Installed:   $($installed -join ', ')"
}
if ($skipped.Count -gt 0) {
    Write-Host "Skipped:     $($skipped -join ', ') (already there, use -Force to overwrite)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next:"
switch ($Agent) {
    'agents' {
        Write-Host "  Kai:   start a new chat so the skills are read, then work in Agent mode."
        Write-Host "  Codex: skills are picked up on the next run."
    }
    'claude' { Write-Host "  Claude Code: run /skills or start a new session to confirm they loaded." }
    'gemini' { Write-Host "  Gemini CLI:  run /skills reload, then /skills list to confirm." }
    default  { Write-Host "  Restart the agent, or use its reload command, so the skills are read." }
}
Write-Host "  Then ask for a FireDAC migration, or work through prompts\00-setup.md onwards."
Write-Host ""
