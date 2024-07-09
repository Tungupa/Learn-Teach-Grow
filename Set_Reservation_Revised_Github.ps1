# Putting the DCHP servers into variables.
$DHCPS1 = "company.servername.com"
$DHCPS2 = "company.servername.com"
$DHCPS3 = "company.servername.com"
$DHCPS4 = "company.servername.com"

#Putting the variables into an array
$DHCPServer = @(
$DHCPS1,
$DHCPS2,
$DHCPS3,
$DHCPS4
)

#Output the option to select a server to the user.
Write-Host " "

Write-Host " "
Write-Host "   This script is used to set the DHCP reservation of a device. " -ForegroundColor Yellow
Write-Host " "
Write-Host "   Information Required" -ForegroundColor Yellow
Write-Host "   ---------------------- "
Write-Host "   1.The dhcp server for the device needs to be selected. "-ForegroundColor Yellow
Write-Host "   2.The device name needs to be entered." -ForegroundColor Yellow
Write-Host " "
Write-Host " "
Write-Host  "  [0]............." $DHCPServer[0] -ForegroundColor Yellow
Write-Host  "  [1]............." $DHCPServer[1] -ForegroundColor Yellow
Write-Host  "  [2]............." $DHCPServer[2] -ForegroundColor Yellow
Write-Host  "  [3]............." $DHCPServer[3] -ForegroundColor Yellow


#A while loop that allows users to do more then one update
$Menu = "N"
while($Menu -ne "y"){

#Error checking for selecting the dhcp server.

Write-Host " "
Do { $ServerSelection = Read-host "   Enter a number between 0 and 34 to select a server"}
while ((0..34) -notcontains $ServerSelection)

#Putting the users selected server into a variable.
$DHCP = $DHCPServer[$ServerSelection]
Write-Host " "
Write-Host "   The dhcp server" $DHCP "has been selected."-ForegroundColor Yellow
Write-Host " "
Write-Host " "

#Error checking for entering the device name.
$DeviceName = "Can be anything that is not an int. This activates the while loop." 
while ($DeviceName -isnot [int]){
    Try{
        [int]$DeviceName = Read-Host "   Enter the device number"    
    }
    Catch{
        Write-Host " "
        Write-Host "   Please use the asset #." -ForegroundColor Red
        Write-Host " "
    }
}

#Converting data type from int32 to string.
[string]$DeviceName = $DeviceName

#Formatting device name to DHCP name.

$PC= $DeviceName + ".companydomain.com"
Write-Host " "

#Notify user about progress.
Write-Host "   Updating" -ForegroundColor Yellow

$scopes = Get-DhcpServerv4Scope -ComputerName $DHCP

#Get Scope
$newScope = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ScopeID

   }

#Error checking for the scope returned.
if($newScope -isnot [string]){

    #If a null or anything else is return, it shows this message.
    Write-Host "   Update Completed: " -ForegroundColor Yellow
    Write-Host " "
    Write-Host "   Scope not found. Reservation not set." -ForegroundColor Red
    Write-Host " "
    Write-Host "   Here are a couple of helpful tips: "
    Write-Host " "
    Write-Host "   1. Check if there is a typo in the asset number."
    Write-Host "   2. The device could be offline." 
    Write-Host "   3. Try a different DHCP Server."  
    Write-Host " "
}
else {

#Infomative
Write-Host " " 
write-host "   The scope for" $PC "is" $newScope -ForegroundColor Green

#Converts to system IP format
$TheScope = [System.Net.IPAddress]$newScope.Trim()

#Get IP
$IP = foreach ($scope in $scopes){
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty IPAddress 
   }
#Informative
Write-Host " " 
write-host "   The IP for" $PC "is" $IP -ForegroundColor Green

#Converts to system IP format
$newIP = [System.Net.IPAddress]$IP.Trim()
 
#Get Mac
$Mac = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ClientID       
   }

#Informative
Write-Host " " 
write-host "   The Mac for" $PC "is" $Mac -ForegroundColor Green

#Set Reservation
$Reserve = Add-DhcpServerv4Reservation -ScopeId $TheScope -IPAddress $newIP -ClientID $Mac -ComputerName $DHCP -erroraction 'silentlycontinue' |
    Select-Object -ExpandProperty IPAddress


if($Reserve -eq $newIP){
    Write-Host " " 
    Write-Host "   Reservation has been set."-ForegroundColor Green
}
else {
    Write-Host " "
    Write-Host "   Resrvation already exist."-ForegroundColor Yellow
}

} #else end

Write-Host " "
$Menu = Read-Host "   Type y to exit or any key to continue"
Write-Host " "
}

