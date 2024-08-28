# 出力先を選択するフラグ ($true = ログファイル, $false = 標準出力)
$outputToLog = $false

# ホスト、ユーザー、コマンドセットを定義
$sshCommandList = @(
    @{
        Host     = "192.168.1.251"
        User     = "user1"
        Commands = @("uname -a", "df -h", "uptime")
    }
)

# ログファイル
$logFile = "D:\logfile20240828.txt"

# ログファイルが存在しない場合は新規作成、存在する場合はクリア
if ($outputToLog) {
    if (-not (Test-Path $logFile)) {
        New-Item -Path $logFile -ItemType File | Out-Null
    } else {
        Clear-Content -Path $logFile
    }
}

# $sshCommandListを取り出す
foreach ($pair in $sshCommandList) {
    $execHost     = $pair.Host
    $execUser     = $pair.User
    $execCommands = $pair.Commands

    # $execCommandsを取り出してループする
    foreach ($command in $execCommands) {
        # 時刻を取得する
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.ffff"
        # SSHコマンドを実行し、結果を文字列に変換
        $result = cmd.exe /c ssh ${execUser}@${execHost} ${command} | Out-String
        # 結果を成形する
        $logEntry = "# Timestamp: ${timestamp} Host: ${execHost} User: ${execUser} Command: ${command}`n`n${result}`n"

        # 結果はログか、標準出力か
        if ($outputToLog) {
            # 結果をログに記録
            Add-Content -Path $logFile -Value $logEntry
        } else {
            # 結果を標準出力に表示
            Write-Host $logEntry
        }
    }
}

# 出力先が標準出力の場合はEnterキーを押すまでウィンドウを閉じない
if (-not ($outputToLog)) {
    Read-Host "Press Enter Key..."
}
