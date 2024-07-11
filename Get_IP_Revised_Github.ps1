
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
Write-Host " "
Write-Host " "
Write-Host "           This script is used to get the Scope, IP and MAC of a device. " -ForegroundColor Yellow
Write-Host " "
Write-Host " "
Write-Host "                              Important Information" -ForegroundColor Yellow
Write-Host "                              ---------------------- "
Write-Host "                                                                           `n
            There are two ways to search for a device's IP. If you know the DHCP server, `n
            it is faster to select the server name and search for that device there. `n
            If you do not know what server the device is located in, a global search is `n
            your only option. `n
            Just note that the global search searches each scope on the 34 DHCP servers.`n
            This search takes about 5 minutes to complete." -ForegroundColor Yellow
Write-Host "  "
Write-Host "  "

#A while loop that allows users to do more then one search
$Menu = "N"
while($Menu -ne "y")
{

    #Error checking for user input
    Write-Host "            Main Menu" -ForegroundColor Blue
    Write-Host "            ---------"
    Write-Host " "
    Do { $UserChoice = Read-host "            Type 1 to select a server, or 2 to do a global search"}
    while ((1..2) -notcontains $UserChoice)
    
    #Shows the user the list of servers when 1 is selected.
    if ($UserChoice -eq 1)
    {

        Write-Host " "
        Write-Host "            Information Required" -ForegroundColor Yellow
        Write-Host "            ---------------------- "
        Write-Host "            1.The dhcp server for the device needs to be selected. "-ForegroundColor Yellow
        Write-Host "            2.The device name needs to be entered (without the K)." -ForegroundColor Yellow
        Write-Host " "
        Write-Host " "
        Write-Host  "            [0]............." $DHCPServer[0] -ForegroundColor Yellow
        Write-Host  "            [1]............." $DHCPServer[1] -ForegroundColor Yellow
        Write-Host  "            [2]............." $DHCPServer[2] -ForegroundColor Yellow
        Write-Host  "            [3]............." $DHCPServer[3] -ForegroundColor Yellow


        #Error checking for selecting the dhcp server.
        Write-Host " "
        Do { $ServerSelection = Read-host "            Enter a number between 0 and 34 to select a server"}
        while ((0..34) -notcontains $ServerSelection)

        #Putting the users selected server into a variable.
        $DHCP = $DHCPServer[$ServerSelection]
        Write-Host " "
        Write-Host "            The dhcp server" $DHCP "has been selected."-ForegroundColor Green
        Write-Host " "
        Write-Host " "

        #Error checking for entering the device name.
        $DeviceName = "Can be anything that is not an int. This activates the while loop." 
        while ($DeviceName -isnot [int]){
            Try{
                [int]$DeviceName = Read-Host "            Enter the device number (without the K)"    
            }
            Catch{
                Write-Host " "
                Write-Host "            Please use the asset # WITHOUT the K." -ForegroundColor Red
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
        Write-Host "            Searching....." -ForegroundColor Yellow

        #Putting the scope into a variable
        $scopes = Get-DhcpServerv4Scope -ComputerName $DHCP

        #Get Scope
        $newScope = foreach ($scope in $scopes){
            Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
                Where-Object hostname -eq $PC | 
                    Select-Object -ExpandProperty ScopeID

        }

        #Error checking for the scope returned.
        if($newScope -isnot [string])
        {

            #If a null or anything else that is not a string is return, it shows this message.
            Write-Host " "
            Write-Host "            Awe Snap! " -ForegroundColor Yellow
            Write-Host "                         _____________   " -ForegroundColor Red
            Write-Host "                        /             \ " -ForegroundColor Red
            Write-Host "                       /               \ " -ForegroundColor Red
            Write-Host "                      /   ____\  /_____ \ " -ForegroundColor Red
            Write-Host "                     /   |_*__|  |_*__|  \ " -ForegroundColor Red
            Write-Host "                     |         V         | " -ForegroundColor Red
            Write-Host "                      \     _______     / " -ForegroundColor Red
            Write-Host "                       \   |_______|   / " -ForegroundColor Red
            Write-Host "                        \             / " -ForegroundColor Red
            Write-Host "                         \           / " -ForegroundColor Red
            Write-Host "                         |___________| " -ForegroundColor Red
            Write-Host " "
            Write-Host "            Device not found." -ForegroundColor Red
            Write-Host " "
            Write-Host "            Here are a couple of helpful tips: " -ForegroundColor Blue
            Write-Host " "
            Write-Host "            1. Check if there is a typo in the asset number." -ForegroundColor Blue
            Write-Host "            2. The device could be offline." -ForegroundColor Blue
            Write-Host "            3. Try a different DHCP Server."  -ForegroundColor Blue
            Write-Host " "
            Write-Host " "
            $Menu = Read-Host "            Type y to exit or any key to continue to main menu"
            Write-Host " "
            
        }
        else
        {

            #Infomative
            Write-Host " " 
            write-host "            The scope for" $PC "is:      " $newScope -ForegroundColor Green

            #Get IP
            $IP = foreach ($scope in $scopes)
            {
                Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
                    Where-Object hostname -eq $PC | 
                        Select-Object -ExpandProperty IPAddress 
            }
            #Informative
            Write-Host " " 
            write-host "            The IP for" $PC "is:         " $IP -ForegroundColor Green
            
            #Get Mac
            $Mac = foreach ($scope in $scopes)
            {
            
                Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCP | 
                    Where-Object hostname -eq $PC | 
                        Select-Object -ExpandProperty ClientID       
            }

            #Informative
            Write-Host " " 
            write-host "            The Mac for" $PC "is:        " $Mac -ForegroundColor Green
            Write-Host " "

            Write-Host " "
            $Menu = Read-Host "            Type y to exit or any key to continue to main menu"
            Write-Host " "
        
        }
    }

    else
    {
        
        #**************************************SEARCHING ALL DHCP SERVERS FOR THE DEVICE******************************
        #Error checking for entering the device name.
        Write-Host " "
        Write-Host " "
        $DeviceName = "Can be anything that is not an int. This activates the while loop." 
        while ($DeviceName -isnot [int])
        {
            Try
            {
                [int]$DeviceName = Read-Host "            Enter the device number (without the K)"    
            }
            Catch
            {
                Write-Host " "
                Write-Host "            Please use the asset # WITHOUT the K." -ForegroundColor Red
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
        Write-Host " "
        Write-Host "            Searching.......It may take up to 5 minutes." -ForegroundColor Yellow
        Write-Host " "
        Write-Host " "
        
        #Initializing dhcp server from Scope serarch
        [int]$Server = 0
        #Get Scope
        while($GlobalnewScope -isnot [string]) 
        {
            $scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer[$Server] 
            $GlobalnewScope = foreach ($scope in $scopes){
            Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer[$Server] | 
                Where-Object hostname -eq $PC | 
                    Select-Object -ExpandProperty ScopeID
            }

            $Server = $Server + 1

            if($null -eq $DHCPServer[$Server])
            {

            #If a null or anything else is return, it shows this message.
            Write-Host " "
            Write-Host "            Awe Snap! " -ForegroundColor Yellow
            Write-Host "                         _____________   " -ForegroundColor Red
            Write-Host "                        /             \ " -ForegroundColor Red
            Write-Host "                       /               \ " -ForegroundColor Red
            Write-Host "                      /   ____\  /_____ \ " -ForegroundColor Red
            Write-Host "                     /   |_*__|  |_*__|  \ " -ForegroundColor Red
            Write-Host "                     |         V         | " -ForegroundColor Red
            Write-Host "                      \     _______     / " -ForegroundColor Red
            Write-Host "                       \   |_______|   / " -ForegroundColor Red
            Write-Host "                        \             / " -ForegroundColor Red
            Write-Host "                         \           / " -ForegroundColor Red
            Write-Host "                         |___________| " -ForegroundColor Red
            Write-Host " "
            Write-Host "            Device not found." -ForegroundColor Red
            Write-Host " "
            Write-Host "            Here are a couple of helpful tips: " -ForegroundColor Blue
            Write-Host " "
            Write-Host "            1. Check if there is a typo in the asset number." -ForegroundColor Blue
            Write-Host "            2. The device could be offline." -ForegroundColor Blue
            Write-Host "            3. Try a different DHCP Server."  -ForegroundColor Blue
            Write-Host " "

                $GlobalnewScope = "1.1.1.1" # To break the while loop if null is returned.

            }    
        } #  While loop end

        # If  $GlobalnewScope = 1.1.1.1 it takes user to the menu, else it moves forward with 
        # finding the IP and MAC of the device.
        if($GlobalnewScope -eq "1.1.1.1" )
        {

            Write-Host " "
            $Menu = Read-Host "            Type y to exit or any key to continue to main menu"
            Write-Host " "
        }
        else
        {
            #Infomative
            write-host "            The scope for" $PC "is:      " $GlobalnewScope -ForegroundColor Green
            Write-Host " "

            #Initializing dhcp server from IP search
            [int]$Server = 0
            #Get IP
            while($GlobalIP -isnot [string])
            {
                $scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer[$Server]
                $GlobalIP = foreach ($scope in $scopes){
                    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer[$Server] | 
                        Where-Object hostname -eq $PC | 
                            Select-Object -ExpandProperty IPAddress   
                }
            $Server = $Server + 1
            }
            #Informative
            write-host "            The IP for" $PC "is:         " $GlobalIP -ForegroundColor Green
            Write-Host " "

            #Initializing dhcp server from MAC search
            [int]$Server = 0
            #Get MAC
            while($GlobalMac -isnot [string])
            {
                $scopes = Get-DhcpServerv4Scope -ComputerName $DHCPServer[$Server]
                $GlobalMac = foreach ($scope in $scopes){
                    Get-DhcpServerv4Lease -ScopeId $scope.ScopeID -ComputerName $DHCPServer[$Server] | 
                        Where-Object hostname -eq $PC | 
                            Select-Object -ExpandProperty ClientID
                }
            $Server = $Server + 1
            }
            #Informative
            write-host "            The Mac for" $PC "is:        " $GlobalMac -ForegroundColor Green



            #Menu End
            Write-Host " "
            $Menu = Read-Host "            Type y to exit or any key to continue to main menu"
            Write-Host " "
        }    
        #Reseting the variable $GlobalnewScope to null
        $GlobalnewScope = $null

    } # Global Search 'else' end
        

}
