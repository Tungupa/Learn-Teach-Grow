$DeviceName = Read-Host "Enter the name of the device" 
$PC= $DeviceName + ".domainname.com"
$DHCPServer = 'dhcpserver.com'


$scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer

#Get Scope
$newScope = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ScopeID #| 
                #Select-Object -ExpandProperty IPAddressToString

   }

#Convert to IP format
write-host "The scope for" $PC "is" $newScope

$TheScope = [System.Net.IPAddress]$newScope.Trim()


#Get IP
$IP = foreach ($scope in $scopes){

 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty IPAddress #| 
                #Select-Object -ExpandProperty IPAddressToString

   }
#Convert to IP format

write-host "The IP for" $PC "is" $IP
$newIP = [System.Net.IPAddress]$IP.Trim()
 
#Get Mac
$Mac = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ClientID 
       
   }
#Converts to String
write-host "The Mac for" $PC "is" $Mac


#Set Reservation

Add-DhcpServerv4Reservation -ScopeId $TheScope -IPAddress $newIP -ClientID $Mac -ComputerName $DHCPServer 



