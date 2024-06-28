$DeviceName = Read-Host "Enter the name of the device" 
$PC= $DeviceName + ".domain.com"
$DHCPServer = 'dhcpserver.com'


$scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer

#Get Scope
$newScope = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ScopeID

   }

#Infomative
write-host "The scope for" $PC "is" $newScope


#Converts to system IP format
$TheScope = [System.Net.IPAddress]$newScope.Trim()


#Get IP
$IP = foreach ($scope in $scopes){

 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty IPAddress 

   }
#Informative
write-host "The IP for" $PC "is" $IP

#Converts to system IP format
$newIP = [System.Net.IPAddress]$IP.Trim()
 
#Get Mac
$Mac = foreach ($scope in $scopes){
 
    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
        Where-Object hostname -eq $PC | 
            Select-Object -ExpandProperty ClientID 
       
   }
#Informative
write-host "The Mac for" $PC "is" $Mac
