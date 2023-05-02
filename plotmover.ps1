$src = "E:\"
$destinations = @("F:\", "D:\", "X:\", "Z:\")
$maxProcessesPerDest = 1  # maximum number of concurrent copy processes per destination
$moveCounts = @{}
$processCounts = @{}

foreach ($dest in $destinations) {
    $moveCounts[$dest] = 0
    $processCounts[$dest] = 0
}

Start-Sleep -Seconds 5 # Delay for 5 seconds to allow robocopy processes to start

do {
    $plotFiles = Get-ChildItem -Path $src -Filter *.plot
    foreach ($file in $plotFiles) {
        $runningProcesses = Get-WmiObject Win32_Process | Where-Object {$_.Name -eq "robocopy.exe" -and $_.CommandLine -match "$([regex]::Escape($file.Name))"}
        
        Start-Sleep -Seconds 5
        
        if ($runningProcesses) {
            continue
        }

        foreach ($dest in $destinations) {
            $processCount = $processCounts[$dest]

            if ($processCount -lt $maxProcessesPerDest) {
                $drive = Get-PSDrive -Name $($dest[0]) -ErrorAction SilentlyContinue
                if (!$drive) {
                    Write-Warning "Drive $($dest[0]) not found. Skipping destination $dest."
                    continue
                }

                $freeSpace = (Get-PSDrive -PSProvider 'FileSystem' $dest.Substring(0,1)).Free / 1GB
                $plotSize = $file.Length / 1GB
                if ($freeSpace -lt $plotSize) {
                    Write-Warning "Not enough free space on $($dest[0]) to copy $($file.Name). Skipping destination $dest."
                    continue
                }

                Start-Process -FilePath "Robocopy" -ArgumentList $src, $dest, $file, "/J", "/MOV" -PassThru -Wait
                Write-Host "Started copying $($file.Name) to $dest..."

                $moveCounts[$dest]++
                $processCounts[$dest]++

                break
            }
        }
    }

    Start-Sleep -Seconds 5

    # Check if any move processes have completed and reset moveCount if they have
    $completedJobs = Get-Job | Where-Object { $_.State -eq "Completed" }

    foreach($job in $completedJobs) {
        $jobId = $job.Id
        $dest = $job.Location

        Receive-Job $jobId | Out-Null
        $moveCounts[$dest] = 0
        $processCounts[$dest]--
    }
} while ($true)
