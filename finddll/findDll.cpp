/*
	License:   GPL

	Author:    David Zimmer <dzzie@yahoo.com>

			 This program is free software; you can redistribute it and/or modify it
			 under the terms of the GNU General Public License as published by the Free
			 Software Foundation; either version 2 of the License, or (at your option)
			 any later version.

			 This program is distributed in the hope that it will be useful, but WITHOUT
			 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
			FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
			 more details.

			 You should have received a copy of the GNU General Public License along with
			 this program; if not, write to the Free Software Foundation, Inc., 59 Temple
			 Place, Suite 330, Boston, MA 02111-1307 USA

*/ 

#include "windows.h"
#include "stdio.h"
#include <tlhelp32.h> 
#include <psapi.h>

char* find = NULL;

char* findProcessByPid(int pid){
	
	PROCESSENTRY32 pe;
    HANDLE hSnap;
	int cnt=0;
    char tmp[200]={0};

    pe.dwSize = sizeof(pe);
    hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    
    Process32First( hSnap, &pe);
    if( pe.th32ProcessID == pid ) return strdup(pe.szExeFile);

    while( Process32Next(hSnap, &pe) ){
		if( pe.th32ProcessID == pid ) return strdup(pe.szExeFile);
	}

	sprintf(tmp, "pid:%x", pid);
	return strdup(tmp);

}

void ScanModules( int processID )
{
    HMODULE hMods[1024];
    HANDLE hProcess;
    DWORD cbNeeded;
    unsigned int i;
    char* szModName[MAX_PATH];
 
    hProcess = OpenProcess( PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processID );
    if (NULL == hProcess) return;

    if( EnumProcessModules(hProcess, hMods, sizeof(hMods), &cbNeeded)){
        for ( i = 0; i < (cbNeeded / sizeof(HMODULE)); i++ ){
			if ( GetModuleFileNameEx( hProcess, hMods[i], (char*)szModName, MAX_PATH)){
				if( strstr(_strlwr((char*)szModName), find) > 0){
					printf("0x%04X (%04d)\t%s\t%s\t0x%08X\n", processID,processID, findProcessByPid(processID), szModName, hMods[i] );
				}
            }
        }
    }
    
    CloseHandle( hProcess );
}

void ScanProcesses(void){

	PROCESSENTRY32 pe;
    HANDLE hSnap;
    
    pe.dwSize = sizeof(pe);
    hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    
    Process32First( hSnap, &pe);
    ScanModules(pe.th32ProcessID);

    while( Process32Next(hSnap, &pe) ){
		 ScanModules(pe.th32ProcessID);
	}

	return;
}




bool GetSeDebug(void){
	
	HANDLE hToken=0, hProcess;
	LUID luid;
    TOKEN_PRIVILEGES tkp;
	bool ret = false;

	hProcess = GetCurrentProcess();
	OpenProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES, &hToken);
    LookupPrivilegeValue( NULL,  SE_DEBUG_NAME, &luid );
	
	tkp.Privileges->Luid = luid; 
    tkp.PrivilegeCount = 1;
    tkp.Privileges->Attributes = SE_PRIVILEGE_ENABLED;
    
    AdjustTokenPrivileges(hToken, FALSE, &tkp, 0, NULL, NULL);
       
    if(GetLastError()==0) ret = true;
	
	CloseHandle(hToken);
	return ret;
}



void main(int argc, char** argv)
{
		
	if(argc==1){
		printf("usage: findDll [module name]\n");
		exit(0);
	}


	if(!GetSeDebug()) printf(" Could not get SeDebug, should run as admin\n");

	find = strdup(_strlwr(argv[1]));
	printf("Scanning running processes for module: %s\n", find);
	ScanProcesses();

        
}
 
