VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.Form Form1 
   Caption         =   "Socket Tool"
   ClientHeight    =   8160
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10305
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   8160
   ScaleWidth      =   10305
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox chkAutoScroll 
      Caption         =   "Auto Scroll Response"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   5040
      TabIndex        =   44
      Top             =   2400
      Width           =   2235
   End
   Begin VB.CommandButton cmdClear 
      Caption         =   "Clear"
      Height          =   255
      Left            =   9060
      TabIndex        =   43
      Top             =   2400
      Width           =   1155
   End
   Begin VB.CheckBox chkLastResponseOnly 
      Caption         =   "Show only last response"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   2760
      TabIndex        =   42
      Top             =   2400
      Value           =   1  'Checked
      Width           =   2235
   End
   Begin VB.Frame Frame3 
      Caption         =   "%TEMP% Files"
      ForeColor       =   &H00FF0000&
      Height          =   2235
      Left            =   6360
      TabIndex        =   38
      Top             =   4320
      Width           =   3915
      Begin VB.FileListBox fLst 
         Height          =   1650
         Left            =   60
         System          =   -1  'True
         TabIndex        =   41
         Top             =   480
         Width           =   3735
      End
      Begin VB.CommandButton Command1 
         Caption         =   "Refresh"
         Height          =   255
         Left            =   2940
         TabIndex        =   40
         Top             =   180
         Width           =   855
      End
      Begin VB.CommandButton cmdSelFileSize 
         Caption         =   "Selected FileSize"
         Height          =   255
         Left            =   1020
         TabIndex        =   39
         Top             =   180
         Width           =   1695
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Clipboards"
      ForeColor       =   &H00FF0000&
      Height          =   1515
      Left            =   60
      TabIndex        =   33
      Top             =   6600
      Width           =   10215
      Begin VB.TextBox txtClip 
         Height          =   975
         Left            =   60
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   35
         Top             =   480
         Width           =   4995
      End
      Begin VB.TextBox txtClip2 
         Height          =   975
         Left            =   5160
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   34
         Top             =   480
         Width           =   4935
      End
      Begin VB.Label Label1 
         Caption         =   "#1"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   2
         Left            =   60
         TabIndex        =   37
         Top             =   240
         Width           =   255
      End
      Begin VB.Label Label1 
         Caption         =   "#2"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   3
         Left            =   5160
         TabIndex        =   36
         Top             =   240
         Width           =   795
      End
   End
   Begin VB.CheckBox chkHexResponse 
      Caption         =   "HexDump"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   960
      TabIndex        =   32
      Top             =   2400
      Value           =   1  'Checked
      Width           =   1695
   End
   Begin VB.Frame Frame1 
      Caption         =   "Data Transform Tools"
      ForeColor       =   &H00FF0000&
      Height          =   2235
      Left            =   60
      TabIndex        =   12
      Top             =   4320
      Width           =   6255
      Begin VB.TextBox txtBinary 
         Height          =   255
         Left            =   120
         OLEDropMode     =   1  'Manual
         TabIndex        =   24
         Top             =   1260
         Width           =   4755
      End
      Begin VB.CommandButton cmdLoadFile 
         Caption         =   "Load File"
         Height          =   315
         Left            =   4980
         TabIndex        =   23
         Top             =   1260
         Width           =   1215
      End
      Begin VB.CommandButton cmdBufferSize 
         Caption         =   "Buffer up"
         Height          =   315
         Left            =   4980
         TabIndex        =   22
         Top             =   1560
         Width           =   1215
      End
      Begin VB.CommandButton cmdWHoleHit 
         Caption         =   "Send File"
         Height          =   315
         Left            =   4980
         TabIndex        =   21
         Top             =   1860
         Width           =   1215
      End
      Begin VB.TextBox txtFinalSize 
         Height          =   285
         Left            =   3660
         TabIndex        =   20
         Text            =   "17920"
         Top             =   1560
         Width           =   1215
      End
      Begin VB.TextBox txtChar 
         Height          =   315
         Left            =   900
         TabIndex        =   19
         Text            =   "CC"
         Top             =   540
         Width           =   975
      End
      Begin VB.TextBox txtNumReps 
         Height          =   315
         Left            =   2220
         TabIndex        =   18
         Text            =   "1000"
         Top             =   540
         Width           =   735
      End
      Begin VB.CommandButton cmdSendBuffer 
         Caption         =   "Now"
         Height          =   255
         Left            =   3060
         TabIndex        =   17
         Top             =   600
         Width           =   735
      End
      Begin VB.CheckBox chkLogin 
         Alignment       =   1  'Right Justify
         Caption         =   "prepend doom login"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Left            =   3240
         TabIndex        =   16
         Top             =   1920
         Width           =   1695
      End
      Begin VB.CheckBox chkInsertData 
         BackColor       =   &H8000000B&
         Caption         =   "OnSend"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Left            =   3900
         TabIndex        =   15
         Top             =   600
         Value           =   1  'Checked
         Width           =   975
      End
      Begin VB.CheckBox chkStripCRLF 
         Caption         =   "strip CRLF on send"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Left            =   60
         TabIndex        =   14
         Top             =   240
         Width           =   1695
      End
      Begin VB.TextBox txtEscapeChar 
         Height          =   285
         Left            =   3180
         TabIndex        =   13
         Text            =   "%"
         Top             =   180
         Width           =   435
      End
      Begin VB.Label lblIp 
         Caption         =   "Send File (Supports Drag && Drop)"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   30
         Top             =   1020
         Width           =   2475
      End
      Begin VB.Label lblIp 
         Caption         =   "Not Ready"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   29
         Top             =   1560
         Width           =   975
      End
      Begin VB.Label lblFileSize 
         Caption         =   "FileSize:"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Left            =   1140
         TabIndex        =   28
         Top             =   1560
         Width           =   1335
      End
      Begin VB.Label Label1 
         Caption         =   "Pad File Size to"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   0
         Left            =   2460
         TabIndex        =   27
         Top             =   1560
         Width           =   1095
      End
      Begin VB.Label lblIp 
         Caption         =   "[DATA] ->                          x"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   26
         Top             =   600
         Width           =   2295
      End
      Begin VB.Label Label1 
         Caption         =   "Escape Char"
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   4
         Left            =   2160
         TabIndex        =   25
         Top             =   240
         Width           =   975
      End
   End
   Begin VB.CommandButton Command5 
      Caption         =   "2"
      Height          =   255
      Left            =   4860
      TabIndex        =   10
      Top             =   120
      Width           =   375
   End
   Begin VB.CommandButton Command4 
      Caption         =   "1"
      Height          =   255
      Left            =   4500
      TabIndex        =   9
      Top             =   120
      Width           =   375
   End
   Begin VB.TextBox txtLog 
      BeginProperty Font 
         Name            =   "Terminal"
         Size            =   9
         Charset         =   255
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1575
      Left            =   60
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   8
      Top             =   2700
      Width           =   10215
   End
   Begin MSWinsockLib.Winsock ws 
      Left            =   10020
      Top             =   0
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin VB.CommandButton cmdClose 
      Caption         =   "Close"
      Height          =   315
      Left            =   9060
      TabIndex        =   5
      Top             =   60
      Width           =   1215
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "Send"
      Height          =   315
      Left            =   7680
      TabIndex        =   4
      Top             =   60
      Width           =   1215
   End
   Begin VB.CommandButton cmdConnect 
      Caption         =   "Connect"
      Height          =   315
      Left            =   6300
      TabIndex        =   3
      Top             =   60
      Width           =   1215
   End
   Begin VB.TextBox txtData 
      BeginProperty Font 
         Name            =   "Terminal"
         Size            =   9
         Charset         =   255
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1935
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   420
      Width           =   10275
   End
   Begin VB.TextBox txtPort 
      Height          =   255
      Left            =   3600
      TabIndex        =   1
      Text            =   "3127"
      Top             =   120
      Width           =   855
   End
   Begin VB.TextBox txtIp 
      Height          =   255
      Left            =   1860
      TabIndex        =   0
      Text            =   "127.0.0.1"
      Top             =   120
      Width           =   1275
   End
   Begin VB.Label Label1 
      Caption         =   "Send Buffer"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Index           =   5
      Left            =   60
      TabIndex        =   31
      Top             =   120
      Width           =   975
   End
   Begin VB.Label Label1 
      Caption         =   "Response"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Index           =   1
      Left            =   0
      TabIndex        =   11
      Top             =   2400
      Width           =   795
   End
   Begin VB.Label lblIp 
      Caption         =   "Port"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Index           =   1
      Left            =   3240
      TabIndex        =   7
      Top             =   120
      Width           =   375
   End
   Begin VB.Label lblIp 
      Caption         =   "Ip"
      ForeColor       =   &H00FF0000&
      Height          =   255
      Index           =   0
      Left            =   1500
      TabIndex        =   6
      Top             =   120
      Width           =   255
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Author: david@idefense.com
'
'Purpose: small tool to send text or binary data to backdoor server ports
'         to help in testing/probing their functionality.
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

Dim myBinary() As Byte

Private Type struc
    ip As String
    port As Long
    datachar As String
    datarep As Long
    onsend As Byte
    escChar As String
    shellcode As String
    stripCRLF As Byte
    hexdump As Byte
    autoscroll As Byte
    freshView As Byte
    clip1 As String
    clip2 As String
    data As String
    finalsz As Long
End Type

Private settings As struc

Private Sub SaveSettings()
   On Error Resume Next
   Dim f As Long
   
   f = FreeFile
   
   With settings
        .ip = txtIp
        .port = txtPort
        .datachar = txtChar
        .datarep = txtNumReps
        .onsend = chkInsertData
        .escChar = txtEscapeChar
        .shellcode = txtData
        .stripCRLF = chkStripCRLF
        .data = txtData
        .clip1 = txtClip
        .clip2 = txtClip2
        .freshView = chkLastResponseOnly.value
        .hexdump = chkHexResponse.value
        .autoscroll = chkAutoScroll.value
        .finalsz = CLng(txtFinalSize)
    End With
      
   Open App.path & "\options.dat" For Binary As f
   Put f, , settings
   Close f
   
End Sub

Private Sub LoadSettings()
   
   If Not FileExists(App.path & "\options.dat") Then Exit Sub
      
   On Error Resume Next
   Dim f As Long
   f = FreeFile
   
   Open App.path & "\options.dat" For Binary As f
   Get f, , settings
   Close f
   
   With settings
        txtIp = .ip
        txtPort = .port
        txtChar = .datachar
        txtNumReps = .datarep
        chkInsertData = .onsend
        txtEscapeChar = .escChar
        txtData = .shellcode
        chkStripCRLF = .stripCRLF
        txtData = .data
        txtClip = .clip1
        txtClip2 = .clip2
        chkLastResponseOnly.value = .freshView
        chkHexResponse.value = .hexdump
        chkAutoScroll.value = .autoscroll
        txtFinalSize = .finalsz
    End With
   
   
End Sub


 

Private Sub cmdBufferSize_Click()
    On Error GoTo hell
    ReDim Preserve myBinary(CLng(txtFinalSize) - 1)
    Exit Sub
hell: MsgBox Err.Description
End Sub

Private Sub cmdClear_Click()
    txtLog.Text = ""
End Sub

Private Sub cmdClose_Click()
   On Error Resume Next
   ws.Close
   Me.Caption = IIf(Err.Number = 0, "Closed...", "Error: " & Err.Description)
End Sub

Private Sub cmdConnect_Click()
    On Error Resume Next
    ws.Connect txtIp, CLng(txtPort)
    Me.Caption = IIf(Err.Number = 0, "Connected...", "Error: " & Err.Description)
End Sub

 
Private Sub cmdLoadFile_Click()
    On Error Resume Next
    If Not FileExists(txtBinary) Then
        MsgBox "Nofile"
    Else
        ReadFile (txtBinary)
        lblIp(4).Caption = "Ready"
        lblFileSize.Caption = "CurSize: " & UBound(myBinary)
    End If
End Sub

Private Sub cmdSelFileSize_Click()
    On Error Resume Next
    f = fLst.filename
    If Len(f) = 0 Then Exit Sub
    f = fLst.path & "\" & f
    MsgBox FileLen(f) & " Bytes"
End Sub

Private Sub cmdSend_Click()
    On Error GoTo hell
    
    Dim x As Long
    
    buf = txtData
    
    If chkStripCRLF.value = 1 Then
        buf = Replace(buf, vbCrLf, "")
    End If
    
    If chkInsertData.value = 1 Then
        buf = Replace(buf, "[DATA]", String(txtNumReps, Chr("&h" & txtChar)))
    End If
    
    buf = Escape(buf)
    
    ws.SendData buf
    Me.Caption = "Connected: " & Len(buf) & " Bytes Sent (" & Hex(Len(buf)) & ")"
    
    Exit Sub
hell:
    MsgBox Err.Description
    Me.Caption = "Error"
End Sub











Function Escape(it)
    Dim f(): Dim c()
    n = Replace(it, "+", " ")
    If InStr(n, txtEscapeChar) > 0 Then
        t = Split(n, txtEscapeChar)
        For i = 0 To UBound(t)
            a = Left(t(i), 2)
            b = IsHex(a)
            If b <> Empty Then
                push f(), txtEscapeChar & a
                push c(), b
            End If
        Next
        For i = 0 To UBound(f)
            n = Replace(n, f(i), c(i))
        Next
    End If
    Escape = n
End Function

Private Function IsHex(it)
    On Error GoTo out
      IsHex = Chr(Int("&H" & it))
    Exit Function
out:  IsHex = Empty
End Function

Sub push(ary, value) 'this modifies parent ary object
    On Error GoTo init
    x = UBound(ary) '<-throws Error If Not initalized
    ReDim Preserve ary(UBound(ary) + 1)
    ary(UBound(ary)) = value
    Exit Sub
init:     ReDim ary(0): ary(0) = value
End Sub
 
Private Sub cmdSendBuffer_Click()
    On Error GoTo hell
    Dim b As String
    
    For i = 1 To txtNumReps
        b = b & txtEscapeChar & txtChar
    Next
    
    txtData = Replace(txtData, "[DATA]", b, , , vbTextCompare)
    
    Exit Sub
hell:
    
End Sub

Private Sub cmdWHoleHit_Click()
   On Error GoTo hell
  
   Dim login(4) As Byte
   login(0) = &H85
   login(1) = &H13
   login(2) = &H3C
   login(3) = &H9E
   login(4) = &HA2
   
   x = UBound(myBinary) 'err if not loaded
   
   If chkLogin.value Then ws.SendData login()
   ws.SendData myBinary()
 
 Exit Sub
hell:  MsgBox Err.Description
End Sub

Private Sub Command1_Click()
    On Error Resume Next
    fLst.path = Environ("temp")
    fLst.Refresh
End Sub

Private Sub Command4_Click()
    Dim s As String
    s = txtClip
    txtClip = txtData
    txtData = s
End Sub

Private Sub Command5_Click()
 Dim s As String
    s = txtClip2
    txtClip2 = txtData
    txtData = s
End Sub

Private Sub Form_Load()
    Command1_Click 'load tmp files in listbox
    LoadSettings
    'txtBinary = App.path & "\test.exe"
End Sub

Private Sub Form_Unload(Cancel As Integer)
    SaveSettings
End Sub

Private Sub txtBinary_OLEDragDrop(data As DataObject, Effect As Long, Button As Integer, Shift As Integer, x As Single, Y As Single)
    On Error Resume Next
    txtBinary = data.Files(1)
End Sub

Private Sub ws_Close()
    Me.Caption = "Socket Closed..."
End Sub

Private Sub ws_DataArrival(ByVal bytesTotal As Long)
    Dim s As String
    On Error Resume Next
    ws.GetData s
    
    If chkLastResponseOnly.value = 1 Then txtLog = ""
    
    If chkHexResponse.value = 1 Then
        txtLog = txtLog & hexdump(s) & vbCrLf
    Else
        s = Replace(s, Chr(0), "\x00")
        txtLog = txtLog & s
    End If
    
    If chkAutoScroll.value Then txtLog.SelStart = Len(txtLog)
    
End Sub



Function ReadFile(filename)
  f = FreeFile
   ReDim myBinary(FileLen(filename))
   Open filename For Binary As #f        ' Open file.(can be text or image)
     Get f, , myBinary() ' Get entire Files data
   Close #f
   
End Function

Function FileExists(path) As Boolean
  If Len(path) = 0 Then Exit Function
  If Dir(path, vbHidden Or vbNormal Or vbReadOnly Or vbSystem) <> "" Then FileExists = True _
  Else FileExists = False
End Function

Private Sub ws_Error(ByVal Number As Integer, Description As String, ByVal Scode As Long, ByVal Source As String, ByVal HelpFile As String, ByVal HelpContext As Long, CancelDisplay As Boolean)
    Me.Caption = "Error: " & Description
End Sub




Function hexdump(it)
    Dim my, i, c, s, a, b
    Dim lines() As String
    
    my = ""
    For i = 1 To Len(it)
        a = Asc(Mid(it, i, 1))
        c = Hex(a)
        c = IIf(Len(c) = 1, "0" & c, c)
        b = b & IIf(a > 33 And a < 123, Chr(a), ".")
        my = my & c & " "
        If i Mod 16 = 0 Then
            push lines(), my & "  [" & b & "]"
            my = Empty
            b = Empty
        End If
    Next
    
    If Len(b) > 0 Then
        If Len(my) < 48 Then
            my = my & String(48 - Len(my), " ")
        End If
        If Len(b) < 16 Then
             b = b & String(16 - Len(b), " ")
        End If
        push lines(), my & "  [" & b & "]"
    End If
        
    If Len(it) < 16 Then
        hexdump = my & "  [" & b & "]"
    Else
        hexdump = Join(lines, vbCrLf)
    End If
    
    
End Function

 
