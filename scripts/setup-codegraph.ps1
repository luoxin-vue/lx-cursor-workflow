[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath
)

$ErrorActionPreference = 'Stop'

$project = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path
$indexPath = Join-Path $project '.codegraph'
if (Test-Path -LiteralPath $indexPath -PathType Container) {
    Write-Host "[CodeGraph] 已检测到项目索引：$indexPath"
    exit 0
}

Write-Host ''
Write-Host "[CodeGraph] 项目未检测到 .codegraph：$project"
Write-Host 'CodeGraph 可以在本地建立代码结构、调用关系和影响范围索引，帮助 AI：'
Write-Host '  - 先定位真实入口和调用方，再做手术刀式修改'
Write-Host '  - 复用已有公共组件、工具和依赖，减少重复造轮子'
Write-Host '  - 修 Bug 前看到影响范围，降低漏改和误改风险'
Write-Host '索引保存在项目本地，CodeGraph CLI 不会替代项目测试。'
$answer = Read-Host '是否安装最新 CodeGraph CLI 到个人全局，并为此项目建立索引？(Y/N)'
if ($answer -notmatch '^(?i:y|yes|是)$') {
    Write-Host '[CodeGraph] 用户选择跳过，工作流安装继续完成。'
    exit 0
}

function Get-CodeGraphCommand {
    $command = Get-Command codegraph -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command }
    return $null
}

$command = Get-CodeGraphCommand
$npm = Get-Command npm -ErrorAction SilentlyContinue
$latest = $null
if ($npm) {
    $latest = (& $npm.Source view '@colbymchenry/codegraph' version 2>$null | Select-Object -Last 1).Trim()
}
$current = $null
if ($command) {
    $current = (& $command.Source --version 2>$null | Select-Object -Last 1).Trim()
}

if (-not $command -or ($latest -and $current -ne $latest)) {
    if ($npm) {
        Write-Host '[CodeGraph] 正在安装最新 CLI 到 npm 个人全局目录...'
        & $npm.Source install --global '@colbymchenry/codegraph@latest' --no-fund --no-audit
        if ($LASTEXITCODE -ne 0) { throw 'CodeGraph CLI 安装失败。' }
        $prefix = (& $npm.Source prefix --global 2>$null | Select-Object -Last 1).Trim()
        if ($prefix -and (Test-Path -LiteralPath $prefix)) { $env:Path = "$prefix;$env:Path" }
    } else {
        Write-Host '[CodeGraph] 未找到 npm，改用官方 Windows 安装器...'
        $installer = (Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1').Content
        & ([scriptblock]::Create($installer))
        if ($LASTEXITCODE -ne 0) { throw 'CodeGraph CLI 安装失败。' }
    }
    $command = Get-CodeGraphCommand
}

if (-not $command) {
    throw 'CodeGraph CLI 安装后仍不可用，请重新打开终端后再执行 codegraph init。'
}

$current = (& $command.Source --version 2>$null | Select-Object -Last 1).Trim()
Write-Host "[CodeGraph] CLI 已就绪：$current"
Write-Host '[CodeGraph] 正在为项目建立本地索引...'
& $command.Source init $project
if ($LASTEXITCODE -ne 0) { throw 'CodeGraph 项目索引初始化失败。' }
Write-Host '[CodeGraph] 项目索引完成。'
