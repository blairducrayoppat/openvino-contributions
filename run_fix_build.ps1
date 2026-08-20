# Launch the incremental npu_compiler build, throttled to cores 3-7 (mask 0xF8, ~62% cap)
# + BelowNormal priority so the Lead Architect keeps P-cores 0-2 free during the day.
$ErrorActionPreference = 'Continue'
$status = 'C:\Users\mrbla\oss\fix_build_status.txt'
"BUILD_START $(Get-Date -Format o)" | Set-Content $status

$build = Start-Process -FilePath 'cmd.exe' `
    -ArgumentList '/c', 'C:\Users\mrbla\oss\build_fix.cmd' `
    -PassThru -WindowStyle Hidden

$mask = [IntPtr]0xF8
while (-not $build.HasExited) {
    Get-Process -Name cl, link, lld-link, ninja, cmake, mspdbsrv -ErrorAction SilentlyContinue | ForEach-Object {
        try { $_.ProcessorAffinity = $mask; $_.PriorityClass = 'BelowNormal' } catch {}
    }
    Start-Sleep -Milliseconds 700
}
"BUILD_EXIT $($build.ExitCode) $(Get-Date -Format o)" | Add-Content $status
