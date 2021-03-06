;InnoSetupVersion=4.2.6

[Setup]
AppName=Malcode Analyst Pack
AppVerName=Malcode Analyst Pack v0.23
DefaultDirName=c:\iDefense\MAP\
DefaultGroupName=Malcode Analyst Pack
OutputBaseFilename=./map_setup
OutputDir=./


[Files]
;Source: ./Shellcode_2_exe\shellcode_2_exe.php; DestDir: {app}\Shellcode_2_exe
;Source: ./Shellcode_2_exe\husk.exe; DestDir: {app}\Shellcode_2_exe
Source: ./IDCDumpFix\Form1.frx; DestDir: {app}\IDCDumpFix
Source: ./IDCDumpFix\Project1.vbw; DestDir: {app}\IDCDumpFix
Source: ./IDCDumpFix\Form1.frm; DestDir: {app}\IDCDumpFix
Source: ./IDCDumpFix\Project1.vbp; DestDir: {app}\IDCDumpFix
Source: ./mailPot\Form1.frx; DestDir: {app}\mailPot
Source: ./mailPot\frmSplash.frx; DestDir: {app}\mailPot
Source: ./mailPot\frmSplash.frm; DestDir: {app}\mailPot
Source: ./mailPot\CmaiLog.cls; DestDir: {app}\mailPot
Source: ./mailPot\Mailpot.vbw; DestDir: {app}\mailPot
Source: ./mailPot\Form1.frm; DestDir: {app}\mailPot
Source: ./mailPot\Mailpot.vbp; DestDir: {app}\mailPot
Source: ./ShellExt\frmHash.frm; DestDir: {app}\ShellExt
Source: ./ShellExt\frmFileHash.frm; DestDir: {app}\ShellExt
Source: ./ShellExt\ShellExt.vbw; DestDir: {app}\ShellExt
Source: ./ShellExt\frmMain.frm; DestDir: {app}\ShellExt
Source: ./ShellExt\ShellExt.vbp; DestDir: {app}\ShellExt
Source: ./ShellExt\frmPeek.frm; DestDir: {app}\ShellExt
Source: ./ShellExt\Module1.bas; DestDir: {app}\ShellExt
Source: ./ShellExt\frmPeek.frx; DestDir: {app}\ShellExt
Source: ./ShellExt\frmMain.frx; DestDir: {app}\ShellExt
Source: ./ShellExt\CPEEditor.cls; DestDir: {app}\ShellExt
Source: ./ShellExt\CSection.cls; DestDir: {app}\ShellExt
Source: ./socketTool\Project1.vbw; DestDir: {app}\socketTool
Source: ./socketTool\Form1.frm; DestDir: {app}\socketTool
Source: ./socketTool\Project1.vbp; DestDir: {app}\socketTool
Source: ./fakeDNS.exe; DestDir: {app}; Flags: ignoreversion
Source: ./IDCDumpFix.exe; DestDir: {app}; Flags: ignoreversion
Source: ./fakeDns\Form1.frm; DestDir: {app}\fakeDns
Source: ./fakeDns\Project1.vbw; DestDir: {app}\fakeDns
Source: ./fakeDns\Project1.vbp; DestDir: {app}\fakeDns
Source: ./mail_pot.exe; DestDir: {app}; Flags: ignoreversion
Source: ./sckTool.exe; DestDir: {app}; Flags: ignoreversion
Source: ./ShellExt.exe; DestDir: {app}; Flags: ignoreversion
Source: ./map_help.chm; DestDir: {app}
Source: ./dependancies\vbDevKit.dll; DestDir: {win}; Flags: regserver
Source: ./dependancies\spSubclass2.dll; DestDir: {win}; Flags: regserver
Source: ./dependancies\MSWINSCK.OCX; DestDir: {win}; Flags: uninsneveruninstall regserver promptifolder
Source: ./dependancies\mscomctl.ocx; DestDir: {win}; Flags: uninsneveruninstall regserver promptifolder
Source: ./dependancies\RICHTX32.OCX; DestDir: {win}; Flags: uninsneveruninstall regserver promptifolder
Source: ./sniff_hit\CTcpPacket.cls; DestDir: {app}\sniff_hit
Source: ./sniff_hit\CUdpPacket.cls; DestDir: {app}\sniff_hit
Source: ./sniff_hit\frmData.frx; DestDir: {app}\sniff_hit
Source: ./sniff_hit\frmData.frm; DestDir: {app}\sniff_hit
Source: ./sniff_hit\frmMain.frx; DestDir: {app}\sniff_hit
Source: ./sniff_hit\frmMain.frm; DestDir: {app}\sniff_hit
Source: ./sniff_hit\CSniffer.cls; DestDir: {app}\sniff_hit
Source: ./sniff_hit\sniff_hit.vbp; DestDir: {app}\sniff_hit
Source: ./sniff_hit\sniff_hit.vbw; DestDir: {app}\sniff_hit
Source: ./sniff_hit.exe; DestDir: {app}; Flags: ignoreversion
;Source: ./sc_log\bin\codbot.sc; DestDir: {app}\sc_log\bin
;Source: ./sc_log\bin\recv_cmd.sc; DestDir: {app}\sc_log\bin
;Source: ./sc_log\bin\recv_file.sc; DestDir: {app}\sc_log\bin
;Source: ./sc_log\bin\tftp.sc; DestDir: {app}\sc_log\bin
Source: ./sc_log\bin\sclog.exe; DestDir: {app}\sc_log\bin
Source: ./sc_log\bin\vcrt_test.sc; DestDir: {app}\sc_log\bin
Source: ./sc_log\hook_test\hook_test.dsw; DestDir: {app}\sc_log\hook_test
Source: ./sc_log\hook_test\hook_test.c; DestDir: {app}\sc_log\hook_test
Source: ./sc_log\hook_test\hook_test.dsp; DestDir: {app}\sc_log\hook_test
Source: ./sc_log\hook_test\hook_test.exe; DestDir: {app}\sc_log\hook_test
Source: ./sc_log\hooker\disasm.h; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\assembl.c; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\disasm.c; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\asmserv.c; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\makelib.txt; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\hooker.c; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\asmserv.obj; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\assembl.obj; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\disasm.obj; DestDir: {app}\sc_log\hooker
Source: ./sc_log\hooker\hooker.obj; DestDir: {app}\sc_log\hooker
Source: ./sc_log\parse_h\Project1.vbp; DestDir: {app}\sc_log\parse_h
Source: ./sc_log\parse_h\Form1.frm; DestDir: {app}\sc_log\parse_h
Source: ./sc_log\parse_h\parse_h.exe; DestDir: {app}\sc_log\parse_h
Source: ./sc_log\parse_h\Project1.vbw; DestDir: {app}\sc_log\parse_h
Source: ./sc_log\parse_h\example_output.gif; DestDir: {app}\sc_log\parse_h
Source: ./sc_log\hooker.h; DestDir: {app}\sc_log
Source: ./sc_log\hooker.lib; DestDir: {app}\sc_log
Source: ./sc_log\main.cpp; DestDir: {app}\sc_log
Source: ./sc_log\main.h; DestDir: {app}\sc_log
Source: ./sc_log\sclog.dsp; DestDir: {app}\sc_log
Source: ./sc_log\sclog.dsw; DestDir: {app}\sc_log
Source: ./GdiProcs\GdiProcs.dsp; DestDir: {app}\GdiProcs
Source: ./GdiProcs\GdiProcs.cpp; DestDir: {app}\GdiProcs
Source: ./GdiProcs\GdiProcs.dsw; DestDir: {app}\GdiProcs
Source: ./gdiprocs.exe; DestDir: {app}
Source: ./gdiprocs.exe; DestDir: {win}
Source: ./jsDecode\frame.html; DestDir: {app}\jsDecode
Source: ./jsDecode\index.html; DestDir: {app}\jsDecode
Source: FindDll.exe; DestDir: {app}; Flags: ignoreversion
Source: FindDll.exe; DestDir: {win}; Flags: ignoreversion
Source: findDll\findDll.cpp; DestDir: {app}\findDll\
Source: findDll\FindDll.sln; DestDir: {app}\findDll\
Source: findDll\FindDll.vcproj; DestDir: {app}\findDll\
Source: VirusTotal\CResult.cls; DestDir: {app}\VirusTotal\
Source: VirusTotal\CScan.cls; DestDir: {app}\VirusTotal\
Source: VirusTotal\CVirusTotal.cls; DestDir: {app}\VirusTotal\
Source: VirusTotal\Form1.frm; DestDir: {app}\VirusTotal\
Source: VirusTotal\Form2.frm; DestDir: {app}\VirusTotal\
Source: VirusTotal\MD5Hash.cls; DestDir: {app}\VirusTotal\
Source: VirusTotal\Project1.vbp; DestDir: {app}\VirusTotal\
Source: VirusTotal\Project1.vbw; DestDir: {app}\VirusTotal\
Source: VirusTotal\sample.txt; DestDir: {app}\VirusTotal\
Source: virustotal.exe; DestDir: {app}; Flags: ignoreversion
Source: loadlib\loadlib.cpp; DestDir: {app}\loadlib\
Source: loadlib\loadlib.dsp; DestDir: {app}\loadlib\
Source: loadlib\loadlib.dsw; DestDir: {app}\loadlib\
Source: loadlib.exe; DestDir: {app}; Flags: ignoreversion
Source: loadlib.exe; DestDir: {win}; Flags: ignoreversion
Source: fakedns\CStrings.cls; DestDir: {app}\fakedns\
Source: proc_watch.exe; DestDir: {app}
Source: dirwatch_ui.exe; DestDir: {app}
Source: shellext.external.txt; DestDir: {app}

[Dirs]
Name: {app}\IDCDumpFix
Name: {app}\mailPot
Name: {app}\ShellExt
Name: {app}\socketTool
Name: {app}\fakeDns
Name: {app}\sniff_hit
Name: {app}\shellcode_2_exe
Name: {app}\sc_log
Name: {app}\sc_log\bin
Name: {app}\sc_log\hook_test
Name: {app}\sc_log\hooker
Name: {app}\sc_log\parse_h
Name: {app}\GdiProcs
Name: {app}\jsDecode
Name: {app}\findDll
Name: {app}\VirusTotal
Name: {app}\loadlib

[Run]
Filename: {app}\ShellExt.exe; Description: Install Shell Extensions Now; Flags: postinstall
Filename: {app}\map_help.chm; StatusMsg: View Readme File; Flags: shellexec postinstall

[Icons]
Name: {group}\Apps\FakeDNS; Filename: {app}\fakeDNS.exe; WorkingDir: {app}
Name: {group}\Apps\MailPot; Filename: {app}\mail_pot.exe; WorkingDir: {app}
Name: {group}\Apps\SocketTool; Filename: {app}\sckTool.exe; WorkingDir: {app}
Name: {group}\Apps\Shell Extensions; Filename: {app}\ShellExt.exe; WorkingDir: {app}
Name: {group}\Apps\DumpFix; Filename: {app}\IDCDumpFix.exe
Name: {group}\src\FakeDNS.vbp; Filename: {app}\fakeDns\Project1.vbp
Name: {group}\src\Mailpot.vbp; Filename: {app}\mailPot\Mailpot.vbp
Name: {group}\src\SckTool.vbp; Filename: {app}\socketTool\Project1.vbp
Name: {group}\src\ShellExt.vbp; Filename: {app}\ShellExt\ShellExt.vbp
Name: {group}\src\Dumpfix.vbp; Filename: {app}\IDCDumpFix\Project1.vbp
Name: {group}\Readme; Filename: {app}\map_help.chm
Name: {group}\Apps\Sniff_hit; Filename: {app}\sniff_hit.exe
Name: {group}\src\sniff_hit.vbp; Filename: {app}\sniff_hit\sniff_hit.vbp
Name: {group}\src\sclog.dsw; Filename: {app}\sc_log\sclog.dsw
Name: {group}\Open Home Directory; Filename: {app}; WorkingDir: {app}
Name: {group}\Uninstall; Filename: {app}\unins000.exe; WorkingDir: {app}
Name: {group}\Apps\sc_log; Filename: cmd; Parameters: /k sclog; WorkingDir: {app}\sc_log\bin
Name: {group}\Apps\ShellCode2Exe; Filename: {app}\shellcode_2_exe\; WorkingDir: {app}\shellcode_2_exe
Name: {group}\Apps\GdiProcs; Filename: cmd; Parameters: "/k ""GdiProcs.exe /?"""; WorkingDir: {app}
Name: {group}\src\GdiProcs.dsw; Filename: {app}\GdiProcs\GdiProcs.dsw
Name: {group}\Apps\jsDecode.html; Filename: {app}\jsDecode\index.html
Name: {group}\src\jsDecode; Filename: {app}\jsDecode\
Name: {group}\src\findDll; Filename: {app}\findDll\FindDll.vcproj
Name: {group}\src\VirusTotal.vbp; Filename: {app}\VirusTotal\Project1.vbp
Name: {group}\Apps\ProcWatch; Filename: {app}\proc_watch.exe
Name: {group}\App\DirWatch; Filename: {app}\dirwatch_ui.exe

[CustomMessages]
NameAndVersion=%1 version %2
AdditionalIcons=Additional icons:
CreateDesktopIcon=Create a &desktop icon
CreateQuickLaunchIcon=Create a &Quick Launch icon
ProgramOnTheWeb=%1 on the Web
UninstallProgram=Uninstall %1
LaunchProgram=Launch %1
AssocFileExtension=&Associate %1 with the %2 file extension
AssocingFileExtension=Associating %1 with the %2 file extension...
