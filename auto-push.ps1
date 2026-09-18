# Auto-commit and push on file changes
# Run this in the background: PowerShell -ExecutionPolicy Bypass -File auto-push.ps1

$repo = Get-Location
$lastHash = ""

Write-Host "🔄 Auto-push enabled for Moldinvest" -ForegroundColor Green
Write-Host "Watching for changes every 5 seconds..." -ForegroundColor Cyan

while ($true) {
    try {
        # Get current git status
        $output = & git status --porcelain 2>$null
        $currentHash = ($output | Get-StringHash).Hash
        
        # If files changed
        if ($output -and $currentHash -ne $lastHash) {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Detected changes, committing..." -ForegroundColor Yellow
            
            # Stage all changes
            & git add .
            
            # Commit with timestamp
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            & git commit -m "Auto-save: $timestamp" -m "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>" 2>$null
            
            # Push to GitHub
            $pushOutput = & git push 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Successfully pushed to GitHub" -ForegroundColor Green
            } else {
                Write-Host "⚠️ Push failed: $pushOutput" -ForegroundColor Red
            }
            
            $lastHash = $currentHash
        }
        
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "❌ Error: $_" -ForegroundColor Red
        Start-Sleep -Seconds 10
    }
}
