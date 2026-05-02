#!/usr/bin/env pwsh

Write-Host "Offline Model Installer and Setup"

# --- Color Codes ---
$ESC = [char]27
$GREEN  = "$ESC[32m"
$RED    = "$ESC[31m"
$YELLOW = "$ESC[33m"
$NC     = "$ESC[0m"

# --- Status Helpers ---
function Start-Step($msg) {
    Set-Variable -Name CURRENT_STEP -Value $msg -Scope Script
    Write-Host "[....] $msg" -NoNewline
}

function End-Step($status) {
    switch ($status) {
        "ok"   { Write-Host "`r[$GREEN" + "DONE$NC] $CURRENT_STEP" }
        "fail" { Write-Host "`r[$RED"   + "FAIL$NC] $CURRENT_STEP" }
        "skip" { Write-Host "`r[$YELLOW" + "SKIP$NC] $CURRENT_STEP" }
    }
}

# --- Step: Detect Ollama ---
Start-Step "Checking if Ollama is installed"
if (Get-Command ollama -ErrorAction SilentlyContinue) {
    End-Step "skip"
} else {
    End-Step "ok"

    # --- Step: Install Ollama ---
    Start-Step "Installing Ollama"
    Write-Host ""
    try {
        irm https://ollama.com/install.ps1 | iex
        End-Step "ok"
    }
    catch {
        End-Step "fail"
        Write-Host "Installation failed. Aborting."
        exit 1
    }
}

# --- Placeholder for more operations ---
Start-Step "Running additional setup tasks"
Start-Sleep -Seconds 1
End-Step "ok"

Write-Host "All tasks complete."
