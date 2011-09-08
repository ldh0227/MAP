VERSION 5.00
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "RICHTX32.OCX"
Begin VB.Form frmStrings 
   Caption         =   "Strings"
   ClientHeight    =   5340
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8415
   LinkTopic       =   "Form2"
   ScaleHeight     =   5340
   ScaleWidth      =   8415
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command3 
      Caption         =   "Save As"
      Height          =   315
      Left            =   3600
      TabIndex        =   4
      Top             =   0
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Find"
      Height          =   315
      Left            =   2340
      TabIndex        =   3
      Top             =   0
      Width           =   1215
   End
   Begin VB.TextBox Text1 
      Height          =   315
      Left            =   540
      TabIndex        =   2
      Top             =   0
      Width           =   1755
   End
   Begin RichTextLib.RichTextBox rtf 
      Height          =   4935
      Left            =   0
      TabIndex        =   0
      Top             =   360
      Width           =   8355
      _ExtentX        =   14737
      _ExtentY        =   8705
      _Version        =   393217
      Enabled         =   -1  'True
      HideSelection   =   0   'False
      ScrollBars      =   3
      TextRTF         =   $"frmPeek.frx":0000
   End
   Begin VB.Label Label1 
      Caption         =   "Find"
      Height          =   255
      Left            =   60
      TabIndex        =   1
      Top             =   60
      Width           =   435
   End
End
Attribute VB_Name = "frmStrings"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
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

Dim sSearch
Dim lastFind As Long


Dim d As New RegExp
Dim mc As MatchCollection
Dim m As Match
Dim ret() As String

Sub DisplayList(data As String)
    
    rtf.Text = data
    Me.Show 1
    
End Sub


Private Sub Command1_Click()
        
    On Error Resume Next
    
    If sSearch <> Text1 Then
        sSearch = Text1
        lastFind = 0
        lastFind = rtf.Find(sSearch)
        lastFind = lastFind + 1
    Else
        lastFind = rtf.Find(sSearch, lastFind)
        lastFind = lastFind + 1
    End If
    
    If lastFind > 0 Then
        rtf.SelStart = lastFind
        rtf.SelLength = Len(Text1)
    End If
    
End Sub

Private Sub Command3_Click()
    Dim f As String
    On Error GoTo hell
    f = dlg.SaveDialog(AllFiles, , "Save Report as", , Me.hWnd)
    If Len(f) = 0 Then Exit Sub
    fso.WriteFile f, rtf.Text
hell:
End Sub

Private Sub Form_Load()
    sSearch = -1
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    rtf.Move 100, rtf.Top, Me.Width - 300, Me.Height - rtf.Top - 400
End Sub
 
 

Sub ParseFile(fPath As String)
    On Error GoTo hell
    
    Dim f As Long, pointer As Long
    Dim buf()  As Byte
    Dim x As Long
    
    f = FreeFile
    
    If Not fso.FileExists(fPath) Then
        MsgBox "File not found: " & fPath, vbExclamation
        GoTo done
    End If
    
    'd.Pattern = "[a-z,A-Z,0-9 /?.\-_=+$\\@!*\(\)#]{4,}" 'ascii string search
    d.Pattern = "[\w0-9 /?.\-_=+$\\@!*\(\)#%~`\^&\|\{\}\[\]:;'""<>\,]{" & minStrLen & ",}"
    d.Global = True
    
    push ret, "File: " & fso.FileNameFromPath(fPath)
    push ret, "MD5:  " & LCase(hash.HashFile(fPath))
    push ret, "Size: " & FileLen(fPath) & vbCrLf
    push ret, "Ascii Strings:" & vbCrLf & String(75, "-")
    
    ReDim buf(9000)
    Open fPath For Binary Access Read As f
    
    Do While pointer < LOF(f)
        pointer = Seek(f)
        x = LOF(f) - pointer
        If x < 1 Then Exit Do
        If x < 9000 Then ReDim buf(x)
        Get f, , buf()
        Search buf
    Loop
    
    push ret, ""
    push ret, "Unicode Strings:" & vbCrLf & String(75, "-")
    
    'd.Pattern = "([\w0-9 /?.\-=+$\\@!*\(\)#][\x00]){4,}"
    d.Pattern = "([\w0-9 /?.\-=+$\\@!\*\(\)#%~`\^&\|\{\}\[\]:;'""<>\,][\x00]){" & minStrLen & ",}"
    
    ReDim buf(9000)
    pointer = 1
    Seek f, 1
    
    Do While pointer < LOF(f)
        pointer = Seek(f)
        x = LOF(f) - pointer
        If x < 1 Then Exit Do
        If x < 9000 Then ReDim buf(x)
        Get f, , buf()
        Search buf
    Loop
    
    Close f
    
    On Error Resume Next
    rtf.Text = Join(ret, vbCrLf)
    Erase ret
    Me.Show 1
   
        
Exit Sub
hell:
      MsgBox "Error getting strings: " & Err.Description, vbExclamation
      Close f
done:
      'Unload Me
      End
End Sub

Private Sub Search(buf() As Byte)
    Dim b As String
    
    b = StrConv(buf, vbUnicode)
    Set mc = d.Execute(b)
    
    For Each m In mc
        push ret(), Replace(m.value, Chr(0), Empty)
    Next
    
End Sub

