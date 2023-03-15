param (
    [Parameter(Mandatory=$true)][string]$tempPath,
    [Parameter(Mandatory=$true)][string[]]$plotPaths,
    [string]$log = "C:\Users\chia-pc\Desktop\log\log2.log",
    [int]$maxParallelCopy = 10
)

# An array to hold the currently running copy jobs
$runningCopyJobs = @{}
$usedCopyFiles = @()

    while ($true) {
    # Check if all running copy jobs have completed
    $keys = $runningCopyJobs.Keys
    foreach ($key in $keys) {
        $job = $runningCopyJobs[$key]
        if ($job.HasExited) {
            $runningCopyJobs.Remove($key)
            $usedCopyFiles = $usedCopyFiles | Where-Object { $_ -ne $job.Arguments[2] }
            Write-Host "Copy job for $($job.Arguments[2]) on $($job.Arguments[1]) completed."
        }
    }

    # Check if a .plot file is present in the $tempPath
    $file = Get-ChildItem -Path $tempPath -Filter *.plot | Where-Object { $_.Name -notin $usedCopyFiles } | Select-Object -First 1

    if ($file) {
        $dests = @()

        # Check if there is enough space on one of the target drives
        foreach ($plotPath in $plotPaths) {
            # Check if a copy job is already running for this destination
            if ($runningCopyJobs.ContainsKey($plotPath)) {
                Write-Host "Copy job for $($runningCopyJobs[$plotPath].Name) on $($plotPath) is already running, skipping."
                continue
            }
            if (-not (Test-Path -Path $plotPath)) {
                Write-Host "Destination path $($plotPath) does not exist, skipping."
                continue
            }
            $free = (Get-PSDrive -PSProvider 'FileSystem' $plotPath.Substring(0,1)).Free
            if ($free -gt $file.Length/1073741824 -and !($usedCopyFiles -contains $file.Name)) {
                $dests += $plotPath
            }
        }

        if ($dests) {
            # Check if the maximum number of parallel copy jobs has been reached
            if ($runningCopyJobs.Count -ge $maxParallelCopy) {
                Write-Host "Maximum number of parallel copy jobs ($maxParallelCopy) reached, waiting for free slots..."
                while ($runningCopyJobs.Count -ge $maxParallelCopy) {
                    foreach ($job in $runningCopyJobs.GetEnumerator()) {
                        if ($job.Value.HasExited) {
                            $runningCopyJobs.Remove($job.Key)
                            $usedCopyFiles = $usedCopyFiles | Where-Object { $_ -ne $job.Value.Arguments[2] }
                            Write-Host "Copy job for $($job.Value.Arguments[2]) on $($job.Value.Arguments[1]) completed."
                            break
                        }
                    }
                    Start-Sleep -Seconds 15
                }
            }

            # Start the copy operation in a new process
            $dest = $dests | Sort-Object { (Get-PSDrive $_.Substring(0,1)).Free } | Select-Object -First 1
            $copyJob = Start-Process -FilePath "robocopy" -ArgumentList $file.DirectoryName, $dest, $file.Name, "/J", "/MOV", "/LOG+:$log", "/TEE", "/ETA" -PassThru 
            $runningCopyJobs[$dest] = $copyJob
            $usedCopyFiles += $file.Name
            Write-Host "Copying $($file.Name) to $($dest)..."
        }
        else {
            Write-Host "No target drive with enough free space found for file $($file.Name)."
        }
    }
    else {
        Write-Host "No .plot files found in $($tempPath)."
    }
    
    Start-Sleep -Seconds 30
}