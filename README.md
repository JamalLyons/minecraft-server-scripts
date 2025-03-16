# My Minecraft server scripts

Scripts to help setup your Minecraft client for joining my server. If you want to join the server, ask me for the IP.

## Server info:

- IP: `mc.jamallyons.com`
- MC Version: `1.21.4`
- Mod Loader: `forge`

## Mods

This repository contains all the mods needed to play on my Minecraft server. You can install them in two ways:

### Option 1: Automated Installation (Recommended)

If you're on Windows, you can use my [PowerShell script](./scripts/install-mods.ps1) to automatically install all the required mods:

1. **Prerequisites**:

   - Install [CurseForge](https://www.curseforge.com/download/app) if you haven't already
   - Make sure PowerShell is allowed to run scripts on your computer (you may need to run `Set-ExecutionPolicy RemoteSigned` in an admin PowerShell)

2. **Setup CurseForge**:

   - Open CurseForge app
   - Go to the Minecraft section
   - Click "Create Custom Profile"
   - Name it exactly `Jamals-Mc-Profile` (important!)
   - Select Minecraft version `1.21.4` and Forge as the mod loader

3. **Run the Script**:
   - Download this repository (Code → Download ZIP)
   - Extract the ZIP file
   - Right-click the `install-mods.ps1` script in the `scripts` folder
   - Select "Run with PowerShell"
   - Follow the on-screen instructions

The script will:

- Check if you have the correct CurseForge profile
- Download all required mods from this repository
- Update any outdated mods
- Remove any incompatible mods

### Option 2: Manual Installation

If you prefer to install the mods manually:

1. Download this repository as a ZIP file
2. Extract the ZIP file
3. Copy all JAR files from the `mods` folder
4. Paste them into your CurseForge mods folder (typically located at `C:\Users\<your-username>\curseforge\minecraft\Instances\<your-profile>\mods`)

## Troubleshooting

- **Script can't find CurseForge profile**: Make sure you've created a profile named exactly `Jamals-Mc-Profile` in CurseForge
- **Minecraft crashes**: Make sure you have the correct Minecraft version (1.21.4) and Forge installed
- **Script permission errors**: Run PowerShell as administrator and execute `Set-ExecutionPolicy RemoteSigned`

## Joining the server

Once you have all the mods installed:

1. Launch Minecraft through the CurseForge app using the `Jamals-Mc-Profile` profile
2. Click "Multiplayer"
3. Click "Add Server"
4. Enter the server IP (ask me for it)
5. Join and have fun!

## Need help?

If you encounter any issues, feel free to reach out to me directly or open an issue on this repository.
