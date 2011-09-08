/*
	License:   GPL
	Copyright: 2005 iDefense a Verisign Company
	Site:      http://labs.idefense.com

	Author:    David Zimmer <david@idefense.com, dzzie@yahoo.com>

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


	GdiProcess Scanner

	Quick-n-dirty app to scan the GDISharedHandleTable for unique 
	process ID's trying to find hidden processes. 

	This can currently detect most trojans/worms that use
	userland hooking to hide their process ID's from the 
	toolhelp and process API's

	As with any rootkit detection, its a game of trying to 
	find hidden reminants to detect them.

	Use the /c to auto-compare the GDI process list with the 
	toolhelp process list. See /? for more options.

	This is known to currently work against: 
	   AFXRootKit
	   Gaobot/Phatbots with API hooking
	   Maddis variants

	for more info on the gdiSharedHandleTable see
	http://msdn.microsoft.com/msdnmag/issues/03/01/GDILeaks/default.aspx


*/ 

#include "windows.h"
#include "stdio.h"
#include <tlhelp32.h> 


unsigned int handleCnt[200] = {0};
unsigned int gdi_pids[200] = {0};
unsigned int api_pids[200] = {0};

int gdiCnt = 0;
bool fullPath = false;
bool allocationUp = false;
const int MAX_GDI_HANDLE = 0x4000;

typedef LONG (WINAPI NTQIP)(HANDLE, WORD, PVOID, ULONG, PULONG);
NTQIP *lpfnNTQuery;

typedef struct{
   DWORD pKernelInfo;
   WORD  ProcessID; 
   WORD  _nCount;
   WORD  nUpper;
   WORD  nType;
   DWORD pUserInfo;
} GDITableEntry;

typedef struct{
  LIST_ENTRY              InLoadOrderModuleList;
  LIST_ENTRY              InMemoryOrderModuleList;
  LIST_ENTRY              InInitializationOrderModuleList;
  PVOID                   BaseAddress;
  PVOID                   EntryPoint;
  ULONG                   SizeOfImage;
  char*			          FullDllName;
  char*			          BaseDllName;
} LDR_MODULE;

typedef struct{
  ULONG                   Length;
  BOOLEAN                 Initialized;
  PVOID                   SsHandle;
  LIST_ENTRY              InLoadOrderModuleList;
  LIST_ENTRY              InMemoryOrderModuleList;
  LIST_ENTRY              InInitializationOrderModuleList;
} PEB_LDR_DATA,*PPEB_LDR_DATA;

typedef struct PEB { //shortened
  char					  Glob1[12];
  PPEB_LDR_DATA           LoaderData; //16 bytes to here
  char                    Glob2[132];  // = 152 - sizeof(PVOID) - 16
  GDITableEntry*          GdiSharedHandleTable; //152 bytes to here
} PEB;

typedef struct{
    PVOID  Reserved1;
    PEB* PebBaseAddress;
    PVOID  Reserved2[2];
    PVOID  UniqueProcessId;
    PVOID  Reserved3;
} PROCESS_BASIC_INFORMATION;


//XP SP2 randomizes PEB address so have to use this
//to support it. Default addr at bottom wont work that case.
PEB* GetPEBAddress(HANDLE hProc){

	PROCESS_BASIC_INFORMATION pbi;
	DWORD dwSize;

	if (lpfnNTQuery!=NULL){
		(*lpfnNTQuery)(hProc, 0, &pbi, sizeof(pbi), &dwSize);
		return pbi.PebBaseAddress ;
	}
	
	return (PEB*)0x7ffdf000;
}

void AddUniquePid(unsigned int pid){
	
	for(int i=0;i<gdiCnt+1;i++){
		if(gdi_pids[i] ==  pid){
			handleCnt[i]++;
			return ;
		}
	}

	if(gdiCnt==200){
		allocationUp = true;
		return;
	}

	gdiCnt++;
	handleCnt[gdiCnt]++;
	gdi_pids[gdiCnt]=pid;
}


int ScanUnicode(char* strIn, char* bufOut){
	
	int outLen=0;

	for(int i=0;i<255;i++){

		if(strIn[i] == 0 && strIn[i+1]==0) return outLen;
		
		if(strIn[i] != 0){
			bufOut[outLen] = strIn[i];
			outLen++;
		}
	}

	return outLen;
}


int TakeAPISnapShot(void){

	PROCESSENTRY32 pe;
    HANDLE hSnap;
	int cnt=0;
    
    pe.dwSize = sizeof(pe);
    hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    
    Process32First( hSnap, &pe);
    api_pids[cnt++] = pe.th32ProcessID;

    while( Process32Next(hSnap, &pe) ){
		 if(cnt==200){
			allocationUp = true;
			return cnt;
		 }
		 api_pids[cnt++] = pe.th32ProcessID;
	}

	return cnt;
}

void PruneApiTree(int apiCnt){
	for(int i=0; i<apiCnt+1; i++){
		for(int j=0; j<gdiCnt+1; j++){
			if(api_pids[i] == gdi_pids[j]){
				gdi_pids[j] = 0;
				api_pids[i] = 0;
				break;
			}
		}
	}
}

char* findProcessByPid(int pid){
	
	PROCESSENTRY32 pe;
    HANDLE hSnap;
	int cnt=0;
    
    pe.dwSize = sizeof(pe);
    hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    
    Process32First( hSnap, &pe);
    if( pe.th32ProcessID == pid ) return strdup(pe.szExeFile);

    while( Process32Next(hSnap, &pe) ){
		if( pe.th32ProcessID == pid ) return strdup(pe.szExeFile);
	}

	return strdup("-- Could not find pid with ToolHelp Api! --");

}

void GetProcessPath(int pid, char* buf){ 
//this is a round about way to avoid using EnumProcessModules and any PSAPI
//functions which would likely be hooked if rootkit is present
//OpenProcess or ReadProcessMemory could be too, question of how common atm...
	
	PEB peb;
	LDR_MODULE mod;	
	PEB_LDR_DATA pld;

	unsigned long sz;
	char tmp[255] = {0};
	char out[255] = {0};
	
	memset(&mod,0,sizeof(mod));
	memset(&peb,0,sizeof(peb));
	memset(&pld,0,sizeof(pld));

	HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, 0, pid);
	void *pebAddress = (void*)GetPEBAddress(hProc);
    
	if(hProc!=0){	
		
		try{
				if(!ReadProcessMemory(hProc, pebAddress, (void*)&peb, sizeof(PEB), &sz ) ){
					strcpy(buf, "Could not extract PEB from remote process");
					goto cleanup;
				}

				if(!ReadProcessMemory(hProc, peb.LoaderData, (void*)&pld, sizeof(PEB_LDR_DATA), &sz )){
					strcpy(buf, "Could not extract Loader Data from remote process\n");
					goto cleanup;
				}

				if(!ReadProcessMemory(hProc, pld.InLoadOrderModuleList.Flink , (void*)&mod, sizeof(LDR_MODULE), &sz )){
					strcpy(buf, "Could not extract module Data from remote process\n");
					goto cleanup;
				}

				if(!ReadProcessMemory(hProc, mod.BaseDllName, out, 254, &sz )){
					sprintf(buf,"Could not extract module path from remote process ptr=0x%x\n", mod.BaseDllName );
					goto cleanup;
				}	
				
				if(ScanUnicode(out, (char*)tmp ) == 0 ){
					strcpy(buf, "Error reading Scanning Unicode string");
					goto cleanup;
				}
			
				if(fullPath){
					strncpy(buf, tmp, 254);
				}
				else{
					sz = strlen(tmp);
					while(tmp[sz] != '\\' && sz > 0) sz--;
					
					if(sz>0){
						strncpy(buf, &tmp[sz+1], 254 );
					}else{
						strncpy(buf,tmp, 254);
					}
				}
	 
		 }
		 catch(...){
			strcpy(buf, "Error reading Processes PEB :(");
		 }
	
	}
	else{
		 //strcpy(buf, "---- Could not OpenProcess ----");
		 strcpy(buf, "Api: ");
		 strcat(buf, findProcessByPid(pid));
		 return;
	}


cleanup:
		CloseHandle(hProc);

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
		int apiCnt;
        char pth[300] ; 
		bool compare = false, display = false, help = false;

		while(argc-- > 1){
			argv++;
			if(strcmp(*argv, "/f")==0) fullPath = true;
			if(strcmp(*argv, "/c")==0) compare  = true;
			if(strcmp(*argv, "/d")==0) display  = true;
			if(strcmp(*argv, "/?")==0) help     = true;
			if(strcmp(*argv, "/h")==0) help     = true;
			if(strcmp(*argv, "-h")==0) help     = true;
			if(strcmp(*argv, "-?")==0) help     = true;
		}
		
		if(help){
			system("cls");
			printf("\n"
				   "  GDI Process Scanner - \n\n"
				   "  Scans the GDISharedHandleTable for processes id's\n"
				   "  which rootkits may be trying to hide from other\n"
				   "  techniques.\n\n"
				   "  Usage: gdiprocs.exe [ /f /c /d /? ]\n"
				   "\t/f\tDisplay Fullpath of processes\n"
				   "\t/c\tCompare process list w/WinApi results\n"
				   "\t/d\tDisplay GDI handle count per process\n"
				   "\t/?\tthis help screen\n\n");
			return;
		}

		lpfnNTQuery = (NTQIP *)GetProcAddress(GetModuleHandle("ntdll.dll"), "NtQueryInformationProcess");
		
		if(lpfnNTQuery == NULL){
			printf("Could not GetProcAddress(NtQueryInformationProcess)\n");
			printf("Have to use default PEB offset, Probably wont work on XP SP2\n");
		}

		HWND hWin = CreateWindow(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

		printf("GDI Process Scanner - \n\n"
			   "Scanning GDIShared Handle Table for unique process ids...\n\n");
	
		PEB *p = GetPEBAddress(GetCurrentProcess());
		
		for(int i=0; i < MAX_GDI_HANDLE; i++){
			AddUniquePid( p->GdiSharedHandleTable[i].ProcessID );
		}
	
		if(!GetSeDebug()) printf(" Could not get SeDebug, should run as admin\n");

		if(compare){
			apiCnt = TakeAPISnapShot();
			printf(" Compare Mode\n %5d processes returned by WinAPI\n", apiCnt );
			PruneApiTree(apiCnt);
		}
		
		if(allocationUp){ //chance of happening slim so not worth redesign
			printf(" ERROR: more than 200 processes found allocation ran out :-\\\n");
		}

		printf(" %5d processes returned by GDI table\n\n", gdiCnt);
		printf(" Processes listed in GDI:\n");
		printf(" -------------------------------------------------\n");

		for(i=0;i<gdiCnt+1;i++){
			if(gdi_pids[i] != 0){
				GetProcessPath(gdi_pids[i], pth);
				if(display) printf("%5d - %5d - %s\n", gdi_pids[i], handleCnt[i], pth);
				 else printf("%5d - %s\n", gdi_pids[i], pth);
			}
		}

		if(compare){

		    printf("\n\n API Processes not listed in GDI Table\n"
				   " ---------------------------------------------------\n");

			for(i=0;i<apiCnt+1;i++){
				if(api_pids[i] != 0){
					GetProcessPath(api_pids[i], pth);
				    printf("%5d - %s\n", api_pids[i], pth);
				}
			}

		}

		printf("\n\n");

        
}
 
