# PS1 MiSTer <--> MemCardPro


function TimeStamp {
    
    return (Get-Date -Format "[yyyy-MM-dd--HH:MM:ss]" )  
}

function Date {

    return (Get-Date -Format "yyyy-MM-dd")
}

function DateTime {

   return (Get-Date -Format "yyyyMMdd_HHMMss")
}

#=============================
# Set log file
#=============================
$logFile = "path\to\logs\$(Date)_PS1_MiSTer2MCP.log"

#=============================
# Path to PS1 CSV Database
#=============================
$csv = Import-Csv .\PS1_DB.csv

Write-Output "********************************************************************************"
Write-Output "                    PS1 MiSTer Saves <--> MemCard Pro                           "
Write-Output "********************************************************************************"
Write-Host   "                     Backup your data before use!                               " -ForegroundColor DarkRed
Write-Output "********************************************************************************"
Write-Host "Log File: $($logFile)" -ForegroundColor DarkYellow
Write-Output "********************************************************************************"

#=============================
# MCP backup folder
#=============================
$mcpBackup = "path\to\Backup\MCP"

#=============================
# MiSTer backup folder
#=============================
$misterBackup = "path\to\Backup\MiSTer"

Do {
        #=====================================================
        # Set the path to the directory containing your files
        #=====================================================
        $misterPSXFolder = Read-Host "Enter the Path to MiSTer Saves (PSX Folder)"
        $mcpFolder = Read-Host "Enter the Path to MemCard Pro PS1 folder (PS1 Folder)"
        
        $mcpPath = "$($mcpFolder)\$($gameID)"

        #=============================
        # MiSTer save files
        #=============================
        $misterSaves = Get-ChildItem -path $misterPSXFolder -file

        #=============================
        # MemCardPro VMCs
        #=============================
        $mcpSaves = Get-ChildItem -path $mcpFolder -Recurse -file
        
            #=============================
            # Parse the CSV for data
            #=============================
            foreach ($item in $csv){

                #=============================
                # Get game title from CSV
                #=============================
                $gameTitle = $item.redump_name

                #=============================
                # Get gameID from CSV
                #=============================
                $gameID = $item.serial

                #=============================
                # Get MemCardPro filename
                #=============================
                $mcpFileName = $item.MCPFile

                #=============================
                # MemCardPro folder structure
                #=============================
                $mcpGameIDDst = "$($mcpFolder)\$($gameID)"

                    foreach ($misterFile in $misterSaves){

                        if( $gameTitle -eq $misterFile.basename ){
                                                   
                            foreach ($mcpFile in $mcpSaves){
                     
                                if($mcpFileName -eq $mcpFile.Name){
                        
                                    #====================================================
                                    # MiSTer save is the same as MemCardPro save
                                    #====================================================
                                    if ($misterFile.LastWriteTime -eq $mcpFile.LastWriteTime){

                                        Write-Output "$(TimeStamp)[No Change]: '$($misterFile.Name)' and '$($mcpFile.Name)' are the same."

                                    }
                                                                                           
                                    #====================================================
                                    # MiSTer save file is newer than MemCardPro save file
                                    #====================================================
                                    if ($misterFile.LastWriteTime -gt $mcpFile.LastWriteTime ) {

                                        #===================================   
                                        # Backup found MemCardPro save file
                                        #===================================
                                        if (!(Test-Path "$($mcpBackup)\$(Date)")){

                                            cd($mcpBackup); New-Item -Name $(Date) -ItemType Directory

                                        }

                                        Write-Host "$(Timestamp)[MemCardPro Backup]: --> $(DateTime)_$($gameTitle)_$($mcpFile)" -ForegroundColor DarkGreen
                                        Write-Output "$(Timestamp)[MemCardPro Backup]: --> $(DateTime)_$($gameTitle)_$($mcpFile)" | Out-File $logFile -Append
                                        cd($mcpGameIDDst); Copy-Item $mcpFile -Destination "$($mcpBackup)\$(Date)\$(DateTime)_$($gameTitle)_$($mcpFile)" -Force

                                    #=========================================================
                                    # Copy MiSTer save file and overwrite MemCardPro save file
                                    #=========================================================
                                    
                                    Write-Host "$(TimeStamp)[MemCardPro Overwrite]: '$($misterFile.Name)' ($($misterFile.LastWriteTime)) --> '$($mcpFile.Name)' ($($mcpFile.LastWriteTime))" -ForegroundColor DarkYellow
                                    Write-Output "$(TimeStamp)[MemCardPro Overwrite]: '$($misterFile.Name)' ($($misterFile.LastWriteTime)) --> '$($mcpFile.Name)' ($($mcpFile.LastWriteTime))" | Out-File $logFile -Append
                                    cd($misterPSXFolder); Copy-Item $misterFile -Destination "$($mcpGameIDDst)\$($mcpFileName)" -Force

                                    }

                                    #====================================================
                                    # MemCardPro save file is newer than MiSTer save file
                                    #====================================================        
                                    if ($mcpFile.LastWriteTime -gt $misterFile.LastWriteTime) {
                                        
                                        #===============================
                                        # Backup found MiSTer save file
                                        #===============================
                                        if (!(Test-Path "$($misterBackup)\$(Date)")){

                                            cd($misterBackup); New-Item -Name $(Date) -ItemType Directory
                                        }

                                    Write-Host "$(Timestamp)[MiSTer Backup]: --> $(DateTime)_$($gameID)_$($misterFile)" -ForegroundColor DarkGreen
                                    Write-Output "$(Timestamp)[MiSTer Backup]: --> $(DateTime)_$($gameID)_$($misterFile)" | Out-File $logFile -Append
                                    cd($misterPSXFolder); Copy-Item $misterFile -Destination "$($misterBackup)\$(Date)\$(DateTime)_$($gameID)_$($misterFile)" -Force

                                #=================================================    
                                # Copy Memcard Pro Save and overwrite MiSTer save
                                #=================================================

                                Write-Host "$(Timestamp)[MiSTer Overwrite]: '$($mcpFile.Name)'($($mcpFile.LastWriteTime)) --> '$($misterFile.Name)' ($($misterFile.LastWriteTime))" -ForegroundColor DarkYellow
                                Write-Output "$(Timestamp)[MiSTer Overwrite]: '$($mcpFile.Name)'($($mcpFile.LastWriteTime)) --> '$($misterFile.Name)' ($($misterFile.LastWriteTime))" | Out-File $logFile -Append
                                cd($mcpGameIDDst); Copy-Item $mcpFile -Destination "$($misterPSXFolder)\$($misterFile.Name)" -Force

                                    }
                                }
                            }
                        }
                    }
            }


        #====================================================
        # Copy missing MiSTer files from MCP directory.
        #====================================================
        foreach ($item in $csv){

            $gameTitle = $item.redump_name
            $gameID = $item.serial
            $mcpFileName = $item.MCPFile

            if(![string]::IsNullOrEmpty($gameID)){
             
                $mcpGameIDDst = "$($mcpFolder)\$($gameID)"
                                
                    foreach ($mcpFile in $mcpSaves){
                
                        if($mcpFileName -eq $mcpFile.Name){
                                
                            if (!(Test-Path "$($misterPSXFolder)\$($gameTitle).sav")) {
                                
                                Write-Host "$(Timestamp)[MiSTer Create]: '$($mcpFile.Name)' --> '$($gameTitle).sav'" -ForegroundColor DarkGreen                              
                                Write-Output "$(Timestamp)[MiSTer Create]: '$($mcpFile.Name)' --> '$($gameTitle).sav'" | Out-File $logFile -Append
                                cd($mcpGameIDDst); Copy-Item $mcpFile -Destination "$($misterPSXFolder)\$($gameTitle).sav"
                            }

                        }                
                    }
            } 
        }

    #====================================================
    # Copy missing MCP saves from MiSTer directory
    #====================================================                                                                      
    foreach ($item in $csv){

        $gameTitle = $item.redump_name
        $gameID = $item.serial
        $mcpFileName = $item.MCPFile

        if(![string]::IsNullOrEmpty($gameID)){
             
            $mcpGameIDFolder = "$($mcpFolder)\$($gameID)"
                                
                foreach ($misterFile in $misterSaves){
            
                    if($gameTitle -eq $misterFile.BaseName){
                                    
                        $sourceFile = "$($misterPSXFolder)\$($misterFile.Name)"
                        $destinationFile = "$($mcpFolder)\$($gameID)\$($mcpFileName)"

                            if (!(Test-Path $destinationFile)) {

                                if (!(Test-Path $mcpGameIDFolder)){
                            
                                    cd($mcpFolder); New-Item -Name $($gameID) -ItemType Directory

                                }

                            Write-Host "$(Timestamp)[MemCardPro Create]: '$($gameTitle).sav' --> '$($mcpFileName)'" -ForegroundColor DarkGreen
                            Write-Output "$(Timestamp)[MemCardPro Create]: '$($gameTitle).sav' --> '$($mcpFileName)'" | Out-File $logFile -Append
                            cd($misterPSXFolder); Copy-Item $sourceFile -Destination $destinationFile
                    }
                }
            }
        }
    }

} While ($true)