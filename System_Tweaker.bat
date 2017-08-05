::-------------------------------------------------------------------------------------
::
:: This batch file was made to simplify the application of different tweaks
:: Made by TheAlabaster92 12 September 2016.
::
::-------------------------------------------------------------------------------------
::turn off repeated echo
@echo off
GOTO Start


::-------------------------------------------------------------------------------------
::------- Functions:
::-------------------------------------------------------------------------------------

::Start a service passed as the first parameter if the service wasn't started already
:START_SERVICE_IF_NOT_RUNNING
  for /F "tokens=3 delims=: " %%H in ('sc query "%1" ^| findstr "        STATE"') do (
    if /I "%%H" NEQ "RUNNING" (
      net start "%1"
	  echo %1>>%~dp0temp.txt
    )
  )
  GOTO:EOF
  
:NetInterfaces_Make_Settings
    SET guid=%~1
    SET reg_path="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%guid%"
    SET reg_name_1=TcpAckFrequency
	SET reg_name_2=TCPNoDelay
	SET reg_name_3=TcpDelAckTicks
    SET reg_type=REG_DWORD
	GOTO:EOF
	
:NetInterfaces_Set_Stream_Mode
    echo setting Network Interface %guid% for streaming profile (on 3 values)...
    SET reg_val_1=4
	SET reg_val_2=1
	SET reg_val_3=0
	
	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val_1% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val_2% /f
	REG ADD %reg_path% /v %reg_name_3% /t %reg_type% /d %reg_val_3% /f
	GOTO:EOF
	
:NetInterfaces_Set_Game_Mode
    echo setting Network Interface %guid% for gaming profile (on 3 values)...
    SET reg_val_1=1
	SET reg_val_2=1
	SET reg_val_3=0
	
	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val_1% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val_2% /f
	REG ADD %reg_path% /v %reg_name_3% /t %reg_type% /d %reg_val_3% /f
	GOTO:EOF
	
:NetInterfaces_Clean_Settings
	for /F %%I in (%~dp0temp.txt) do (
	  net stop %%I
	)
	DEL %~dp0temp.txt
	DEL %~dp0temp_net.txt
	GOTO:EOF
::-------------------------------------------------------------------------------------	

::-------------------------------------------------------------------------------------
::------- Execution Start:
::-------------------------------------------------------------------------------------
:Start
::-------------------------------------------------------------------------------------
::------- Variables:
::-------------------------------------------------------------------------------------
SET net_svc_01="dot3svc"
SET net_svc_02="WlanSvc"
SET must_clean="False"

::-------------------------------------------------------------------------------------
::------- Command Line parameters:
::-------------------------------------------------------------------------------------
if "%~1"==""   GOTO Help

set first_par=%~1
set second_par=%~2

if "%first_par%"=="-s" GOTO Superfetch
if "%first_par%"=="-m" GOTO AutoMaint
if "%first_par%"=="-n" GOTO NetInterfaces
if "%first_par%"=="-g" GOTO Gaming
if "%first_par%"=="-h" GOTO Help
::-------------------------------------------------------------------------------------



::-------------------------------------------------------------------------------------
::------- Superfetch Section:
::-------------------------------------------------------------------------------------
:Superfetch
  
  if "%second_par%"=="" GOTO Help_Error
  
  SET reg_path="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SessionManager\Memory Management\PrefetchParameters"
  SET reg_name_1=EnableSuperfetch
  SET reg_name_2=EnablePrefetcher
  SET reg_type=REG_DWORD
  
  if "%second_par%"=="-0" GOTO S_Set_Disabled
  if "%second_par%"=="-1" GOTO S_Set_App_Only
  if "%second_par%"=="-2" GOTO S_Set_Boot_Only
  if "%second_par%"=="-3" GOTO S_Set_All
  
  :S_Set_Disabled
    echo setting superfetch to disabled...
	SET reg_val=0

	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name_1%
	REG QUERY %reg_path% /v %reg_name_2%
	GOTO EOF
	
  :S_Set_App_Only
    echo setting superfetch to cache application only...
	SET reg_val=1
	
	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name_1%
	REG QUERY %reg_path% /v %reg_name_2%
	GOTO EOF
	
  :S_Set_Boot_Only
    echo setting superfetch to cache boot files only...
	SET reg_val=2
    
	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name_1%
	REG QUERY %reg_path% /v %reg_name_2%
	GOTO EOF
	
  :S_Set_All
    echo setting superfetch to cache everything...
	SET reg_val=3
	
	REG ADD %reg_path% /v %reg_name_1% /t %reg_type% /d %reg_val% /f
	REG ADD %reg_path% /v %reg_name_2% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name_1%
	REG QUERY %reg_path% /v %reg_name_2%
	GOTO EOF
::-------------------------------------------------------------------------------------		



::-------------------------------------------------------------------------------------
::------- Automatic Maintenance Section:
::-------------------------------------------------------------------------------------	
:AutoMaint
  
  if "%second_par%"=="" GOTO Help_Error
  
  SET reg_path="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"
  SET reg_name=MaintenanceDisabled
  SET reg_type=REG_DWORD
  
  if "%second_par%"=="-e" GOTO AutoMaint_Enable
  if "%second_par%"=="-d" GOTO AutoMaint_Disable
  
  :AutoMaint_Enable
    echo setting Auto Maintenance to enabled...
	SET reg_val=0
	
    REG ADD %reg_path% /v %reg_name% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name%
	GOTO EOF
  
  :AutoMaint_Disable
    echo setting Auto Maintenance to disabled...
	SET reg_val=1
	
    REG ADD %reg_path% /v %reg_name% /t %reg_type% /d %reg_val% /f
	echo settings done.
	echo new_values:
	REG QUERY %reg_path% /v %reg_name%
	GOTO EOF
::-------------------------------------------------------------------------------------



::-------------------------------------------------------------------------------------
::------- Network Interfaces Section:
::-------------------------------------------------------------------------------------	
:NetInterfaces

  if "%second_par%"=="" GOTO Help_Error
  
  ::Get Lan interfaces GUID
  call ::START_SERVICE_IF_NOT_RUNNING %net_svc_01%
  netsh lan show interfaces | findstr "GUID" > %~dp0temp_net.txt
  for /f "tokens=3 delims= " %%g in (%~dp0temp_net.txt) do (
    call :NetInterfaces_Make_Settings %%g
	if "%second_par%"=="-s" call :NetInterfaces_Set_Stream_Mode
    if "%second_par%"=="-g" call :NetInterfaces_Set_Game_Mode
  )
  
  ::Get WLan interfaces GUID
  call ::START_SERVICE_IF_NOT_RUNNING %net_svc_02%
  netsh wlan show interfaces | findstr "GUID" > %~dp0temp_net.txt
  for /f "tokens=3 delims= " %%g in (%~dp0temp_net.txt) do (
    call :NetInterfaces_Make_Settings %%g
	if "%second_par%"=="-s" call :NetInterfaces_Set_Stream_Mode
    if "%second_par%"=="-g" call :NetInterfaces_Set_Game_Mode
  )
  
  call ::NetInterfaces_Clean_Settings
  GOTO EOF
::-------------------------------------------------------------------------------------	



::-------------------------------------------------------------------------------------
::------- Gaming Section:
::-------------------------------------------------------------------------------------	 
:Gaming
  
  if "%second_par%"=="" (
    call :Check_Second_Par
  )
  
  if "%second_par%"=="-e" GOTO Gaming_Enable
  if "%second_par%"=="-d" GOTO Gaming_Disable
  
  :Gaming_Enable
    echo Enabling gaming tweaks...
    REG IMPORT %~dp0Tweaks\Tweak_Gaming_Enabled.reg
	echo done.
	
	GOTO EOF
	
  :Gaming_Disable
    echo Disabling gaming tweaks...
    REG IMPORT %~dp0Tweaks\Tweak_Gaming_Disabled.reg
	echo done.
	
	GOTO EOF
::-------------------------------------------------------------------------------------	



:Help_Error
  echo no_sub_parameter or wrong_sub_parameter.
  echo see help for legal parameters.
  GOTO EOF

:Help
  echo Sets the desired tweaks:
  echo parameters:
  echo -s   Superfetch Tweak:
  echo      Changes the way Superfetch handles the caching of the files to speed up the system.
  echo        sub-parameters
  echo          -0 disabled
  echo          -1 Cache applications only
  echo          -2 Cache boot files only (raccomanded)
  echo          -3 Cache everything (default)
  echo -m   Automatic Maintenance Tweaks:
  echo      Enable or Disable the Windows automatic maintenance.
  echo        sub-parameters
  echo          -e enabled
  echo          -d disabled
  echo -n   Network Interfaces Tweaks:
  echo      Tunes different parameters on all the network interfaces to speed up either Streaming or Gaming.
  echo        sub-parameters
  echo          -s stream mode
  echo          -g gaming mode
  echo -g   Gaming Tweaks:
  echo      Batch of tweaks to improve system performances.
  echo      *Specifically designed for gaming, but brings overall improvements.
  echo        sub-parameters
  echo          -e enabled
  echo          -d disabled
  echo -h   Displays this help.
  echo -q   Quits the Script. (No sub-parameters input)
  
  echo please enter your first parameter...
  SET /P first_par=
  
  if "%first_par%"=="-q" GOTO EOF_NO_Pause
  
  echo please enter your second parameter...
  SET /P second_par=
  
  
  if "%first_par%"=="-s" GOTO Superfetch
  if "%first_par%"=="-m" GOTO AutoMaint
  if "%first_par%"=="-n" GOTO NetInterfaces
  if "%first_par%"=="-g" GOTO Gaming
  if "%first_par%"=="-h" GOTO Help
  
:EOF
PAUSE

:EOF_NO_Pause
