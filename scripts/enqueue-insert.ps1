[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Uri,
    [string]$Host = "127.0.0.1",
    [int]$Port = 1234,
    [string]$QueueId = "insert_queue"
)

$ErrorActionPreference = 'Stop'

$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($Host, $Port)

try {
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $reader = New-Object System.IO.StreamReader($stream)

    $writer.NewLine = "`n"
    $writer.AutoFlush = $true

    $command = "$QueueId.push $Uri"
    $writer.WriteLine($command)
    $writer.WriteLine("exit")

    Start-Sleep -Milliseconds 200

    $response = ""
    while ($stream.DataAvailable) {
        $response += $reader.ReadToEnd()
        Start-Sleep -Milliseconds 50
    }

    if ([string]::IsNullOrWhiteSpace($response)) {
        Write-Host "Queued request command sent: $command"
    } else {
        Write-Host $response.Trim()
    }
}
finally {
    if ($client.Connected) {
        $client.Close()
    }
}
