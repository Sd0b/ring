/*
**	Application : Ring To Executable 
**	Purpose	    : Convert Ring project source code to executable file 
**		      (Windows, Linux & MacOS X)
**	Author	    : Mahmoud Fayed <msfclipper@yahoo.com>
**	Date	    : 2017.11.06
*/

/*
	Usage

		ring ring2exe.ring filename.ring  [Options]
		This will set filename.ring as input to the program 	

		The next files will be generated 
		filename.ringo	  (The Ring Object File - by Ring Compiler)
		filename.c	  (The C Source code file
				   Contains the ringo file content
				   Will be generated by this program)
		filename_buildvc.bat (Will be executed to build filename.c using Visual C/C++)
		filename_buildgcc.bat (Will be executed to build filename.c using GNU C/C++)
		filename_buildclang.bat (Will be executed to build filename.c using CLang C/C++)
		filename.obj	  (Will be generated by the Visual C/C++ compiler) 
		filename.exe 	  (Will ge generated by the Visual C/C++ Linker)
		filename	  (Executable File - On Linux & MacOS X platforms)

	Note
		We can use 
			ring ring2exe.ring ring2exe.ring 
		This will build ring2exe.exe
		We can use ring2exe.exe 

		ring2exe filename.ring 

		Or (Linux & MacOS X)

		./ring2exe filename.ring

	Testing 	
	
		ring2exe test.ring 
		test 

		Or (Linux & MacOS X)

		./ring2exe test.ring 
		./test

	Options

		-keep       	 : Don't delete Temp. Files
		-static     	 : Build Standalone Executable File (Don't use ring.dll/ring.so/ring.dylib)
		-gui        	 : Build GUI Application (Hide the Console Window)
		-dist	    	 : Prepare application for distribution 
		-allruntime 	 : Include all libraries in distribution
		-mobileqt	 : Prepare Qt Project to distribute Ring Application for Mobile 
		-noqt	    	 : Remove RingQt from distribution
		-noallegro 	 : Remove RingAllegro from distribution
		-noopenssl  	 : Remove RingOpenSSL from distribution
		-nolibcurl  	 : Remove RingLibCurl from distribution
		-nomysql    	 : Remove RingMySQL from distribution
		-noodbc     	 : Remove RingODBC from distribution
		-nosqlite   	 : Remove RingSQLite from distribution
		-noopengl   	 : Remove RingOpenGL from distribution
		-nofreeglut 	 : Remove RingFreeGLUT from distribution
		-nolibzip   	 : Remove RingLibZip from distribution
		-noconsolecolors : Remove RingConsoleColors from distribution
		-nocruntime	 : Remove C Runtime from distribution
		-qt	    	 : Add RingQt to distribution
		-allegro 	 : Add RingAllegro to distribution
		-openssl  	 : Add RingOpenSSL to distribution
		-libcurl  	 : Add RingLibCurl to distribution
		-mysql    	 : Add RingMySQL to distribution
		-odbc     	 : Add RingODBC to distribution
		-sqlite   	 : Add RingSQLite to distribution
		-opengl   	 : Add RingOpenGL to distribution
		-freeglut 	 : Add RingFreeGLUT to distribution
		-libzip   	 : Add RingLibZip to distribution
		-consolecolors   : Add RingConsoleColors to distribution
		-cruntime	 : Add C Runtime to distribution
*/

C_WINDOWS_NOOUTPUTNOERROR = " >nul 2>nul"
C_LINUX_NOOUTPUTNOERROR   = " > /dev/null"

# Load Libraries information
	eval(read(exefolder()+"/../ring2exe/ring2exe.data"))

func Main 
	aPara = sysargv
	aOptions = []
	# Get Options 
		for x = len(aPara) to 1 step -1
			if left(trim(aPara[x]),1) = "-"
				aOptions + lower(trim(aPara[x]))
				del(aPara,x)
			ok
		next
	nParaCount = len(aPara)
	if (nParaCount > 2) or ( nParaCount = 2 and aPara[1] != "ring" )
		cFile = aPara[nParaCount]
		msg("Process File : " + cFile)
		BuildApp(cFile,aOptions)
	else 
		drawline()
		see "Application : Ring2EXE (Ring script to Executable file)" + nl
		see "Author      : 2017, Mahmoud Fayed <msfclipper@yahoo.com>" + nl
		see "Usage       : ring2exe filename.ring [Options]" + nl
		drawline()
	ok

func DrawLine 
	see copy("=",70) + nl

func msg cMsg
	see "Ring2EXE: " + cMsg + nl

func BuildApp cFileName,aOptions
	msg("Start building the application...")
	# Generate the Object File 
		systemSilent(exefolder()+"../bin/ring " + cFileName + " -go -norun")
	# Generate the C Source Code File 
		cFile = substr(cFileName,".ring","")
		GenerateCFile(cFile,aOptions)
	# Generate the Batch File 
		cBatch = GenerateBatch(cFile,aOptions)
	# Build the Executable File 
		msg("Build the Executable File...")
		systemSilent(cBatch)
		msg("End of building script...")
	# Prepare Application for distribution
		if find(aOptions,"-dist")
			Distribute(cFile,aOptions)
		ok
		msg("End of building process...")
	# Clear Temp Files 	
		if not find(aOptions,"-keep")
			cleartempfiles()
		ok

func GenerateCFile cFileName,aOptions
	# Display Message
		msg("Generate C source code file...")
	nTime = clock()
	# Convert the Ring Object File to Hex.
		cFile = read(cFileName+".ringo")
		cHex  = str2hexCStyle(cFile)
	fp = fopen(cFileName+".c","w+")
	# Start writing the C source code - Main Function 
	if isWindows() and find(aOptions,"-gui")
		cCode = '#include "windows.h"' 	+ nl +
			'#include "stdio.h"' 	+ nl +
			'#include "stdlib.h"' 	+ nl +
			'#include "conio.h"' 	+ nl +  
			'#include "ring.h"' 	+ nl +  nl +
		'int WINAPI WinMain ( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nShowCmd )' + nl +  "{" + nl + nl +
		char(9) + 'int argc;' + nl + char(9) + 'char **argv ;' + nl + 
		char(9) + 'argc = __argc ; ' + nl + char(9) + 'argv = __argv ;' + nl + nl +
		char(9) + 'static const unsigned char bytecode[] = { 
			  '
	else
		cCode = '#include "ring.h"' + nl + nl +
		'int main( int argc, char *argv[])' + nl +  "{" + nl + nl +
		char(9) + 'static const unsigned char bytecode[] = { 
			  '
	ok
	fputs(fp,cCode)
	# Add the Object File Content		
		fputs(fp,cHex)
	fputs(fp, ", EOF" + char(9) + "};"+substr(
	'

	RingState *pRingState ;
	pRingState = ring_state_new();	
	pRingState->argc = argc;
	pRingState->argv = argv;
	ring_state_runobjectstring(pRingState,(char *) bytecode,"#{f1}");
	ring_state_delete(pRingState);

	return 0;',"#{f1}",cFileName+".ring") + nl + 
	"}")
	fclose(fp)	
	msg("Generation Time : " + ((clock()-nTime)/clockspersecond()) + " seconds...")

func GenerateBatch cFileName,aOptions
	msg("Generate batch|script file...")
	if find(aOptions,"-static")
		return GenerateBatchStatic(cFileName,aOptions)
	else 
		return GenerateBatchDynamic(cFileName,aOptions)
	ok

func GenerateBatchDynamic cFileName,aOptions
	msg("Generate batch|script file for dynamic building...")
	return GenerateBatchGeneral([
		:file = cFileName ,
		:ringlib = [
			:windows = exefolder() + "..\lib\ring.lib" ,
			:linux   = "-L "+exefolder()+"/../lib -lring",
			:macosx	 = exefolder() + "/../lib/libring.dylib"
		]
	],aOptions)	

func GenerateBatchStatic cFileName,aOptions
	msg("Generate batch|script file for static building...")
	return GenerateBatchGeneral([
		:file = cFileName ,
		:ringlib = [
			:windows = exefolder()+"..\lib\ringstatic.lib" ,
			:linux   = "-L "+exefolder()+"/../lib -lringstatic",
			:macosx	 = "-L "+exefolder()+"/../lib -lringstatic"
		]
	],aOptions)


func GenerateBatchGeneral aPara,aOptions
	cFileName = aPara[:file]
	cFile = substr(cFileName," ","_")
	# Generate Windows Batch (Visual C/C++)
		cCode = "call "+exefolder()+"../src/locatevc.bat" + nl +
			"#{f3}" + nl +
			'cl #{f1}.c #{f2} #{f4} -I"#{f6}..\include" -I"#{f6}../src/" /link #{f5} /OUT:#{f1}.exe' 
		cCode = substr(cCode,"#{f1}",cFile)
		cCode = substr(cCode,"#{f2}",aPara[:ringlib][:windows])
		# Resource File 
			cResourceFile = cFile + ".rc"
			if fexists(cResourceFile)
				cCode = substr(cCode,"#{f3}","rc " + cResourceFile)
				cCode = substr(cCode,"#{f4}",cFile + ".res")
			else 
				cCode = substr(cCode,"#{f3}","")
				cCode = substr(cCode,"#{f4}","")
			ok
		# GUI Application 
			if find(aOptions,"-gui")
				cCode = substr(cCode,"#{f5}",'advapi32.lib shell32.lib /SUBSYSTEM:WINDOWS,"5.01" ')
			else 
				cCode = substr(cCode,"#{f5}",' /SUBSYSTEM:CONSOLE,"5.01" ')
			ok
		cCode = substr(cCode,"#{f6}",exefolder())
		cWindowsBatch = cFile+"_buildvc.bat"
		write(cWindowsBatch,cCode)
	# Generate Linux Script (GNU C/C++)
		cCode = 'gcc -rdynamic #{f1}.c -o #{f1} #{f2} -lm -ldl  -I #{f3}/../include  '
		cCode = substr(cCode,"#{f1}",cFile)
		cCode = substr(cCode,"#{f2}",aPara[:ringlib][:linux])
		cCode = substr(cCode,"#{f3}",exefolder())
		cLinuxBatch = cFile+"_buildgcc.sh"
		write(cLinuxBatch,cCode)
	# Generate MacOS X Script (CLang C/C++)
		cCode = 'clang #{f1}.c #{f2} -o #{f1} -lm -ldl  -I #{f3}/../include  '
		cCode = substr(cCode,"#{f1}",cFile)
		cCode = substr(cCode,"#{f2}",aPara[:ringlib][:macosx])
		cCode = substr(cCode,"#{f3}",exefolder())
		cMacOSXBatch = cFile+"_buildclang.sh"
		write(cMacOSXBatch,cCode)
	# Return the script/batch file name
		if isWindows()	
			return cWindowsBatch
		but isLinux()
			systemSilent("chmod +x " + cLinuxBatch)
			return "./"+cLinuxBatch
		but isMacosx()
			systemSilent("chmod +x " + cMacOSXBatch)
			return "./"+cMacOSXBatch	
		ok

func ClearTempFiles
	msg("Clear Temp. Files...")
	if isWindows()
		systemSilent(exefolder()+"/../ring2exe/cleartemp.bat")
	else
		systemSilent(exefolder()+"/../ring2exe/cleartemp.sh")
	ok

func Distribute cFileName,aOptions
	cBaseFolder = currentdir()
	CreateOpenFolder(:target)
	cDir = currentdir()
	if isWindows()
		DistributeForWindows(cBaseFolder,cFileName,aOptions)
	but isLinux()
		DistributeForLinux(cBaseFolder,cFileName,aOptions)
	but isMacOSX()
		DistributeForMacOSX(cBaseFolder,cFileName,aOptions)
	ok
	if currentdir() != cDir
	 	chdir(cDir)
	ok
	# Prepare Application for Mobile (RingQt)
		if find(aOptions,"-mobileqt")
			DistributeForMobileQt(cBaseFolder,cFileName,aOptions)
		ok
	chdir(cBaseFolder)

func DistributeForWindows cBaseFolder,cFileName,aOptions
	# Delete Files 
		WindowsDeleteFolder("windows")
	CreateOpenFolder(:windows)
	# copy the executable file 
		msg("Copy the executable file to target/windows")
		WindowsCopyFile(cBaseFolder+"\"+cFileName+".exe")
		CheckNoCCompiler(cBaseFolder,cFileName)
	# Check ring.dll
		if not find(aOptions,"-static")	
			msg("Copy ring.dll to target/windows")	
			WindowsCopyFile(exefolder()+"\ring.dll")
		ok
	# Check All Runtime 
		if find(aOptions,"-allruntime")	
			msg("Copy all libraries to target/windows")	
			for aLibrary in aLibsInfo 
				if not find(aOptions,"-no"+aLibrary[:name])
					if islist(aLibrary[:windowsfolders])
						for cLibFolder in aLibrary[:windowsfolders]
							WindowsCopyFolder(cLibFolder)
						next
					ok
					if islist(aLibrary[:windowsfiles])
						for cLibFile in aLibrary[:windowsfiles]
							WindowsCopyFile(exefolder()+"\"+cLibFile)
						next
					ok
				else 
					msg("Skip library "+aLibrary[:title])
				ok
			next  	
		else	# No -allruntime
			for aLibrary in aLibsInfo 
				if find(aOptions,"-"+aLibrary[:name])
					msg("Add "+aLibrary[:title]+" to target/windows")
					if islist(aLibrary[:windowsfolders])
						for cLibFolder in aLibrary[:windowsfolders]
							WindowsCopyFolder(cLibFolder)
						next
					ok
					if islist(aLibrary[:windowsfiles])
						for cLibFile in aLibrary[:windowsfiles]
							WindowsCopyFile(exefolder()+"\"+cLibFile)
						next
					ok
				ok
			next 				
		ok

func DistributeForLinux cBaseFolder,cFileName,aOptions
	# Delete Files 
		LinuxDeleteFolder(:linux)
	CreateOpenFolder(:linux)
	cLinuxDir = currentdir()
	CreateOpenFolder("dist_using_deb_package")
	cDebDir = currentdir() 
	chdir(cLinuxDir)
	CreateOpenFolder("dist_using_scripts")
	cDir = currentdir()
	CreateOpenFolder(:bin)
	# copy the executable file 
		msg("Copy the executable file to target/linux/bin")
		LinuxCopyFile(cBaseFolder+"/"+cFileName)
		CheckNoCCompiler(cBaseFolder,cFileName)
	chdir(cDir)
	CreateOpenFolder(:lib)
	cInstallUbuntu = "sudo apt-get install"
	cInstallFedora = "sudo dnf install"
	cInstallLibs   = ""
	cDebianPackageDependency = ""
	# Check ring.so
		if not find(aOptions,"-static")	
			msg("Copy libring.so to target/linux/lib")	
			LinuxCopyFile(exefolder()+"/../lib/libring.so")
		ok
		cInstallLibs = InstallLibLinux(cInstallLibs,"libring.so")
	# Check All Runtime 
		if find(aOptions,"-allruntime")	
			msg("Copy all libraries to target/linux/lib")
			LinuxCopyFile(exefolder()+"/../lib/libring.so")	
			for aLibrary in aLibsInfo 
				if not find(aOptions,"-no"+aLibrary[:name])
					if islist(aLibrary[:linuxfiles])
						for cLibFile in aLibrary[:linuxfiles]
							LinuxCopyFile(exefolder()+"/../lib/"+cLibFile)					
							cInstallLibs = InstallLibLinux(cInstallLibs,cLibFile)
						next
					ok
					cInstallUbuntu += (" " + aLibrary[:ubuntudep])
					cInstallFedora += (" " + aLibrary[:fedoradep])
					if aLibrary[:ubuntudep] != NULL
						cDebianPackageDependency += (" " + aLibrary[:ubuntudep])			
					ok
				else 
					msg("Skip library "+aLibrary[:title])
				ok
			next  	
		else	# No -allruntime
			for aLibrary in aLibsInfo 
				if find(aOptions,"-"+aLibrary[:name])
					msg("Add "+aLibrary[:title]+" to target/linux/lib")
					if islist(aLibrary[:linuxfiles])
						for cLibFile in aLibrary[:linuxfiles]
							LinuxCopyFile(exefolder()+"/lib/"+cLibFile)
							cInstallLibs = InstallLibLinux(cInstallLibs,cLibFile)
						next
					ok
					cInstallUbuntu += (" " + aLibrary[:ubuntudep])
					cInstallFedora += (" " + aLibrary[:fedoradep])					
					if aLibrary[:ubuntudep] != NULL
						cDebianPackageDependency += (" " + aLibrary[:ubuntudep])			
					ok
				ok
			next 				
		ok
	# Script to install the application 
	chdir(cDir)
	if cInstallUbuntu != "sudo apt-get install"
		cInstallUbuntu += (nl+cInstallLibs)
		write("install_ubuntu.sh",cInstallUbuntu)
		SystemSilent("chmod +x install_ubuntu.sh")
	ok
	if cInstallFedora != "sudo dnf install"
		cInstallFedora += (nl+cInstallLibs)
		write("install_fedora.sh",cInstallFedora)	
		SystemSilent("chmod +x install_fedora.sh")
	ok
	# Create the debian package 
	msg("Prepare files to create the Debian package")
	chdir(cDebDir)
	cAppName = substr(cFileName," ","_")
	cBuildDeb = "dpkg-deb --build #{f1}_1.0-1"
	cBuildDeb = substr(cBuildDeb,"#{f1}",cAppName)
	write("builddeb.sh",cBuildDeb)
	SystemSilent("chmod +x builddeb.sh")
	CreateOpenFolder(cAppName+"_1.0-1")
	cAppFolder = currentdir()
	CreateOpenFolder("DEBIAN")
	cControl = RemoveFirstTabs("
		Package: #{f1}
		Version: 1.0-1
		Section: base
		Priority: optional
		Architecture: amd64
		Depends: #{f2}
		Maintainer: Developer Name <youraccount@email.com>
		Description: Ring Application",2) + nl
	cDebianPackageDependency = trim(cDebianPackageDependency)
	cDebianPackageDependency = substr(cDebianPackageDependency," "," (>=0) ,")
	cDebianPackageDependency += " (>=0) "
	cControl = substr(cControl,"#{f1}",cAppName)
	cControl = substr(cControl,"#{f2}",cDebianPackageDependency)
	write("control",cControl)
	cPostInst = RemoveFirstTabs("
		#!/bin/sh
		cd /usr/local/#{f1}/bin
		./#{f1}
		exit 0
	",2)
	cPostInst = substr(cPostInst,"#{f1}",cAppName)
	write("postinst",cPostInst)
	SystemSilent("chmod +x postinst")
	chdir(cAppFolder)
	CreateOpenFolder("usr")
		cUsrFolder = currentdir()
		CreateOpenFolder("bin")
		write(cFileName,"/usr/local/"+cAppName+"/bin/"+cFileName+" \$1 \$2 \$3 \$4 \$5 \$6 \$7")
		systemSilent("chmod +x " + cFileName)
		chdir(cUsrFolder)
		CreateOpenFolder("lib")
		chdir(cUsrFolder)
		CreateOpenFolder("local")
			CreateOpenFolder(cAppName)
				CreateOpenFolder("bin")
	chdir(cAppFolder)
	systemSilent("cp -a ../../dist_using_scripts/lib/. usr/lib/")
	systemSilent("cp -a ../../dist_using_scripts/bin/. usr/local/"+cAppName+"/bin/")

func InstallLibLinux cInstallLib,cLibFile 
	cCode = "
		if [ -f lib/#{f1} ];
		then
			sudo cp lib/#{f1} /usr/lib
			sudo cp lib/#{f1} /usr/lib64
		fi
	"
	cCode = SubStr(cCode,"#{f1}",cLibFile)
	cCode = RemoveFirstTabs(cCode,2)
	return cInstallLib + cCode

func RemoveFirstTabs cString,nCount
	aList = str2list(cString)
	for item in aList 
		if left(item,nCount) = Copy(char(9),nCount)
			if len(item) > nCount
				item = substr(item,nCount+1)
			ok
		ok
	next
	return list2str(aList)

func DistributeForMacOSX cBaseFolder,cFileName,aOptions
	# Delete Files 
		MacOSXDeleteFolder(:macosx)
	CreateOpenFolder(:macosx)
	cDir = currentdir()
	CreateOpenFolder(:bin)
	# copy the executable file 
		msg("Copy the executable file to target/macosx/bin")
		MacOSXCopyFile(cBaseFolder+"/"+cFileName)
		CheckNoCCompiler(cBaseFolder,cFileName)
	chdir(cDir)
	CreateOpenFolder(:lib)
	cInstallmacosx = "brew install -k"
	cInstallLibs   = ""
	# Check ring.dylib
		if not find(aOptions,"-static")	
			msg("Copy libring.dylib to target/macosx/lib")	
			MacOSXCopyFile(exefolder()+"/../lib/libring.dylib")
		ok
		cInstallLibs = InstallLibMacOSX(cInstallLibs,"libring.dylib")
	# Check All Runtime 
		if find(aOptions,"-allruntime")	
			msg("Copy all libraries to target/macosx/lib")
			MacOSXCopyFile(exefolder()+"/../lib/libring.dylib")	
			for aLibrary in aLibsInfo 
				if not find(aOptions,"-no"+aLibrary[:name])
					if islist(aLibrary[:macosxfiles])
						for cLibFile in aLibrary[:macosxfiles]
							MacOSXCopyFile(exefolder()+"/../lib/"+cLibFile)
							cInstallLibs = InstallLibMacOSX(cInstallLibs,cLibFile)
						next
					ok
					cInstallMacOSX += (" " + aLibrary[:macosxdep])
				else 
					msg("Skip library "+aLibrary[:title])
				ok
			next  	
		else	# No -allruntime
			for aLibrary in aLibsInfo 
				if find(aOptions,"-"+aLibrary[:name])
					msg("Add "+aLibrary[:title]+" to target/macosx/lib")
					if islist(aLibrary[:macosxfiles])
						for cLibFile in aLibrary[:macosxfiles]
							MacOSXCopyFile(exefolder()+"/lib/"+cLibFile)
							cInstallLibs = InstallLibMacOSX(cInstallLibs,cLibFile)
						next
					ok
					cInstallMacOSX += (" " + aLibrary[:macosxdep])
				ok
			next 				
		ok
	# Script to install the application 
	chdir(cDir)
	if cInstallmacosx != "brew install -k"
		cInstallmacosx += (nl+cInstallLibs)
		write("install.sh",cInstallMacOSX)
		SystemSilent("chmod +x install.sh")
	ok

func InstallLibMacOSX cInstallLib,cLibFile 
	cCode = "
		if [ -f lib/#{f1} ];
		then
			cp lib/#{f1} /usr/local/lib
		fi
	"
	cCode = SubStr(cCode,"#{f1}",cLibFile)
	cCode = RemoveFirstTabs(cCode,2)
	return cInstallLib + cCode

func DistributeForMobileQt cBaseFolder,cFileName,aoptions
	msg("Prepare RingQt project to distribute for Mobile")
	# Delete Files 
		OSDeleteFolder(:mobile)
	CreateOpenFolder(:mobile)
	CreateOpenFolder(:qtproject)
	msg("Copy RingQt for Mobile project files...")
	OSCopyFile(exefolder() + "../android/ringqt/project/*.*" )
	OSDeleteFile("project.pro.user")
	msg("Prepare ringapp.ringo")
	OSDeleteFile("ringapp.ring")
	OSDeleteFile("ringapp.ringo")
	cRINGOFile = cBaseFolder+"/"+cFileName+".ringo"
	msg("Get the Ring Object File")
	OSCopyFile(cRINGOFile)
	write("main.cpp",substr(read("main.cpp"),"ringapp.ringo",cFileName+".ringo"))
	write("project.qrc",substr(read("project.qrc"),"ringapp.ringo",cFileName+".ringo"))

func CheckNoCCompiler cBaseFolder,cFileName 
	# If we don't have a C compiler 
	# We copy ring.exe to be app.exe 
	# Then we change app.ringo to ring.ringo 
	if isWindows()
		cExeFile = cBaseFolder+"\"+cFileName+".exe"
	else 
		cExeFile = cBaseFolder+"/"+cFileName
	ok
	if fexists(cExeFile)
		msg("Executable file is ready!")
		return 
	ok
	if isWindows()
		cRingOFile = cBaseFolder+"\"+cFileName+".ringo"
	else 
		cRingOFile = cBaseFolder+"/"+cFileName+".ringo"
	ok
	if fexists(cRingOFile)
		msg("No Executable, Looks like we don't have a C Compiler!")
	else 
		msg("No Ring Object File!")
		return
	ok	
	msg("Using the Ring Way to create executable file without a C Compiler!")
	OSCopyFile(exefilename())
	if isWindows()
		OSRenameFile("ring.exe",cFileName+".exe")
		OSCopyFile(cBaseFolder+"\"+cFileName+".ringo")
	else 
		OSRenameFile("ring",cFileName)
		OSCopyFile(cBaseFolder+"/"+cFileName+".ringo")
	ok
	OSRenameFile(cFileName+".ringo","ring.ringo")

func SystemSilent cCmd
	if isWindows()
		system(cCmd + C_WINDOWS_NOOUTPUTNOERROR)
	else 
		system(cCmd + C_LINUX_NOOUTPUTNOERROR)
	ok

func MakeFolder cFolder
	if iswindows()
		SystemSilent("mkdir " + cFolder)
	else 
		SystemSilent("mkdir -p " + cFolder)
	ok

func CreateOpenFolder cFolder
	MakeFolder(cFolder)
	chdir(cFolder)

func WindowsDeleteFolder cFolder
	systemSilent("rd /s /q " + cFolder)

func WindowsCopyFolder cFolder
	cParentFolder = currentdir()
	CreateOpenFolder(cFolder)
	systemsilent("copy " + exefolder()+cFolder)
	chdir(cParentFolder)

func WindowsDeleteFile cFile 
	systemSilent("del " + cFile)

func WindowsCopyFile cFile 
	systemSilent("copy " + cFile)

func LinuxDeleteFolder cFolder
	systemSilent("rm -r " + cFolder)

func LinuxDeleteFile cFile 
	systemSilent("rm " + cFile)

func LinuxCopyFile cFile 
	systemSilent("cp " + cFile + " .")

func MacOSXDeleteFolder cFolder
	LinuxDeleteFolder(cFolder)

func MacOSXDeleteFile cFile 
	LinuxDeleteFile(cFile)

func MacOSXCopyFile cFile 
	LinuxCopyFile(cFile)

func OSDeleteFolder cFolder 
	if isWindows() 
		WindowsDeleteFolder(cFolder)
	but isLinux()
		LinuxDeleteFolder(cFolder)
	but isMacosx()
		MacOSXDeleteFolder(cFolder)
	ok

func OSDeleteFile cFile
	if isWindows() 
		WindowsDeleteFile(cFile)
	but isLinux()
		LinuxDeleteFile(cFile)
	but isMacosx()
		MacOSXDeleteFile(cFile)
	ok

func OSCopyFile cFile
	if isWindows()
		WindowsCopyFile(substr(cFile,"/","\")) 
	but isLinux()
		LinuxCopyFile(cFile)
	but isMacosx()
		MacOSXCopyFile(cFile)
	ok

func OSRenameFile cOldFile,cNewFile
	if isWindows()
		systemSilent("rename " + cOldFile + " " + cNewFile)
	but isLinux() or isMacosx()
		systemSilent("mv " + cOldFile + " " + cNewFile)
	ok
