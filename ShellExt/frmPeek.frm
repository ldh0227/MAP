VERSION 5.00
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "RICHTX32.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
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
   Begin VB.CommandButton cmdFindAll 
      Caption         =   "All"
      Height          =   315
      Left            =   4440
      TabIndex        =   9
      Top             =   0
      Width           =   885
   End
   Begin VB.CommandButton cmdRescan 
      Caption         =   "Rescan"
      Height          =   315
      Left            =   7620
      TabIndex        =   8
      Top             =   30
      Width           =   735
   End
   Begin VB.TextBox txtMinLen 
      Height          =   285
      Left            =   6930
      TabIndex        =   7
      Text            =   "6"
      Top             =   30
      Width           =   615
   End
   Begin MSComctlLib.ProgressBar pb 
      Height          =   225
      Left            =   60
      TabIndex        =   5
      Top             =   330
      Width           =   8325
      _ExtentX        =   14684
      _ExtentY        =   397
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Save As"
      Height          =   315
      Left            =   5370
      TabIndex        =   4
      Top             =   0
      Width           =   855
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Find"
      Height          =   315
      Left            =   3510
      TabIndex        =   3
      Top             =   0
      Width           =   855
   End
   Begin VB.TextBox Text1 
      Height          =   315
      Left            =   540
      TabIndex        =   2
      Top             =   0
      Width           =   2895
   End
   Begin RichTextLib.RichTextBox rtf 
      Height          =   4695
      Left            =   0
      TabIndex        =   0
      Top             =   600
      Width           =   8355
      _ExtentX        =   14737
      _ExtentY        =   8281
      _Version        =   393217
      HideSelection   =   0   'False
      ScrollBars      =   3
      TextRTF         =   $"frmPeek.frx":0000
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Courier New"
         Size            =   11.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.Label Label2 
      Caption         =   "Min Size"
      Height          =   255
      Left            =   6300
      TabIndex        =   6
      Top             =   60
      Width           =   645
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
Dim lastSize As Long
Dim curFile As String

Dim d As New RegExp
Dim mc As MatchCollection
Dim m As match
Dim ret() As String

Sub DisplayList(data As String)
    
    rtf.Text = data
    Me.Show 1
    
End Sub


Private Sub cmdFindAll_Click()
    On Error Resume Next
    
    Dim tmp, x, ret(), i, f As String
    
    If Len(Text1) = 0 Then Exit Sub
    tmp = Split(rtf.Text, vbCrLf)
    
    pb.value = 0
    For Each x In tmp
         i = i + 1
        If InStr(1, x, Text1, vbTextCompare) > 0 Then
            push ret, x
        End If
        If i Mod 5 = 0 Then setPB i, UBound(tmp)
    Next
    pb.value = 0
    
    x = UBound(ret)
    If x < 0 Then
        Me.Caption = "No results found.."
        Exit Sub
    End If
    
    f = fso.GetFreeFileName(Environ("temp"))
    fso.WriteFile f, Join(ret, vbCrLf)
    Shell "notepad.exe """ & f & """", vbNormalFocus
    
    
    
    
End Sub

Private Sub cmdRescan_Click()
    ParseFile curFile
End Sub

Private Sub Command1_Click()
        
    On Error Resume Next
    
    If sSearch <> Text1 Then
        sSearch = Text1
        lastFind = 0
        lastFind = rtf.Find(sSearch)
        lastFind = lastFind + 1
        Me.Caption = "Search for: " & Text1 & " - " & occuranceCount(rtf.Text, Text1) & " hits"
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
    f = dlg.SaveDialog(textFiles, , "Save Report as", , Me.hWnd)
    If Len(f) = 0 Then Exit Sub
    fso.WriteFile f, rtf.Text
hell:
End Sub

Private Sub Form_Load()
    sSearch = -1
    txtMinLen = minStrLen 'global
    pb.max = 100
    pb.value = 0
    RestoreFormSizeAnPosition Me
    Me.Visible = True
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    rtf.Move 100, rtf.Top, Me.Width - 300, Me.Height - rtf.Top - 400
    pb.Width = rtf.Width
End Sub
 
 Sub setPB(cur, max)
    On Error Resume Next
    pb.value = (cur / max) * 100
    Me.Refresh
    DoEvents
 End Sub


Sub ParseFile(fpath As String)
    On Error GoTo hell
    
    Dim f As Long, pointer As Long
    Dim buf()  As Byte
    Dim x As Long
    
    f = FreeFile
    curFile = fpath
    
    If Not IsNumeric(txtMinLen) Then txtMinLen = 4
    
    If lastSize = txtMinLen Then Exit Sub
    lastSize = CLng(txtMinLen)
    
    If Not fso.FileExists(fpath) Then
        MsgBox "File not found: " & fpath, vbExclamation
        GoTo done
    End If
    
    'd.Pattern = "[a-z,A-Z,0-9 /?.\-_=+$\\@!*\(\)#]{4,}" 'ascii string search
    d.Pattern = "[\w0-9 /?.\-_=+$\\@!*\(\)#%~`\^&\|\{\}\[\]:;'""<>\,]{" & txtMinLen & ",}"
    d.Global = True
    
    Me.Caption = "Scanning for ASCII Strings..."
    push ret, "File: " & fso.FileNameFromPath(fpath)
    push ret, "MD5:  " & LCase(hash.HashFile(fpath))
    push ret, "Size: " & FileLen(fpath) & vbCrLf
    push ret, "Ascii Strings:" & vbCrLf & String(75, "-")
    
    ReDim buf(9000)
    Open fpath For Binary Access Read As f
    
    pb.value = 0
    Do While pointer < LOF(f)
        pointer = Seek(f)
        x = LOF(f) - pointer
        If x < 1 Then Exit Do
        If x < 9000 Then ReDim buf(x)
        Get f, , buf()
        Search buf, pointer
        setPB pointer, LOF(f)
    Loop
    
    Me.Caption = "Scanning for unicode strings.."
    push ret, ""
    push ret, "Unicode Strings:" & vbCrLf & String(75, "-")
    
    'd.Pattern = "([\w0-9 /?.\-=+$\\@!*\(\)#][\x00]){4,}"
    d.Pattern = "([\w0-9 /?.\-=+$\\@!\*\(\)#%~`\^&\|\{\}\[\]:;'""<>\,][\x00]){" & txtMinLen & ",}"
    
    ReDim buf(9000)
    pointer = 1
    Seek f, 1
    
    pb.value = 0
    Do While pointer < LOF(f)
        pointer = Seek(f)
        x = LOF(f) - pointer
        If x < 1 Then Exit Do
        If x < 9000 Then ReDim buf(x)
        Get f, , buf()
        Search buf, pointer
        setPB pointer, LOF(f)
    Loop
    pb.value = 0
    
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

Private Sub Search(buf() As Byte, offset As Long)
    Dim b As String
    
    b = StrConv(buf, vbUnicode)
    Set mc = d.Execute(b)
    
    For Each m In mc
        push ret(), pad(m.FirstIndex + offset - 1) & "  " & Replace(m.value, Chr(0), Empty)
    Next
    
End Sub

Function pad(x, Optional leng = 8)
    On Error Resume Next
    x = Hex(x)
    While Len(x) < leng
        x = "0" & x
    Wend
    pad = x
End Function

Private Sub Form_Unload(Cancel As Integer)
    SaveFormSizeAnPosition Me
End Sub
