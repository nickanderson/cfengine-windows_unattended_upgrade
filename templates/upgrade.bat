REM Work around a packaging issue that causes install over an existing version to leave a non functional agent.
REM Backup ppkeys, It must be removed before the new package can be installed and restored afterwards.
xcopy "$(sys.workdir)\ppkeys" "$(sys.workdir)\ppkeys.bak" /O /X /E /H /K /I /Y
rmdir /S /Q "$(sys.workdir)\ppkeys"   
msiexec /quiet /qn /i "$(cfengine_software.local_software_dir)\$(cfengine_software.pkg_name)$(cfengine_software.pkg_version)-$(cfengine_software.pkg_arch).msi"
REM We don't want the services to be running with the wrong hostkey.
Taskkill /IM cf-execd.exe /F
Taskkill /IM cf-monitord.exe /F
Taskkill /IM cf-serverd.exe /F
Taskkill /IM cf-agent.exe /F
REM We now restore the ppkeys from backup
rmdir /S /Q  "$(sys.workdir)\ppkeys"
xcopy "$(sys.workdir)\ppkeys.bak" "$(sys.workdir)\ppkeys" /O /X /E /H /K /I /Y
rmdir /S /Q "$(sys.workdir)\ppkeys.bak"
REM Run the update policy. The policy should ensure the services are running.
$(sys.cf_agent) -KIf update.cf
exit