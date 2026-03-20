$dockerDesktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$wslExe = "C:\Windows\System32\wsl.exe"
$distro = "Ubuntu-24.04"
$user = "gaga"
$command = "systemctl --user start openclaw-stack.service openclaw-node.service || true"

if (Test-Path $dockerDesktop) {
    Start-Process -FilePath $dockerDesktop -WindowStyle Minimized
}

Start-Sleep -Seconds 20

Start-Process -FilePath $wslExe -ArgumentList @(
    "-d", $distro,
    "-u", $user,
    "--",
    "/bin/bash", "-lc",
    $command
) -WindowStyle Hidden
