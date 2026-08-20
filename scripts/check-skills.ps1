[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content (Join-Path $packageRoot 'manifest.json') -Raw | ConvertFrom-Json
foreach ($name in @($manifest.skills)) {
    $skillPath = Join-Path $packageRoot "skills\$name\SKILL.md"
    if (-not (Test-Path $skillPath)) { throw "缺少 $skillPath" }
    $content = Get-Content $skillPath -Raw
    if ($content -notmatch "(?m)^name:\s*$name\s*$") { throw "$name 的 frontmatter name 不匹配" }
    if ($content -notmatch '(?m)^description:\s*.+$') { throw "$name 缺少 description" }
}
Write-Host "PASS: $(@($manifest.skills).Count) 个 Skill 的目录和 frontmatter 通过检查。"

