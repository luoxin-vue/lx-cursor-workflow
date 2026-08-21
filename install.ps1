[CmdletBinding()]
param(
    [switch]$WhatIf,
    [switch]$Uninstall,
    [switch]$SkipCodeGraph,
    [string]$ProjectPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Join-Path $repoRoot 'skills'
$manifest = Get-Content -LiteralPath (Join-Path $repoRoot 'manifest.json') -Raw | ConvertFrom-Json
$cursorRoot = Join-Path $env:USERPROFILE '.cursor'
$destinationRoot = Join-Path $cursorRoot 'skills'
$recordPath = Join-Path $cursorRoot 'lx-cursor-workflow.manifest.json'

function Get-TreeRecords([string]$root) {
    $records = @()
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { return $records }
    Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
        $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\') + '\'
        $fileFull = [IO.Path]::GetFullPath($_.FullName)
        $relative = $fileFull.Substring($rootFull.Length).Replace('\', '/')
        $records += [PSCustomObject]@{
            path = $relative
            hash = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    }
    return @($records | Sort-Object path)
}

function Test-TreeEqual($left, $right) {
    $leftRecords = @(Get-TreeRecords $left)
    $rightRecords = @(Get-TreeRecords $right)
    if ($leftRecords.Count -ne $rightRecords.Count) { return $false }
    for ($i = 0; $i -lt $leftRecords.Count; $i++) {
        if ($leftRecords[$i].path -ne $rightRecords[$i].path) { return $false }
        if ($leftRecords[$i].hash -ne $rightRecords[$i].hash) { return $false }
    }
    return $true
}

function Remove-ManagedInstall {
    if (-not (Test-Path -LiteralPath $recordPath -PathType Leaf)) {
        Write-Host "没有找到本安装器的记录：$recordPath"
        return
    }

    $record = Get-Content -LiteralPath $recordPath -Raw | ConvertFrom-Json
    $blocked = @()
    foreach ($item in @($record.skills)) {
        $target = Join-Path $destinationRoot $item.name
        if (-not (Test-Path -LiteralPath $target -PathType Container)) { continue }
        $expected = @($item.files | ForEach-Object { [PSCustomObject]@{ path = $_.path; hash = $_.hash } })
        $actual = @(Get-TreeRecords $target)
        $same = $expected.Count -eq $actual.Count
        if ($same) {
            for ($i = 0; $i -lt $expected.Count; $i++) {
                if ($expected[$i].path -ne $actual[$i].path -or $expected[$i].hash -ne $actual[$i].hash) { $same = $false; break }
            }
        }
        if ($same) {
            Remove-Item -LiteralPath $target -Recurse -Force
            Write-Host "已卸载 $($item.name)"
        } else {
            $blocked += $item.name
            Write-Warning "保留 $($item.name)：安装后内容已被修改。"
        }
    }
    if ($blocked.Count -eq 0) {
        Remove-Item -LiteralPath $recordPath -Force
        Write-Host '已删除安装记录。'
    } else {
        Write-Warning "以下目录未删除：$($blocked -join ', ')"
    }
}

if ($Uninstall) {
    Remove-ManagedInstall
    exit 0
}

$skillNames = @($manifest.skills)
$conflicts = @()
$actions = @()
foreach ($name in $skillNames) {
    $source = Join-Path $sourceRoot $name
    $target = Join-Path $destinationRoot $name
    if (-not (Test-Path -LiteralPath $source -PathType Container) -or -not (Test-Path -LiteralPath (Join-Path $source 'SKILL.md') -PathType Leaf)) {
        throw "源 Skill 不完整：$name"
    }
    if (Test-Path -LiteralPath $target -PathType Container) {
        if (Test-TreeEqual $source $target) {
            $actions += "跳过（内容相同）：$name"
        } else {
            $conflicts += $name
        }
    } else {
        $actions += "安装：$name"
    }
}

if ($conflicts.Count -gt 0) {
    Write-Host "检测到冲突，未安装任何 Skill：$($conflicts -join ', ')" -ForegroundColor Red
    Write-Host '请先人工处理冲突目录，安装器不会覆盖已有内容。' -ForegroundColor Red
    exit 2
}

if ($WhatIf) {
    Write-Host "目标目录：$destinationRoot"
    $actions | ForEach-Object { Write-Host $_ }
    Write-Host '预览结束，未写入文件。'
    exit 0
}

New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null
$installed = @()
foreach ($name in $skillNames) {
    $source = Join-Path $sourceRoot $name
    $target = Join-Path $destinationRoot $name
    if (-not (Test-Path -LiteralPath $target -PathType Container)) {
        Copy-Item -LiteralPath $source -Destination $target -Recurse
        Write-Host "已安装 $name"
    } else {
        Write-Host "已存在且一致，跳过 $name"
    }
    $installed += [PSCustomObject]@{ name = $name; files = @(Get-TreeRecords $target) }
}

New-Item -ItemType Directory -Force -Path $cursorRoot | Out-Null
[PSCustomObject]@{
    name = $manifest.name
    version = $manifest.version
    installedAt = (Get-Date).ToUniversalTime().ToString('o')
    skills = $installed
} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $recordPath -Encoding UTF8
Write-Host "安装完成：$recordPath"

if (-not $WhatIf -and -not $SkipCodeGraph) {
    $targetProject = $ProjectPath
    if ([string]::IsNullOrWhiteSpace($targetProject)) {
        $currentPath = (Get-Location).Path
        $repoFullPath = [IO.Path]::GetFullPath($repoRoot).TrimEnd('\')
        $currentFullPath = [IO.Path]::GetFullPath($currentPath).TrimEnd('\')
        if ($currentFullPath -ne $repoFullPath -and (Test-Path -LiteralPath (Join-Path $currentFullPath '.git') -PathType Container)) {
            $targetProject = $currentFullPath
        }
    }

    if ([string]::IsNullOrWhiteSpace($targetProject)) {
        Write-Host '未指定目标项目，已跳过 CodeGraph 检测。需要时请使用 -ProjectPath <项目目录> 重新执行安装器。'
    } else {
        $codeGraphSetup = Join-Path $repoRoot 'scripts\setup-codegraph.ps1'
        & $codeGraphSetup -ProjectPath $targetProject
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
}
