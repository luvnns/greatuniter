@ echo ------------------------------------------------
@ echo -                                              -
@ echo -               vJTAG CONTROLLER               -
@ echo -                                              -
@ echo -            2014.01.16 tvSHUSHTOV             -
@ echo -                                              -
@ echo ------------------------------------------------
@ REM ############### SETTINGS SCRIPT ###################
@ set QUARTUS_STP_FOLDER_PATH=C:\intelFPGA\18.0\quartus\bin64\
@ REM # Current folder
@ set CURR_FOLDER_PATH=%~dp0
@ set CURR_FOLDER_PATH="%CURR_FOLDER_PATH:\=/%"
@ echo Current directory:
@ echo ^> %CURR_FOLDER_PATH%

@ REM ###################################################
@ REM # Shell Settings
@ prompt $G$G  

@ REM ######################################
@ REM # Variable to ignore <CR> in DOS
@ REM # line endings
@ set SHELLOPTS=igncr

@ REM ######################################
@ REM # Variable to ignore mixed paths
@ REM # i.e. G:/$SOPC_KIT_NIOS2/bin
@ set CYGWIN=nodosfilewarning

@ echo ------------------------------------------------
@  "%QUARTUS_STP_FOLDER_PATH%quartus_stp.exe" -t "%CURR_FOLDER_PATH%TCL_Server_cons_2.tcl"
@ echo End BASH 
@ pause