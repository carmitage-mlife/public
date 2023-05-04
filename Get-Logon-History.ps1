$Logs = @()

$events = get-winevent -LogName Microsoft-Windows-TerminalServices-LocalSessionManager/Operational | `
    ? {
    ($_.Id -like 21) -or `
    ($_.Id -like 23) -or `
    ($_.Id -like 24) -or `
    ($_.Id -like 25) -and `
    ($_.TimeCreated -gt  (Get-Date).adddays(-90))
    }
    
foreach ($event in $events) {
        #write-host "$($_.TimeCreated)`t$($_.Id)`t$($_.message.split("`n")[2])"
        switch ($event.Id) {
            21 {
                    $Logs += "$($event.TimeCreated)`tLogon`t`t$($event.message.split("`n")[2].replace("MFCGD\",''))"
                }
            23 {
                    $Logs += "$($event.TimeCreated)`tLogff`t`t$($event.message.split("`n")[2].replace("MFCGD\",''))"
                }
            24 {
                    $Logs += "$($event.TimeCreated)`tDisconnect`t$($event.message.split("`n")[2].replace("MFCGD\",''))"
                }
            25 {
                    $Logs += "$($event.TimeCreated)`tReconnect`t$($event.message.split("`n")[2].replace("MFCGD\",''))"
                }
        }
}
"===Current Sessions===" | out-file c:\temp\VM-Access-Log.log -force
quser | out-file c:\temp\VM-Access-Log.log -append -force
"`n===Connect History===" | out-file c:\temp\VM-Access-Log.log -append -force
"Time`t`t`tEvent`t`tUser" | out-file c:\temp\VM-Access-Log.log -append -force
$Logs | sort -Descending -unique | out-file c:\temp\VM-Access-Log.log -Append -force