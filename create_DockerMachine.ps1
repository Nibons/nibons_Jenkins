#docker setup for WCF tester
$machineName = 'docker1'
$docker_InstallationPath = 'C:\Program Files\Docker Toolbox'
$docker_MachineDirectoryPath = 'C:\Users\chaertzen\.docker\machine\machines\'

function new-DockerMachine{
[cmdletbinding(supportsShouldProcess)]
Param(
    [Parameter(mandatory)]
    [string[]]$name = 'boot2docker',
    [string]$computername = $env:computername,
    [int]$memory = 1024,#amount is in MB
    [string]$vmSwitch = (Get-VMSwitch -SwitchType External,Internal | sort-object SwitchType | select-object -first 1 -ExpandProperty Name),
    [string]$driver = 'hyperv', #should support other driver types at some point
    [switch]$asJob    
)
Begin{    
    $scriptblock = {
        Param($name,$memory,$vmswitch,$driver)
        docker-machine create --driver $driver --hyperv-virtual-switch $vmswitch --hyperv-memory $memory $name
        docker-machine regenerate-certs --force $Name
    }
}
Process{
    foreach($n in $name){
        if(!$WhatIfPreference){Invoke-Command -ScriptBlock $scriptblock -ArgumentList $n,$memory,$vmswitch,$driver}
        #if(!$WhatIfPreference){Invoke-Command -ScriptBlock $scriptblock -AsJob:($asJob.IsPresent) -ArgumentList $n,$memory,$vmswitch,$driver}
        else{Write-Output "WhatIf: Creating VM"}#make better WhatIf
    }
}
End{

}

}

new-DockerMachine -name  = 'docker1'

#install docker-compose
$command = @"
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
"@
docker-machine ssh $machineName $command