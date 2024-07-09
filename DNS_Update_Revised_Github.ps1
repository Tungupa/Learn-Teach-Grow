#The purpose of this scrip is to update the DNS record of a device.

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
Write-Host "   This script is used to update a device's DNS record. "
Write-Host " "
Write-Host "            Information Required"
Write-Host "   1.The dhcp server for the device needs to be selected. "
Write-Host "   2.The device name needs to be entered."
Write-Host " "
Write-Host " "
Write-Host  "  [0]............." $DHCPServer[0]
Write-Host  "  [1]............." $DHCPServer[1]
Write-Host  "  [2]............." $DHCPServer[2] 
Write-Host  "  [3]............." $DHCPServer[3] 


#A while loop that allows users to do more then one update
$Menu = "N"
while($Menu -ne "y"){

#Error checking for selecting the dhcp server.

Write-Host " "
Do { $ServerSelection = Read-host "Enter a number between 0 and 34 to select a server"}
while ((0..34) -notcontains $ServerSelection)

#Putting the users selected server into a variable.
$DHCP = $DHCPServer[$ServerSelection]
Write-Host " "
Write-Host "The dhcp server" $DHCP "has been selected."-ForegroundColor Yellow
Write-Host " "
Write-Host " "


#Error checking for entering the device name.
$DeviceName = "Can be anything that is not an int. This activates the while loop." 
while ($DeviceName -isnot [int]){
    Try{
        [int]$DeviceName = Read-Host "Enter the device number (without the K)"    
    }
    Catch{
        Write-Host " "
        Write-Host "Please use the asset # WITHOUT the K." -ForegroundColor Red
        Write-Host " "
    }
}

#Converting data type from int32 to string.
[string]$DeviceName = $DeviceName

#Formatting device name to DHCP name.
$DeviceName = "K" + $DeviceName 
$PC= $DeviceName + ".knapheide.com"
Write-Host " "

#Notify user about progress.
Write-Host "   Updating" -ForegroundColor Yellow
Write-Host " "

#Going through the scopes to select correct device IP address.
$scopes = Get-DhcpServerv4Scope -ComputerName $DHCP
$newDnsIp = foreach ($scope in $scopes){ 
 Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | Where-Object hostname -eq $PC | Select-Object -ExpandProperty IPAddress 
}

#Error checking for the returned IP.
if($newDnsIp -isnot [string]){

    #If a null or anything else is return, it shows this message.
    Write-Host "   Update Completed: " -ForegroundColor Yellow
    Write-Host " "
    Write-Host "   IP not found. DNS record has NOT been updated." -ForegroundColor Red
    Write-Host " "
    Write-Host "   Here are a couple of helpful tips: "
    Write-Host " "
    Write-Host "   1. Check if there is a typo in the asset number."
    Write-Host "   2. The device could be offline." 
    Write-Host "   3. Try a different DHCP Server."  
    Write-Host " "
}
else {
   
#Creating a new DNS record.
$oldDnsEntry = Get-DnsServerResourceRecord -ComputerName dc1 -Name $DeviceName -ZoneName knapheide.com -RRType "A"
$newDnsEntry = Get-DnsServerResourceRecord -ComputerName dc1 -Name $DeviceName -ZoneName knapheide.com -RRType "A"
$newDnsEntry.RecordData.IPv4Address = [System.Net.IPAddress]::parse($newDnsIp)

#Setting the new DNS record.
Set-DnsServerResourceRecord -NewInputObject $newDnsEntry -OldInputObject $oldDnsEntry -ZoneName knapheide.com -ComputerName dc1


Write-Host " "
Write-Host "   Update Completed: "-ForegroundColor Green
Write-Host " "
Write-Host "   DNS record for "$DeviceName" has been updated." -ForegroundColor Green
Write-Host " "
Write-Host "   New IP used to update" $DeviceName"'s DNS record is: " $newDnsIp"." -ForegroundColor Green
Write-Host " "
}

 $Menu = Read-Host "Type y to exit or any key to continue"
}
