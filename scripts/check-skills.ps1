[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content (Join-Path $packageRoot 'manifest.json') -Raw | ConvertFrom-Json
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($name in @($manifest.skills)) {
    $skillPath = Join-Path $packageRoot "skills\$name\SKILL.md"
    if (-not (Test-Path $skillPath)) { throw "缺少 $skillPath" }
    $content = [System.IO.File]::ReadAllText($skillPath, $utf8)
    if ($content -notmatch "(?m)^name:\s*$name\s*$") { throw "$name 的 frontmatter name 不匹配" }
    if ($content -notmatch '(?m)^description:\s*.+$') { throw "$name 缺少 description" }
}
$workflowContent = [System.IO.File]::ReadAllText((Join-Path $packageRoot 'skills\lx-workflow\SKILL.md'), $utf8)
$bugfixContent = [System.IO.File]::ReadAllText((Join-Path $packageRoot 'skills\lx-bugfix\SKILL.md'), $utf8)
if ($workflowContent -notmatch 'fast.*门槛') { throw 'lx-workflow 缺少 Bugfix 快速分流规则' }
if ($bugfixContent -notmatch '速度原则：先快后深') { throw 'lx-bugfix 缺少速度原则' }
if ($bugfixContent -notmatch '契约已由项目文档') { throw 'lx-bugfix 缺少已确认接口契约的快路径规则' }
if ($bugfixContent -notmatch '最小验证无法解释用户现象') { throw 'lx-bugfix 缺少证据不足时升级规则' }
Write-Host "PASS: $(@($manifest.skills).Count) 个 Skill 的目录和 frontmatter 通过检查。"

