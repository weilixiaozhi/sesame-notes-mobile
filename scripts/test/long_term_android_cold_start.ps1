<# .SYNOPSIS 对已经完成造数的独立测试包采集进程冷启动，不修改正式应用和系统网络。 #>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Serial,
    [Parameter(Mandatory=$true)][string]$OutputDirectory,
    [ValidateRange(20,50)][int]$Samples=20
)
$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$package='com.sesame.notes.test.probe'

<# .SYNOPSIS 只对指定设备执行ADB，非零退出保留上下文。 #>
function Invoke-QaAdb {
    param([string[]]$Arguments)
    try {
        $output=& adb -s $Serial @Arguments
        if($LASTEXITCODE -ne 0){throw "ADB命令未完成：$($Arguments -join ' ')"}
        return $output
    } catch {throw [InvalidOperationException]::new('独立测试设备操作失败。', $_.Exception)}
}

try {
    $outputRoot=[IO.Path]::GetFullPath($OutputDirectory,$repoRoot)
    $tempRoot=[IO.Path]::GetFullPath((Join-Path $repoRoot 'Temp'))+[IO.Path]::DirectorySeparatorChar
    if(-not $outputRoot.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase) -or (Test-Path -LiteralPath $outputRoot)){
        throw '输出目录必须是仓库Temp下尚不存在的目录，以保留历次测量。'
    }
    $null=New-Item -ItemType Directory -Path $outputRoot
    $activity=(Invoke-QaAdb @('shell','cmd','package','resolve-activity','--brief',$package)|Select-Object -Last 1).Trim()
    if($activity -notmatch '^com\.sesame\.notes\.test\.probe/[A-Za-z0-9_.$]+$'){throw '未找到独立测试包的启动组件。'}
    $results=@()
    for($sample=1;$sample -le $Samples;$sample++){
        Invoke-QaAdb @('shell','am','force-stop',$package)|Out-Null
        $before=& adb -s $Serial shell pidof $package
        if($before){throw '测试包进程未停止，不计入冷启动。'}
        $timer=[Diagnostics.Stopwatch]::StartNew()
        $launch=Invoke-QaAdb @('shell','am','start','-W','-n',$activity)
        $launch|Set-Content -LiteralPath (Join-Path $outputRoot "launch-$sample.log") -Encoding utf8
        if(($launch -join "`n") -notmatch 'Status:\s*ok'){throw 'Activity未成功启动。'}
        $qaProcess=(Invoke-QaAdb @('shell','pidof',$package)).Trim()
        if($qaProcess -notmatch '^\d+$'){throw '无法确定本轮独立进程。'}
        $cold=$null
        $ready=$null
        $events=@()
        while($timer.Elapsed.TotalSeconds -lt 30){
            $log=Invoke-QaAdb @('logcat','-d',"--pid=$qaProcess",'-s','flutter:I')
            $events=@($log|ForEach-Object {if($_ -match 'LONG_TERM_ANDROID_JSON:\s*(\{.*\})'){$Matches[1]|ConvertFrom-Json}})
            if($events|Where-Object type -eq 'error'){throw '应用报告验收错误，请查看本轮日志。'}
            $cold=$events|Where-Object type -eq 'cold_startup'|Select-Object -Last 1
            $ready=$events|Where-Object type -eq 'ready_for_manual'|Select-Object -Last 1
            if($cold -and $ready){break}
            Start-Sleep -Milliseconds 200
        }
        $timer.Stop()
        $log|Set-Content -LiteralPath (Join-Path $outputRoot "app-$sample.log") -Encoding utf8
        if(-not $cold -or -not $ready -or -not $ready.benchmarks_complete){throw '应用未完成既有10年数据的冷启动，不能把首次造数计为冷启动。'}
        $native=@{}
        foreach($line in $launch){if($line -match '^(TotalTime|WaitTime|ThisTime):\s*(\d+)'){$native[$Matches[1]]=[int]$Matches[2]}}
        $results+=@{sample=$sample;pid=[int]$qaProcess;utc=[DateTime]::UtcNow.ToString('o');native_ms=$native;dart=$cold;host_ready_observation_ms=$timer.Elapsed.TotalMilliseconds}
        @{samples=$results;mode='Android profile; process cold, warm OS file cache; Dart timing includes QA guards; host ready observation includes adb polling'}|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $outputRoot 'results.json') -Encoding utf8
        Write-Output "冷启动样本 $sample/$Samples 已记录。"
    }
    Write-Output "测量完成：$outputRoot"
} catch {
    [Console]::Error.WriteLine("冷启动验收未完成：$($_.Exception.Message)")
    [Console]::Error.WriteLine($_.ScriptStackTrace)
    exit 1
}
