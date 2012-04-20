VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Install Shell Extensions"
   ClientHeight    =   2790
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5130
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2790
   ScaleWidth      =   5130
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.TextBox Text2 
      Appearance      =   0  'Flat
      Height          =   1575
      Left            =   60
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   6
      Text            =   "frmMain.frx":030A
      Top             =   60
      Width           =   4995
   End
   Begin VB.Frame Frame1 
      Height          =   615
      Left            =   60
      TabIndex        =   2
      Top             =   1650
      Width           =   4995
      Begin VB.CommandButton cmdMinLen 
         Caption         =   "Update"
         Height          =   255
         Left            =   4080
         TabIndex        =   5
         Top             =   240
         Width           =   795
      End
      Begin VB.TextBox Text1 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   3480
         TabIndex        =   4
         Text            =   "4"
         Top             =   180
         Width           =   495
      End
      Begin VB.Label Label2 
         Caption         =   """Strings"" minimum match length"
         Height          =   255
         Left            =   1080
         TabIndex        =   3
         Top             =   240
         Width           =   2355
      End
   End
   Begin VB.CommandButton cmdInstallRegKeys 
      Caption         =   "Install"
      Height          =   315
      Left            =   4020
      TabIndex        =   1
      Top             =   2370
      Width           =   1035
   End
   Begin VB.CommandButton cmdRemoveRegKeys 
      Caption         =   "Remove"
      Height          =   315
      Left            =   2880
      TabIndex        =   0
      Top             =   2370
      Width           =   1035
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'
'Author: david@idefense.com
'
'Purpose: small utility to add 3 shell extensions to explorer right click
'         context menus.
'
'         1) "Strings" contex menu item added for files
'                reads through the file and extracts all ascii and unicode strings
'                matching minimum predefined length. Results displayed in a popup form.
'                Uses the MS VBscript Regexp library should be pretty quick.
'
'         2) "Hash Files" contex menu item added for folders
'                enumerates all files in folder and pops up a form listing their names,
'                file sizes, and MD5 hash values. Also allows you to delete files from
'                the UI. Very useful for sorting directories full of malcode sample which
'                may contain duplicates.
'
'         3) "Decompile" context menu item added for chm files
'               this uses the -decompile option for hh.exe to decompile
'               the chm file you select into ./chm_src
'
'         4) "MD5 Hash" context menu added for all file types (added 12.15.05)
'               -bug fix 9/7/07 some ms service pack broke my vbdevkit md5 code..fixed now :-\
'
'         5) "Virus Total" context menu added for all file types (added 4-19-12)
'
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

Const peek = "*\shell\Strings\command"
Const hash = "Folder\shell\Hash Files\command"
Const deco = "chm.file\shell\Decompile\command"
Const m5 = "*\shell\Md5 Hash\command"
Const vt = "*\shell\Virus Total\command"

Private Sub cmdInstallRegKeys_Click()

    Dim cmdline_1 As String
    Dim cmdline_2 As String
    Dim cmdline_3 As String
    Dim cmdline_4 As String
    Dim cmdline_5 As String
    Dim reg As New clsRegistry2
    
    'note app.path will be wrong value to use in IDE unless you actually compile
    'a version to app.path, default compile dir is /source dir/../
    
    cmdline_1 = """" & App.path & "\shellext.exe"" ""%1"" /peek"
    cmdline_2 = """" & App.path & "\shellext.exe"" ""%1"" /hash"
    cmdline_3 = """" & App.path & "\shellext.exe"" ""%1"" /deco"
    cmdline_4 = """" & App.path & "\shellext.exe"" ""%1"" /md5f"
    cmdline_5 = """" & App.path & "\virustotal.exe"" ""%1"""
    
    On Error GoTo hell
    
    reg.hive = HKEY_CLASSES_ROOT
    
    If reg.CreateKey(peek) Then
        reg.SetValue peek, "", cmdline_1, REG_SZ
    Else
        MsgBox "You may not have permission to write to HKCR", vbExclamation
        Exit Sub
    End If
    
    If reg.CreateKey(hash) Then
        reg.SetValue hash, "", cmdline_2, REG_SZ
    End If
    
    If reg.CreateKey(deco) Then
        reg.SetValue deco, "", cmdline_3, REG_SZ
    End If
    
    If reg.CreateKey(m5) Then
        reg.SetValue m5, "", cmdline_4, REG_SZ
    End If
    
    If reg.CreateKey(vt) Then
        reg.SetValue vt, "", cmdline_5, REG_SZ
    End If
    
    MsgBox "Entries Added", vbInformation
    End
    
hell: MsgBox "Error adding keys: " & Err.Description

End Sub


Private Sub cmdMinLen_Click()

    If Not IsNumeric(Text1) Then
        MsgBox "String Length must be numeric", vbInformation
        Exit Sub
    End If
    
    On Error Resume Next
    minStrLen = CLng(Text1)
    If Len(minStrLen) = 0 Then minStrLen = 4
    SaveMySetting "minStrLen", minStrLen
    
End Sub

Private Sub cmdRemoveRegKeys_Click()
    
    Dim reg As New clsRegistry2
    Dim a As Boolean, b As Boolean, c As Boolean
    
    reg.hive = HKEY_CLASSES_ROOT
    
    a = True: b = True: c = True
    
    If reg.keyExists(peek) Then
        a = reg.DeleteKey(peek)
        a = reg.DeleteKey("*\shell\Strings\")
    End If
    
    If reg.keyExists(m5) Then
        a = reg.DeleteKey(m5)
        a = reg.DeleteKey("*\shell\Md5 Hash\")
    End If
    
    If reg.keyExists(vt) Then
        a = reg.DeleteKey(vt)
        a = reg.DeleteKey("*\shell\Virus Total\")
    End If
    
    If reg.keyExists(hash) Then
        b = reg.DeleteKey(hash)
        b = reg.DeleteKey("Folder\shell\Hash Files")
    End If
    
    If reg.keyExists(deco) Then
       c = reg.DeleteKey(deco)
       c = reg.DeleteKey("chm.file\shell\Decompile")
    End If
    
    
    If a And b And c Then
        MsgBox "Keys deleted        ", vbInformation
    Else
        MsgBox "Could not delete all regkeys", vbExclamation
    End If
    
    End
    
End Sub

Private Sub Form_Load()
       
    Dim mode As Long
    Dim cmd As String
       
    'frmFileHash.ShowFileStats "c:\boot.ini"
    'Exit Sub
    
       
    cmd = Replace(Command, """", "")
    
    On Error Resume Next
    minStrLen = CLng(GetMySetting("minStrLen", 4))
    If Len(minStrLen) = 0 Then minStrLen = 4
    Text1 = minStrLen
    
    If Len(cmd) > 0 Then
        If VBA.Right(cmd, 5) = "/peek" Then mode = 1
        If VBA.Right(cmd, 5) = "/hash" Then mode = 2
        If VBA.Right(cmd, 5) = "/deco" Then mode = 3
        If VBA.Right(cmd, 5) = "/md5f" Then mode = 4
        
        cmd = Trim(Mid(cmd, 1, Len(cmd) - 5))
        
        Select Case mode
            Case 1: frmStrings.ParseFile cmd
            Case 2: frmHash.HashDir cmd
            Case 3: DecompileChm cmd
            Case 4: frmFileHash.ShowFileStats cmd
            Case Else: MsgBox "Unknown Option", vbExclamation
        End Select
        
        Unload Me
        
    Else
        Me.Visible = True
    End If
    
    
End Sub

Sub DecompileChm(pth As String)
    On Error GoTo hell
    
    Dim pf As String
    Dim cmd As String
    Dim tmp As String
    Dim fn As String
    
    pf = fso.GetParentFolder(pth)
        
    If InStr(pth, " ") < 1 Then
            pf = pf & "\chm_src"
    Else 'hh bugs! cant handle spaces in path or " this sucks...
    
        tmp = Environ("TEMP")
        If Len(tmp) = 0 Then
            tmp = Environ("TMP")
            If Len(tmp) = 0 Then
                MsgBox "Chm path has space char in it and Enviroment variable TEMP not set sorry exiting"
                Exit Sub
            End If
        End If
        
        If Not fso.FolderExists(tmp) Then
            MsgBox "TEMP variable points to invalid directory?"
            Exit Sub
        End If
        
        fn = fso.FileNameFromPath(pth)
        If InStr(fn, " ") > 0 Then fn = Replace(fn, " ", "")
        
        fn = tmp & "\" & fn
        If fso.FileExists(fn) Then Kill fn
        FileCopy pth, fn
        
        tmp = tmp & "\chm_src"
        If fso.FolderExists(tmp) Then fso.DeleteFolder tmp
        
        pf = tmp
        pth = fn
    End If
    
    If Not fso.FolderExists(pf) Then MkDir pf
    
    cmd = "hh -decompile " & pf & " " & pth
    'InputBox "", , cmd
    
    Shell cmd
    Shell "explorer " & pf, vbNormalFocus
    
    Exit Sub
hell: MsgBox "Error Decompiling CHM: " & Err.Description
End Sub
