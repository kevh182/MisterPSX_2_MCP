# PS1 MiSTer <--> MemCardPro

# Create timestamp for logging
function TimeStamp {
    
    return (Get-Date -Format "[yyyy-MM-dd--HH:MM:ss]" )  
}

function LogDate {

    return (Get-Date -Format "yyyy-MM-dd")
}

function DateTime {

   return (Get-Date -Format "yyyyMMdd_HHMMss")
}

# Set log file
$logFile = "$($pwd)\$(LogDate)_PS1_MiSTer2MCP.log"

# Path to PS1 CSV Database
$csv = Import-Csv "$($pwd)\PS1_DB.csv"

Write-Output "********************************************************************************"
Write-Output "                    PS1 MiSTer Saves <--> MemCard Pro                           "
Write-Output "********************************************************************************"
Write-Output "                     Backup your data before use!                               "
Write-Output "********************************************************************************"

Do {
        # Set the path to the directory containing your files
        $misterPSXFolder = Read-Host "Enter the Path to MiSTer Saves (PSX Folder)"
        $mcpFolder = Read-Host "Enter the Path to MemCard Pro PS1 folder (PS1 Folder)"
        $mcpPath = "$($mcpFolder)\$($gameID)"

        $mcpBackup = "$($pwd)\Backup\MCP"
        $misterBackup = "$($pwd)\Backup\MiSTer"

        # MiSTer save files
        $misterSaves = Get-ChildItem -path $misterPSXFolder -file

        # MemCardPro VMCs
        $mcpFileFolder = Get-ChildItem -path $mcpFolder -Recurse -file

            # Check if MiSTer PSX saves exist
            if ($misterSaves.exists){
                                  
                # Parse the CSV for data   
                foreach ($item in $csv){

                    # Get game title from CSV
                    $gameTitle = $item.redump_name
                    # Get gameID from CSV
                    $gameID = $item.Serial
                    # Get MemCardPro filename
                    $mcpFileName = $item.MCPFile

                    $mcpGameIDFolder = "$($mcpFolder)\$($gameID)"
                                
                        foreach ($file in $misterSaves){

                            if( $gameTitle -eq $file.basename ){

                                if (!(Test-Path "$($mcpGameIDFolder)")){

                                    Write-Output "$(Timestamp) MemCard Pro PS1 Save Created: $($file.Name) --> $($gameID)\$($mcpFileName)" | Tee-Object $logFile -Append
                                    cd($mcpFolder); New-Item -Name $gameID -ItemType Directory
                                    cd($misterPSXFolder);Copy-Item $file -Destination "$($mcpGameIDFolder)\$($mcpFileName)"

                                }      
                                                   
                                    foreach ($mcFile in $mcpFileFolder){

                                        if($mcpFileName -eq $mcFile.Name){
                                                                         
                                            if ($file.LastWriteTime -eq $mcFile.LastWriteTime) {

                                                Write-Output "$(TimeStamp) '$($file.Name)' and '$($mcFile.Name)' are the same."
                                                                        
                                            # MiSTer save file is newer than MemCardPro save file                 
                                            } elseif ($file.LastWriteTime -gt $mcFile.LastWriteTime ) {
                                            
                                                Write-Output "$(TimeStamp) '$($file.Name)' ($($file.LastWriteTime)) --> '$($mcFile.Name)' ($($mcFile.LastWriteTime))" | Tee-Object $logFile -Append

                                                # Backup found MemCardPro save file
                                                if (!(Test-Path "$($mcpBackup)\$(DateTime)")){

                                                    cd($mcpBackup); New-Item -Name DateTime -ItemType Directory
                                                    cd($mcpGameIDFolder); Copy-Item $mcFile -Destination "$($mcpBackup)\$(DateTime)" -Force
                                                    Write-Output "$(Timestamp) '$($mcFile)' backed up to $($misterBackup)\$(DateTime)" | Tee-Object $logFile -Append

                                                } 

                                                # Copy MiSTer save file and overwrite MemCardPro save file
                                                cd($misterPSXFolder); Copy-Item $file -Destination "$($mcpGameIDFolder)\$($mcpFileName)" -Force

                                            # MemCardPro save file is newer than MiSTer save file
                                            } elseif ($mcFile.LastWriteTime -gt $file.LastWriteTime) {

                                                Write-Output "$(Timestamp) '$($mcFile.Name)'($($mcFile.LastWriteTime)) --> '$($file.Name)' ($($file.LastWriteTime))" | Tee-Object $logFile -Append

                                                # Backup found MiSTer save file
                                                if (!(Test-Path "$($mcpBackup)\$(DateTime)")){

                                                    cd($misterBackup); New-Item -Name $(DateTime) -ItemType Directory
                                                    cd($misterPSXFolder); Copy-Item $file -Destination "$($misterBackup)\$(DateTime)" -Force
                                                    Write-Output "$(Timestamp) '$($file)' backed up to $($misterBackup)\$(DateTime)" | Tee-Object $logFile -Append

                                                }
                                               
                                                # Copy Memcard Pro Save and overwrite MiSTer save
                                                cd($mcpGameIDFolder); Copy-Item $mcFile -Destination "$($misterPSXFolder)\$($file.Name)" -Force
                                    } 
                                }
                            }
                        }
                    }
                }
            }
                                                            
    # Copy missing MCP saves from MiSTer directory.                                                                         
    foreach ($item in $csv){

        $gameTitle = $item.redump_name
        $gameID = $item.Serial
        $mcpFileName = $item.MCPFile
             
        $mcpGameIDFolder = "$($mcpFolder)\$($gameID)"
                                
            foreach ($mcFile in $mcpFileFolder){

                if($mcpFileName -eq $mcFile.Name){
                                    
                    cd($misterPSXFolder)
                    $sourceFile = "$($misterPSXFolder)\$($gameTitle).sav"
                    $destinationFile = $mcFile

                        if (!(test-path $destinationFile)) {
                                
                            Write-Output "$(Timestamp) MemCardPro save created: '$($gameTitle).sav' --> '$($mcFile.Name)'" | Tee-Object $logFile -Append
                            cd($misterPSXFolder); Copy-Item $sourceFile -Destination $destinationFile
                        }
                    }                
                } 
            }

    # Copy missing MiSTer files from MCP directory.
    foreach ($item in $csv){

        $gameTitle = $item.redump_name
        $gameID = $item.Serial
        $mcpFileName = $item.MCPFile
             
        $mcpGameIDFolder = "$($mcpFolder)\$($gameID)"
                                
            foreach ($mcFile in $mcpFileFolder){

                if($mcpFileName -eq $mcFile.Name){
                                
                    cd($mcpGameIDFolder)
                    $sourceFile = $mcFile
                    $destinationFile = "$($misterPSXFolder)\$($gameTitle).sav"

                        if (!(test-path $destinationFile)) {
                                
                            Write-Output "$(Timestamp) MiSTer save created: '$($mcFile.Name)' --> '$($gameTitle).sav'" | Tee-Object $logFile -Append
                            cd($mcpGameIDFolder); Copy-Item $sourceFile -Destination $destinationFile
                    }
                }                
            } 
        }

  } While ($true)