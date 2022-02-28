sc config "wuauserv" start= demand

dism /online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0

sc config "sshd" start= auto

net start sshd

net stop wuauserv
sc config "wuauserv" start= disabled

reg add HKLM\SOFTWARE\OpenSSH /v DefaultShell /t REG_SZ /d %SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe /f

net stop sshd && net start sshd

set ssh_public_key=${ssh_public_key}

IF NOT "%ssh_public_key%" == "" (
	echo %ssh_public_key% > %PROGRAMDATA%\ssh\administrators_authorized_keys
	icacls %PROGRAMDATA%\ssh\administrators_authorized_keys /inheritancelevel:r
	icacls %PROGRAMDATA%\ssh\administrators_authorized_keys /grant *S-1-5-18:(F)
	icacls %PROGRAMDATA%\ssh\administrators_authorized_keys /grant *S-1-5-32-544:(F)	
)

netsh advfirewall firewall add rule name="OpenSSH SSH Server (sshd)" dir=in action=allow protocol=tcp localport=22 program="%SystemRoot%\system32\OpenSSH\sshd.exe"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex ((New-Object System.Net.Webclient).DownloadString('https://github.com/ansible/ansible/raw/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iex ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/andif888/optimize-powershell-assemblies/master/optimize-powershell-assemblies.ps1'))"
