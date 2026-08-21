[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$packageRoot = Split-Path -Parent $PSScriptRoot
$install = Join-Path $packageRoot 'install.ps1'
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('lx-cursor-workflow-test-' + [Guid]::NewGuid().ToString('N'))
$oldUserProfile = $env:USERPROFILE

function Assert-True([bool]$condition, [string]$message) {
    if (-not $condition) { throw "验证失败：$message" }
}

try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $env:USERPROFILE = $tempRoot
    $powershell = (Get-Process -Id $PID).Path

    & $powershell -NoProfile -ExecutionPolicy Bypass -File $install -WhatIf | Out-Host
    Assert-True (-not (Test-Path (Join-Path $tempRoot '.cursor'))) 'WhatIf 不应创建 Cursor 目录'

    & $powershell -NoProfile -ExecutionPolicy Bypass -File $install -SkipCodeGraph | Out-Host
    $destination = Join-Path $tempRoot '.cursor\skills'
    Assert-True (Test-Path (Join-Path $destination 'lx-grill\SKILL.md')) '首次安装缺少 lx-grill'
    Assert-True (Test-Path (Join-Path $destination 'lx-bugfix\SKILL.md')) '首次安装缺少 lx-bugfix'
    Assert-True (Test-Path (Join-Path $tempRoot '.cursor\lx-cursor-workflow.manifest.json')) '缺少安装记录'

    & $powershell -NoProfile -ExecutionPolicy Bypass -File $install -SkipCodeGraph | Out-Host
    $conflictFile = Join-Path $destination 'lx-grill\SKILL.md'
    Add-Content -LiteralPath $conflictFile -Value "`n# intentional conflict"
    & $powershell -NoProfile -ExecutionPolicy Bypass -File $install -SkipCodeGraph 2>$null
    Assert-True ($LASTEXITCODE -eq 2) '冲突安装没有返回退出码 2'

    & $powershell -NoProfile -ExecutionPolicy Bypass -File $install -Uninstall | Out-Host
    Assert-True (Test-Path $conflictFile) '卸载器删除了被修改的 Skill'
    Write-Host 'PASS: WhatIf、首次安装、重复安装、冲突停止和安全卸载均通过。'
} finally {
    $env:USERPROFILE = $oldUserProfile
    if (Test-Path $tempRoot) { Remove-Item -LiteralPath $tempRoot -Recurse -Force }
}

