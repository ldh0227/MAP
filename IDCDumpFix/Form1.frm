VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "IAT DumpFix - Generate IDC file from olly dump for CALL PTR and JMP IATs"
   ClientHeight    =   3840
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7935
   LinkTopic       =   "Form1"
   ScaleHeight     =   3840
   ScaleWidth      =   7935
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox Check1 
      Caption         =   "Make Unk"
      Height          =   255
      Left            =   6600
      TabIndex        =   7
      Top             =   3240
      Width           =   1335
   End
   Begin VB.CommandButton cmdHelp 
      Caption         =   "?"
      Height          =   375
      Left            =   3300
      TabIndex        =   6
      Top             =   3420
      Width           =   435
   End
   Begin VB.CommandButton cmdSave 
      Caption         =   "Save As"
      Height          =   375
      Left            =   3960
      TabIndex        =   5
      Top             =   3420
      Width           =   1395
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Kill Lines Like"
      Height          =   375
      Left            =   1920
      TabIndex        =   4
      Top             =   3420
      Width           =   1275
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   315
      Left            =   60
      TabIndex        =   3
      Text            =   "*EAX,EAX*"
      Top             =   3420
      Width           =   1815
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Copy"
      Height          =   375
      Left            =   5460
      TabIndex        =   2
      Top             =   3420
      Width           =   1095
   End
   Begin VB.TextBox Text2 
      Height          =   3315
      Left            =   0
      MultiLine       =   -1  'True
      OLEDropMode     =   1  'Manual
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      Top             =   0
      Width           =   7875
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Generate IDC"
      Height          =   375
      Left            =   6660
      TabIndex        =   0
      Top             =   3420
      Width           =   1215
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'this was made about as quick as they come
'does what it needs to, no frills
'
'Author: david@idefense.com
'
'Purpose: small tool used for speed RE of packed binaries.
'         This tools gives you an easy way to make a disasm
'         readable after you have done a raw dump from memory
'         without requiring the time to rebuild the pe for a
'         clean disasm etc..See ? for more details
'
'License: Copyright (C) 2005 David Zimmer <david@idefense.com, dzzie@yahoo.com>
'
'         This program is free software; you can redistribute it and/or modify it
'         under the terms of the GNU General Public License as published by the Free
'         Software Foundation; either version 2 of the License, or (at your option)
'         any later version.
'
'         This program is distributed in the hope that it will be useful, but WITHOUT
'         ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
'         FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
'         more details.
'
'         You should have received a copy of the GNU General Public License along with
'         this program; if not, write to the Free Software Foundation, Inc., 59 Temple
'         Place, Suite 330, Boston, MA 02111-1307 USA

Dim unique As Collection
Dim dlg As New clsCmnDlg
Dim fso As New CFileSystem2

Private Sub cmdHelp_Click()
 
    Dim helpme As String
    On Error Resume Next
    
    helpme = App.Path & "\DumpFix_Readme.txt"
    
    If Not fso.FileExists(helpme) Then
        MsgBox "Could not locate helpfile: " & vbCrLf & vbCrLf & vbTab & helpme, vbExclamation
        Exit Sub
    End If
    
    Text2 = fso.ReadFile(helpme)
    
        
            
End Sub

Private Sub cmdSave_Click()
    On Error Resume Next
    Dim f As String
    dlg.SetCustomFilter "IDC Files", "*.idc"
    f = dlg.SaveDialog(CustomFilter, "", "Save As:")
    If Len(f) = 0 Then Exit Sub
    fso.WriteFile f, Text2
    If Err.Number = 0 Then
        MsgBox "Saved Successfuly", vbInformation
    End If
End Sub

Private Sub Command1_Click()
    On Error Resume Next
    
    header = "#define UNLOADED_FILE   1" & vbCrLf & _
             "#include <idc.idc>" & vbCrLf & vbCrLf & _
             "static main(void) {" & vbCrLf

    Set unique = New Collection
    
    f = Text2
    f = Split(f, vbCrLf) 'lines
    
    Dim addr As String
    Dim import As String
    
    For i = 0 To UBound(f)

        l = f(i)
        If InStr(l, "CALL") > 0 And InStr(l, "PTR") > 0 Then 'style 2
            ImportStyleCallPtr l, addr, import
        ElseIf InStr(l, "CALL") > 0 Then
            ImportStyleCall l, addr, import
        ElseIf InStr(l, "JMP") > 0 Then 'style 1
            ImportStyleJmp l, addr, import
        ElseIf InStr(l, ".") > 0 Then
            PointerTable l, addr, import
        End If


        If Len(import) = 0 Then GoTo nextone

        unique.Add CStr(import), CStr(import)

        import = Replace(import, "-", "_") 'some chars are reserved for IDA names

        'MakeName(0X4010E8,  "THISISMYSUB_2");
        If Check1.Value Then tmp = tmp & vbTab & "MakeUnkn(0X" & addr & ",1);" & vbCrLf
        tmp = tmp & vbTab & "MakeName(0X" & addr & ",""" & import & "_"");" & vbCrLf
        
        
nextone:
    Next
    
    Text2 = header & tmp & "}"
    
End Sub

Sub PointerTable(fileLine, addrVar, importNameVar)
    '43434394 >7C91137A  ntdll.RtlDeleteCriticalSection
    l = Split(fileLine, " ")
    addrVar = l(0)
    importNameVar = l(UBound(l))
    
    a = InStr(importNameVar, ".")
    If a > 0 Then
        importNameVar = Mid(importNameVar, a + 1)
    End If
    
    If KeyExistsInCollection(unique, CStr(importNameVar)) Then
        importNameVar = Empty
        addrVar = Empty
    End If
    
End Sub


'all variables byref modificed here
Sub ImportStyleJmp(fileLine, addrVar, importNameVar)
    '00402A98  FF25 7CF14100  JMP DWORD PTR DS:[41F17C] ; ADVAPI32.AdjustTokenPrivileges
    '--------                                             ------------------------------
    l = Split(fileLine, " ") 'words (we want first(address) and last (api name)
    addrVar = l(0)
    importNameVar = l(UBound(l))
    
    a = InStr(importNameVar, ".")
    If a > 0 Then
        importNameVar = Mid(importNameVar, a + 1)
    End If
    
    If KeyExistsInCollection(unique, CStr(importNameVar)) Then
        importNameVar = Empty
        addrVar = Empty
    End If
    
End Sub



'all variables byref modificed here
Sub ImportStyleCallPtr(fileLine, addrVar, importNameVar)
    '00401000   CALL DWORD PTR DS:[405100]                KERNEL32.FreeConsole
    '                              ------                 --------------------
    
    l = Split(Trim(fileLine), " ") 'words (we want first(address) and last (api name)
    importNameVar = l(UBound(l))
    
    a = InStr(importNameVar, ".")
    If a > 0 Then
        importNameVar = Mid(importNameVar, a + 1)
    End If
    
    a = InStr(fileLine, "[")
    b = InStr(fileLine, "]")
    If a > 0 And b > a Then
        a = a + 1
        addrVar = Mid(fileLine, a, b - a)
    End If
    
    If KeyExistsInCollection(unique, CStr(importNameVar)) Then
        importNameVar = Empty
        addrVar = Empty
    End If
    
End Sub

Sub ImportStyleCall(fileLine, addrVar, importNameVar)
    '00402330   CALL 13_5k.00403F66                       urlmon.URLDownloadToFileA
    '                      --------                       -------------------------
    On Error Resume Next
    
    l = Split(Trim(fileLine), " ") 'words (we want first(address) and last (api name)
    importNameVar = l(UBound(l))
    
    a = InStrRev(importNameVar, ".")
    If a > 0 Then
        importNameVar = Mid(importNameVar, a + 1)
    End If
    
    a = InStr(fileLine, ".")
    If a > 25 Then 'module name not call x.
        a = 0
        b = InStr(1, fileLine, "CALL ")
    Else
        b = InStr(a, fileLine, " ")
    End If
    
    If a > 0 And b > a Then
        a = a + 1
        addrVar = Mid(fileLine, a, b - a)
    ElseIf a < 1 And b > 0 Then
        b = b + 6
        addrVar = Mid(fileLine, b, InStr((b + 1), fileLine, " ") - b)
        addrVar = Replace(addrVar, vbTab, "")
        addrVar = Replace(addrVar, "]", "")
    Else
        addrVar = ""
        importNameVar = ""
        Exit Sub
    End If
        
    If KeyExistsInCollection(unique, CStr(importNameVar)) Then
        importNameVar = Empty
        addrVar = Empty
    End If
    
End Sub



Private Sub Command2_Click()
    Clipboard.Clear
    Clipboard.SetText Text2.Text
End Sub

Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function
    
Private Sub Text2_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)

    If Not fso.FileExists(Data.Files(1)) Then
        MsgBox "Files only"
        Exit Sub
    End If

    f = Data.Files(1)
    Text2 = fso.ReadFile(f)

End Sub



 

Private Sub Command3_Click()
    
    If Len(Text1) = 0 Then
        MsgBox "Enter expression to match, uses VB LIKE keyword", vbInformation
        Exit Sub
    End If
    
    tmp = Split(Text2, vbCrLf)
    For i = 0 To UBound(tmp)
        If tmp(i) Like Text1 Then tmp(i) = ""
    Next
    
    tmp = Join(tmp, vbCrLf)
    tmp = Replace(tmp, vbCrLf & vbCrLf, vbCrLf)
    Text2 = tmp
    
    
    
End Sub

Private Sub Text2_DblClick()
    Text2 = Clipboard.GetText
End Sub












