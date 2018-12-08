<# Build Script to Build 32 Bit Assembler Files using Microsofts Assembler
Reference for visual studio code tasks used in development: https://code.visualstudio.com/docs/editor/tasks
Reference for assembler command line options: ml.exe /?  will list the command line options
#>
param (
	[string]$workspaceFolder = "."
)
cd "$workspaceFolder/bin/"
$assemblerfiles="" + (get-item $workspaceFolder/source/*.asm)
if ( -not $assemblerfiles) {
	echo "No files to compile!"
	exit
}
$exefile="$workspaceFolder/bin/main.exe"
# Set the 64 bit development environment by calling vcvars64.bat 
# Compile and link in one step using ml64.exe 
$ranstring = -join ((48..57) + (97..122) | Get-Random -Count 32 | % {[char]$_})
$batfile = "$workspaceFolder/.vscode/" + $ranstring + ".bat"
$command = 'set VSWHERE="%ProgramFiles(x86)%/Microsoft Visual Studio/Installer/vswhere.exe"'
write-output $command | out-file -encoding ascii $batfile 
$command = 'for /f "usebackq tokens=*" %i in (`%VSWHERE% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do ('
write-output $command | out-file -encoding ascii -append $batfile 
$command = "    set InstallDir=%i"
write-output $command | out-file -encoding ascii -append $batfile 
$command = ") " 
write-output $command | out-file -encoding ascii -append $batfile 
$command = '%InstallDir%/VC/Auxiliary/Build/vcvarsall.bat x86' 
write-output $command | out-file -encoding ascii -append $batfile 
$command = "ml.exe /nologo /Zi /Zd /I C:\Irvine /Fe " + $exefile + " /W3 /errorReport:prompt /Ta " + $assemblerfiles + ' /link /ENTRY:"main" /SUBSYSTEM:CONSOLE /LARGEADDRESSAWARE:NO C:/Irvine/Lib32/Irvine32.lib kernel32.lib user32.lib gdi32.lib'
write-output $command | out-file -encoding ascii -append $batfile 
type $batfile | CMD
$ofiles = (get-item *.obj)
if ($ofiles){
		rm $ofiles
}
rm $batfile
