#include <windows.h>
#include <stdio.h>
#include <conio.h>
#include <windows.h>

bool FileExists(const char *fileName)
{
    DWORD fileAttr;
    fileAttr = GetFileAttributes(fileName);
    if (0xFFFFFFFF == fileAttr) return false;
    return true;
}


void main(int argc, char* argv[]){

	bool useCC = false;
	int h=0;
	
	char* primaryDll;

	system("cls && echo. && echo.");

	if(argc==1){
		printf("\n Usage loadlib.exe primary_dll dll_2 ... [/break]\n\n");
		printf(" You can load multiple dlls in case you want to\n");
		printf(" also load an api monitor or if the main one\n");
		printf(" expects another to be in memory already. Break\n");
		printf(" will trigger a breakpoint just before the first\n");
		printf(" one in the list is loaded.\n\n");
		exit(0);
	}

	for(int i=1; i < argc; i++){

		if(i==1){
			
			if( !FileExists(argv[i]) ){
				printf("File not found: %s",argv[i]);
				exit(0);
			}

			primaryDll = strdup(argv[1]);

		}else if(strcmp(argv[i],"/break")==0){

			useCC = true;

		}else{

			if( !FileExists(argv[i]) ){
				printf("File not found: %s",argv[i]);
				exit(0);
			}

			printf("Loading secondary dll: %s", argv[i]);
			printf(" base: %x\n", (int)LoadLibrary(argv[i]) );

		}

	}
	
	printf("Loading primary dll: %s\n", primaryDll);

	if(useCC){
		printf("Triggering breakpoint to attach debugger...\n");
		_asm int 3;
	}

	h = (int)LoadLibrary(primaryDll);

	printf("primary base=%x \n\nPress any key to exit...\n\n",h);
	getch();
	exit(0);

}

