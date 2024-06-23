#Prompt users to input device name 
$DeviceName = Read-Host "Enter the name of the device"

# Converts the name into a DHCP lease name.
$PC= $DeviceName + ".companyname.com"

# Putting DHCP server in a variable.
$DHCPServer = 'DHCPServer.com'
 
#Putting scope into a variable.
$scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer 

# The for loop goes through the scopes in the DHCP server looking for the IP. It is then put in a variable ($newDnsIP). 
$newDnsIp = foreach ($scope in $scopes){
 Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer | 
 Where-Object hostname -eq $PC | Select-Object -ExpandProperty IPAddress |
 select -ExpandProperty IPAddressToString
}

#The output of the for loop is converted into a string.
Out-String -InputObject $newDnsIp

# Taking the old dns entry and putting it into a variable.
$oldDnsEntry = Get-DnsServerResourceRecord -ComputerName dc1 -ZoneName companyname.com -Name $DeviceName

#Cloning the old dns entry into a variable(new dns entry).
$newDnsEntry = $oldDnsEntry.clone()

#Changing to IP of the new dns entry.
$newDnsEntry.RecordData.IPv4Address = [System.Net.IPAddress]::Parse($newDnsIp)

#Changing the DNS entry.
Set-DnsServerResourceRecord -NewInputObject $newDnsEntry -OldInputObject $oldDnsEntry -ZoneName companyname.com -ComputerName dc1