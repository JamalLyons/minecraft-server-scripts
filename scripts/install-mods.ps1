# Minecraft Mods Installation Script
# Author: Jamal Lyons
# Description: This script automates the installation of Minecraft mods for my CurseForge profile.

# Function for colored logging
function Write-ColorLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [string]$ForegroundColor = "White",
        
        [Parameter(Mandatory = $false)]
        [string]$Prefix = "INFO"
    )
    
    $prefixColor = switch ($Prefix) {
        "INFO" { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR" { "Red" }
        default { "White" }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] " -NoNewline
    Write-Host "[$Prefix] " -ForegroundColor $prefixColor -NoNewline
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Function to get confirmation from user
function Get-UserConfirmation {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    Write-ColorLog -Message $Message -Prefix "WARNING" 
    $confirmation = Read-Host "Do you want to continue? (Y/N)"
    
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-ColorLog -Message "Operation cancelled by user." -Prefix "INFO"
        return $false
    }
    
    return $true
}

# Function to download a file with progress bar
function Download-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell Script")
        
        Write-ColorLog -Message "Downloading from: $Url" -Prefix "INFO"
        Write-ColorLog -Message "Saving to: $OutputPath" -Prefix "INFO"
        
        $webClient.DownloadFile($Url, $OutputPath)
        
        if (Test-Path $OutputPath) {
            Write-ColorLog -Message "Download completed successfully!" -Prefix "SUCCESS"
            return $true
        }
        else {
            Write-ColorLog -Message "Failed to download file." -Prefix "ERROR"
            return $false
        }
    }
    catch {
        Write-ColorLog -Message "Error downloading file: $_" -Prefix "ERROR"
        return $false
    }
}

# Function to extract mod name and version from filename
function Get-ModInfo {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Filename
    )
    
    # Create pattern to match common mod filename formats
    # Example: modname-mc1.20.1-v2.3.4.jar, modname-forge-1.20-2.3.4.jar
    $pattern = '^(.*?)(?:-forge|-fabric|-mc|-minecraft)?-?(?:1\.\d+(?:\.\d+)?)?(?:-)?(?:v)?(\d+\.\d+\.\d+(?:\.\d+)?).*\.jar$'
    
    if ($Filename -match $pattern) {
        $modName = $matches[1]
        $modVersion = $matches[2]
        
        return @{
            Name     = $modName
            Version  = $modVersion
            FullName = $Filename
        }
    }
    else {
        # If pattern doesn't match, just use the filename without extension as name
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Filename)
        return @{
            Name     = $baseName
            Version  = "unknown"
            FullName = $Filename
        }
    }
}

# Function to fetch mod files from GitHub repository
function Get-GitHubMods {
    param(
        [string]$RepoOwner = "JamalLyons",
        [string]$RepoName = "minecraft-server-scripts",
        [string]$Branch = "master",
        [string]$Path = "mods"
    )

    try {
        Write-ColorLog -Message "Fetching mod list from GitHub repository..." -Prefix "INFO"
        
        # GitHub API URL to get repository contents
        $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/$Path?ref=$Branch"
        
        # Make request to GitHub API
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        
        # Create array to store mod information
        $modsArray = @()
        
        # Process each file in the repository
        foreach ($item in $response) {
            if ($item.type -eq "file" -and $item.name -like "*.jar") {
                # Get mod name and version from filename
                $modInfo = Get-ModInfo -Filename $item.name
                
                # Create download URL for the file
                $downloadUrl = $item.download_url
                
                # Add to mods array
                $modsArray += @{
                    Name     = $modInfo.Name
                    Version  = $modInfo.Version
                    Filename = $item.name
                    Url      = $downloadUrl
                }
                
                Write-ColorLog -Message "Found mod: $($modInfo.Name) (Version: $($modInfo.Version))" -Prefix "INFO"
            }
        }
        
        return $modsArray
    }
    catch {
        Write-ColorLog -Message "Error fetching mods from GitHub: $_" -Prefix "ERROR"
        return @()
    }
}

# Function to get locally installed mods
function Get-LocalMods {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModsFolder
    )
    
    try {
        Write-ColorLog -Message "Checking for locally installed mods..." -Prefix "INFO"
        
        $localMods = @()
        
        # Get all jar files in the mods folder
        $jarFiles = Get-ChildItem -Path $ModsFolder -Filter "*.jar" -ErrorAction SilentlyContinue
        
        foreach ($file in $jarFiles) {
            $modInfo = Get-ModInfo -Filename $file.Name
            
            $localMods += @{
                Name     = $modInfo.Name
                Version  = $modInfo.Version
                Filename = $file.Name
                FullPath = $file.FullName
            }
            
            Write-ColorLog -Message "Found local mod: $($modInfo.Name) (Version: $($modInfo.Version))" -Prefix "INFO"
        }
        
        return $localMods
    }
    catch {
        Write-ColorLog -Message "Error checking local mods: $_" -Prefix "ERROR"
        return @()
    }
}

# Main script execution starts here
Write-ColorLog -Message "Minecraft Mod Installation Script" -ForegroundColor "Magenta" -Prefix "INFO"
Write-ColorLog -Message "This script will install Minecraft mods for your CurseForge profile." -Prefix "INFO"

# Get current username
$currentUser = [Environment]::UserName
Write-ColorLog -Message "Detected current user: $currentUser" -Prefix "INFO"

# Build the path to CurseForge instance
$curseForgeProfilePath = "C:\Users\$currentUser\curseforge\minecraft\Instances\Jamals-Mc-Profile"
$modsFolder = "$curseForgeProfilePath\mods"

# Check if CurseForge profile exists
if (-not (Test-Path $curseForgeProfilePath)) {
    Write-ColorLog -Message "CurseForge profile 'Jamals-Mc-Profile' not found at: $curseForgeProfilePath" -Prefix "ERROR"
    Write-ColorLog -Message "Please create a CurseForge profile named 'Jamals-Mc-Profile' and then run this script again." -Prefix "WARNING"
    Write-ColorLog -Message "Instructions:" -Prefix "INFO"
    Write-ColorLog -Message "1. Open CurseForge App" -Prefix "INFO"
    Write-ColorLog -Message "2. Go to Minecraft section" -Prefix "INFO"
    Write-ColorLog -Message "3. Click 'Create Custom Profile'" -Prefix "INFO"
    Write-ColorLog -Message "4. Name it exactly 'Jamals-Mc-Profile'" -Prefix "INFO"
    Write-ColorLog -Message "5. Select the appropriate Minecraft version" -Prefix "INFO"
    Write-ColorLog -Message "6. Run this script again once done" -Prefix "INFO"
    
    Read-Host "Press Enter to exit"
    exit
}

# Check if mods folder exists, create if not
if (-not (Test-Path $modsFolder)) {
    Write-ColorLog -Message "Mods folder not found. Creating folder at: $modsFolder" -Prefix "WARNING"
    
    $createFolder = Get-UserConfirmation "Would you like to create the mods folder?"
    if (-not $createFolder) {
        Write-ColorLog -Message "Installation cancelled. Exiting script." -Prefix "INFO"
        exit
    }
    
    try {
        New-Item -Path $modsFolder -ItemType Directory -Force | Out-Null
        Write-ColorLog -Message "Mods folder created successfully!" -Prefix "SUCCESS"
    }
    catch {
        Write-ColorLog -Message "Error creating mods folder: $_" -Prefix "ERROR"
        Read-Host "Press Enter to exit"
        exit
    }
}

# Fetch mods from GitHub repository
Write-ColorLog -Message "Fetching mods from GitHub repository..." -Prefix "INFO"
$githubMods = Get-GitHubMods

# Check if any mods were found
if ($githubMods.Count -eq 0) {
    Write-ColorLog -Message "No mods found in the GitHub repository. Check your connection or repository settings." -Prefix "ERROR"
    Read-Host "Press Enter to exit"
    exit
}

# Get locally installed mods
$localMods = Get-LocalMods -ModsFolder $modsFolder

# Confirm mod installation
Write-ColorLog -Message "Found $($githubMods.Count) mods in the GitHub repository" -Prefix "INFO"
Write-ColorLog -Message "Found $($localMods.Count) mods installed locally" -Prefix "INFO"

$installMods = Get-UserConfirmation "Do you want to synchronize your mods with the server? This will ensure you have the correct versions installed."
if (-not $installMods) {
    Write-ColorLog -Message "Installation cancelled. Exiting script." -Prefix "INFO"
    exit
}

# Process each mod from GitHub
$upToDateCount = 0
$updatedCount = 0
$newlyInstalledCount = 0
$failureCount = 0

foreach ($githubMod in $githubMods) {
    Write-ColorLog -Message "Processing mod: $($githubMod.Name) (Version: $($githubMod.Version))" -Prefix "INFO"
    
    # Check if mod exists locally
    $localMod = $localMods | Where-Object { $_.Name -eq $githubMod.Name }
    $outputPath = Join-Path -Path $modsFolder -ChildPath $githubMod.Filename
    
    # If local mod exists with same version, skip it
    if ($localMod -and $localMod.Version -eq $githubMod.Version) {
        Write-ColorLog -Message "Mod $($githubMod.Name) is already up to date (Version: $($githubMod.Version))" -Prefix "SUCCESS"
        $upToDateCount++
        continue
    }
    
    # If local mod exists with different version, remove it
    if ($localMod) {
        Write-ColorLog -Message "Different version of $($githubMod.Name) found locally (Local: $($localMod.Version), GitHub: $($githubMod.Version))" -Prefix "WARNING"
        
        try {
            Remove-Item -Path $localMod.FullPath -Force
            Write-ColorLog -Message "Removed outdated mod version: $($localMod.Filename)" -Prefix "SUCCESS"
        }
        catch {
            Write-ColorLog -Message "Error removing outdated mod file: $_" -Prefix "ERROR"
            $failureCount++
            continue
        }
    }
    
    # Download and install the mod
    $downloadResult = Download-File -Url $githubMod.Url -OutputPath $outputPath
    
    if ($downloadResult) {
        if ($localMod) {
            $updatedCount++
            Write-ColorLog -Message "Successfully updated $($githubMod.Name) to version $($githubMod.Version)" -Prefix "SUCCESS"
        }
        else {
            $newlyInstalledCount++
            Write-ColorLog -Message "Successfully installed $($githubMod.Name) (Version: $($githubMod.Version))" -Prefix "SUCCESS"
        }
    }
    else {
        $failureCount++
        Write-ColorLog -Message "Failed to install $($githubMod.Name)" -Prefix "ERROR"
    }
}

# Check for mods that exist locally but not in GitHub repository
$orphanedMods = $localMods | Where-Object { $githubMod = $githubMods | Where-Object { $_.Name -eq $localMod.Name }; -not $githubMod }

if ($orphanedMods.Count -gt 0) {
    Write-ColorLog -Message "Found $($orphanedMods.Count) mods installed locally that are not in the GitHub repository:" -Prefix "WARNING"
    
    foreach ($orphanedMod in $orphanedMods) {
        Write-ColorLog -Message "- $($orphanedMod.Name) (Version: $($orphanedMod.Version))" -Prefix "WARNING"
    }
    
    $removeOrphaned = Get-UserConfirmation "Would you like to remove these mods to stay in sync with the server?"
    
    if ($removeOrphaned) {
        $orphanedRemoved = 0
        
        foreach ($orphanedMod in $orphanedMods) {
            try {
                Remove-Item -Path $orphanedMod.FullPath -Force
                Write-ColorLog -Message "Removed orphaned mod: $($orphanedMod.Filename)" -Prefix "SUCCESS"
                $orphanedRemoved++
            }
            catch {
                Write-ColorLog -Message "Error removing orphaned mod file: $_" -Prefix "ERROR"
                $failureCount++
            }
        }
        
        Write-ColorLog -Message "Removed $orphanedRemoved orphaned mods" -Prefix "SUCCESS"
    }
    else {
        Write-ColorLog -Message "Orphaned mods were not removed" -Prefix "INFO"
    }
}

# Show installation summary
Write-ColorLog -Message "Installation Summary:" -Prefix "INFO"
Write-ColorLog -Message "$upToDateCount mods were already up to date" -Prefix "SUCCESS"
Write-ColorLog -Message "$updatedCount mods were updated to the correct version" -Prefix "SUCCESS"
Write-ColorLog -Message "$newlyInstalledCount new mods were installed" -Prefix "SUCCESS"
if ($failureCount -gt 0) {
    Write-ColorLog -Message "$failureCount mods failed to install or update" -Prefix "ERROR"
}

Write-ColorLog -Message "Mod installation process complete!" -ForegroundColor "Magenta" -Prefix "SUCCESS"
Write-ColorLog -Message "Your mods are now synchronized with the server" -Prefix "INFO"
Write-ColorLog -Message "You can now launch Minecraft through CurseForge and play with your friends!" -Prefix "INFO"

Read-Host "Press Enter to exit"
