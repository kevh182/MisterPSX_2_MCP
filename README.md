# **  MiSTer PSX saves 2 MemCard Pro PS1   **

# **  Backup your data before use          **

# ** You will have to change the PowerShell execution policy on your machine for these scripts to work. **

More info on changing your PowerShell execution policy:

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-5.1

https://ss64.com/ps/set-executionpolicy.html

Alternatively, you could just copy the text of these scripts and paste it into Windows PowerShell ISE (or any text editor) and save it with a .ps1 extension.

Right click "PS1_MiSTer2MCP.ps1".  Click "Edit".  

PowerShell ISE opens.  Edit the following variables to match your local path (keep the ""):

> $logFile = " path \ to \logs \ $(Date)_PS1_MiSTer2MCP.log"

> $mcpBackup = " path \ to \Backup\MCP"

> $misterBackup = " path \ to \Backup\MiSTer"

PS1_MiSTer2MCP.ps1
1. Right click "Run with PowerShell"
2. Enter the path to your MiSTer saves
3. Enter the path to your MCP PS1 folder.
A log file is generated to see what files copied.

This script will create MemCardPro PS1 "Memory Cards" from your MiSTer PSX save files.  It will also create MiSTer save files from MemCardPro memory cards.

A few things to note:

This was only tested with MemCardPro 2.  I do not own MemCardPro 1 to test.  It "should work" with MemCardPro 1.

Timezone support is not included with this script.  The MemCardPro 2 creates file timestamps in GMT by default.  Depending on your timezone, the timestamps may be ahead or behind your timezone.  Memory cards generated by MemCard Pro may be "older" or "newer" than you may expect and cause files to be overwritten in the wrong direction.  Keep this in mind when running this script.  I tried my best to have the script backup files before overwriting.  Check the included "Backup" folder when in doubt.  Backup your data somewhere else before running this script.

This script was designed to use the "Redump" naming conventions for MiSTer save filenames.  This is required for the script to function correctly.  You can edit the "PS1_DB.csv" to match your filenames.  

You can easily add a game that is not included in "PS1_DB.csv".  Add a new row with the filename (without extension), its GameID (XXXX-12345), and MemCardPro filename (XXXX-12345-1.mcd).

 This script only creates one MemCardPro memory card channel - "XXXX-12345-1.mcd".  I do not have plans to add support for more than one MemCardPro memory card channel.
 
 When the script creates the MiSTer save, you may see multiple "revisions" of a game title.  For example, "Tomb Raider (USA) has 7 versions of the game that share the same GameID - SLUS-00152.  "SLUS-00152-1.mcd" will create the following: "Tomb Raider (USA).sav", "Tomb Raider (USA) (Rev 1).sav", "Tomb Raider (USA) (Rev 2).sav", "Tomb Raider (USA) (Rev 3).sav", "Tomb Raider (USA) (Rev 4).sav", "Tomb Raider (USA) (Rev 5).sav", and "Tomb Raider (USA) (Rev 6).sav" because they all share the same GameID.
 
 This is expected behavior.

Original Excel spreadsheet, "PS1_Database.xlsx", included so you can customize the "PS1_DB.csv" to your liking.
