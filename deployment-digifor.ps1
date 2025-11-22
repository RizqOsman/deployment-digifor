# ============================================================================
# F.R.I.D.A.Y - Forensic Research Installation & Deployment Assistant for You
# ============================================================================
# Windows 11 Pro Installation Script
# ============================================================================

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Color definitions
$colors = @{
    Primary = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Magenta"
    Header = "Blue"
}

# ASCII Art Banner
function Show-FridayBanner {
    Clear-Host
    Write-Host ""
    Write-Host "  ███████╗  ██████╗   ██╗  ██████╗    █████╗  ██╗   ██╗" -ForegroundColor $colors.Primary
    Write-Host "  ██╔════╝  ██╔══██╗  ██║  ██╔══██╗  ██╔══██╗ ╚██╗ ██╔╝" -ForegroundColor $colors.Primary
    Write-Host "  █████╗    ██████╔╝  ██║  ██║  ██║  ███████║  ╚████╔╝ " -ForegroundColor $colors.Primary
    Write-Host "  ██╔══╝    ██╔══██╗  ██║  ██║  ██║  ██╔══██║   ╚██╔╝  " -ForegroundColor $colors.Primary
    Write-Host "  ██║       ██║  ██║  ██║  ██████╔╝  ██║  ██║    ██║   " -ForegroundColor $colors.Primary
    Write-Host "  ╚═╝       ╚═╝  ╚═╝  ╚═╝  ╚═════╝   ╚═╝  ╚═╝    ╚═╝   " -ForegroundColor $colors.Primary
    Write-Host ""
    Write-Host "  Forensic Research Installation & Deployment Assistant for You" -ForegroundColor $colors.Info
    Write-Host "  ══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host ""
}

# Animated loading function
function Show-Loading {
    param([string]$Message)
    $spinner = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
    $i = 0
    Write-Host -NoNewline "$Message "
    for ($x = 0; $x -lt 20; $x++) {
        Write-Host -NoNewline "`r$Message $($spinner[$i % $spinner.Length])" -ForegroundColor $colors.Primary
        Start-Sleep -Milliseconds 100
        $i++
    }
    Write-Host "`r$Message ✓" -ForegroundColor $colors.Success
}

# Friday speaks
function Friday-Say {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    $prefix = "F.R.I.D.A.Y >"
    Write-Host ""
    Write-Host "$prefix " -ForegroundColor $colors.Primary -NoNewline
    Write-Host "$Message" -ForegroundColor $colors[$Type]
}

# Progress bar
function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity
    )
    $percent = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Activity -Status "$percent% Complete" -PercentComplete $percent
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Install Chocolatey
function Install-Chocolatey {
    Friday-Say "Checking for Chocolatey package manager..." "Info"
    
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Friday-Say "Installing Chocolatey package manager..." "Warning"
        Show-Loading "Setting up Chocolatey"
        
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        Friday-Say "Chocolatey installed successfully!" "Success"
    } else {
        Friday-Say "Chocolatey is already installed!" "Success"
    }
}

# Install application
function Install-Application {
    param(
        [string]$Name,
        [string]$ChocoPackage,
        [string]$CheckCommand
    )
    
    Friday-Say "Checking for $Name..." "Info"
    
    if (!(Get-Command $CheckCommand -ErrorAction SilentlyContinue)) {
        Friday-Say "Installing $Name..." "Warning"
        Show-Loading "Downloading and installing $Name"
        
        choco install $ChocoPackage -y --no-progress
        
        if ($LASTEXITCODE -eq 0) {
            Friday-Say "$Name installed successfully!" "Success"
        } else {
            Friday-Say "Failed to install $Name. Please check manually." "Error"
        }
    } else {
        Friday-Say "$Name is already installed!" "Success"
    }
}

# Clone repository
function Clone-Repository {
    param(
        [string]$Url,
        [string]$Name,
        [string]$Description
    )
    
    $repoName = ($Url -split '/')[-1] -replace '.git$', ''
    $targetPath = Join-Path $PSScriptRoot $repoName
    
    Friday-Say "Cloning $Name ($Description)..." "Info"
    
    if (Test-Path $targetPath) {
        Friday-Say "Repository '$repoName' already exists. Skipping..." "Warning"
    } else {
        Show-Loading "Cloning from GitHub"
        git clone $Url $targetPath 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Friday-Say "$Name cloned successfully to: $targetPath" "Success"
        } else {
            Friday-Say "Failed to clone $Name. Please check manually." "Error"
        }
    }
}

# Main installation process
function Start-Installation {
    Show-FridayBanner
    
    Friday-Say "Good day! I'm F.R.I.D.A.Y, your installation assistant." "Info"
    Friday-Say "Initializing installation sequence for Windows 11 Pro..." "Info"
    Start-Sleep -Seconds 2
    
    # Check administrator privileges
    if (!(Test-Administrator)) {
        Friday-Say "Administrator privileges required!" "Error"
        Friday-Say "Please run this script as Administrator." "Warning"
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Friday-Say "Administrator privileges confirmed!" "Success"
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host "  PHASE 1: Package Manager Setup" -ForegroundColor $colors.Header
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host ""
    
    Install-Chocolatey
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host "  PHASE 2: Development Tools Installation" -ForegroundColor $colors.Header
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host ""
    
    $totalApps = 5
    $currentApp = 0
    
    # Install Docker Desktop
    $currentApp++
    Show-Progress -Current $currentApp -Total $totalApps -Activity "Installing Development Tools"
    Install-Application -Name "Docker Desktop" -ChocoPackage "docker-desktop" -CheckCommand "docker"
    Write-Host ""
    
    # Install Visual Studio Build Tools
    $currentApp++
    Show-Progress -Current $currentApp -Total $totalApps -Activity "Installing Development Tools"
    Install-Application -Name "Visual Studio Build Tools" -ChocoPackage "visualstudio2022buildtools" -CheckCommand "vswhere"
    Write-Host ""
    
    # Install Python
    $currentApp++
    Show-Progress -Current $currentApp -Total $totalApps -Activity "Installing Development Tools"
    Install-Application -Name "Python" -ChocoPackage "python" -CheckCommand "python"
    Write-Host ""
    
    # Install Node.js
    $currentApp++
    Show-Progress -Current $currentApp -Total $totalApps -Activity "Installing Development Tools"
    Install-Application -Name "Node.js" -ChocoPackage "nodejs" -CheckCommand "node"
    Write-Host ""
    
    # Install Git
    $currentApp++
    Show-Progress -Current $currentApp -Total $totalApps -Activity "Installing Development Tools"
    Install-Application -Name "Git" -ChocoPackage "git" -CheckCommand "git"
    Write-Host ""
    
    # Refresh environment variables again
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host "  PHASE 3: Cloning GitHub Repositories" -ForegroundColor $colors.Header
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host ""
    
    Start-Sleep -Seconds 1
    
    # Clone repositories
    Clone-Repository -Url "https://github.com/CyberSecurityDept/digifor.git" -Name "Digifor" -Description "Python FastAPI"
    Write-Host ""
    
    Clone-Repository -Url "https://github.com/Bagongs/forensic-file-encryptor-app.git" -Name "Forensic File Encryptor" -Description "NodeJS - ReactJS - Electron"
    Write-Host ""
    
    Clone-Repository -Url "https://github.com/Bagongs/forensic-analytics-app.git" -Name "Forensic Analytics" -Description "NodeJS - ReactJS - Electron"
    Write-Host ""
    
    # Installation complete
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host "  INSTALLATION COMPLETE" -ForegroundColor $colors.Header
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $colors.Header
    Write-Host ""
    
    Friday-Say "All systems operational!" "Success"
    Friday-Say "Installation completed successfully!" "Success"
    Write-Host ""
    Friday-Say "Installed Applications:" "Info"
    Write-Host "  • Docker Desktop" -ForegroundColor $colors.Success
    Write-Host "  • Visual Studio Build Tools" -ForegroundColor $colors.Success
    Write-Host "  • Python" -ForegroundColor $colors.Success
    Write-Host "  • Node.js" -ForegroundColor $colors.Success
    Write-Host "  • Git" -ForegroundColor $colors.Success
    Write-Host ""
    Friday-Say "Cloned Repositories:" "Info"
    Write-Host "  • digifor (Python FastAPI)" -ForegroundColor $colors.Success
    Write-Host "  • forensic-file-encryptor-app (Electron)" -ForegroundColor $colors.Success
    Write-Host "  • forensic-analytics-app (Electron)" -ForegroundColor $colors.Success
    Write-Host ""
    Friday-Say "IMPORTANT: Please restart your computer to complete the installation." "Warning"
    Friday-Say "Thank you for using F.R.I.D.A.Y!" "Info"
    Write-Host ""
}

# Run the installation
try {
    Start-Installation
} catch {
    Friday-Say "An error occurred during installation: $_" "Error"
    Write-Host ""
} finally {
    Write-Host ""
    Read-Host "Press Enter to exit"
}
