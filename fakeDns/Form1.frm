VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.Form Form1 
   Caption         =   "Fake DNS"
   ClientHeight    =   4785
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9870
   LinkTopic       =   "Form1"
   ScaleHeight     =   4785
   ScaleWidth      =   9870
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdClear 
      Caption         =   "Clear"
      Height          =   315
      Left            =   7680
      TabIndex        =   8
      Top             =   4440
      Width           =   885
   End
   Begin VB.CommandButton cmdCopy 
      Caption         =   "Copy"
      Height          =   285
      Left            =   8970
      TabIndex        =   7
      Top             =   4440
      Width           =   855
   End
   Begin VB.ListBox List1 
      Height          =   4350
      Left            =   7170
      TabIndex        =   6
      Top             =   30
      Width           =   2655
   End
   Begin VB.TextBox txtIp 
      Enabled         =   0   'False
      Height          =   315
      Left            =   4680
      TabIndex        =   1
      Text            =   "10.10.10.7"
      Top             =   4440
      Width           =   1515
   End
   Begin VB.OptionButton Option2 
      Caption         =   "User defined"
      Height          =   255
      Left            =   3420
      TabIndex        =   5
      Top             =   4500
      Width           =   1335
   End
   Begin VB.OptionButton Option1 
      Caption         =   "127.0.0.1"
      Height          =   255
      Left            =   2280
      TabIndex        =   4
      Top             =   4500
      Value           =   -1  'True
      Width           =   1035
   End
   Begin MSWinsockLib.Winsock ws 
      Index           =   0
      Left            =   5700
      Top             =   60
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
      Protocol        =   1
   End
   Begin VB.TextBox txtLog 
      BeginProperty Font 
         Name            =   "Terminal"
         Size            =   6
         Charset         =   255
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4395
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   3
      Top             =   0
      Width           =   7095
   End
   Begin VB.CommandButton cmdListen 
      Caption         =   "Listen"
      Height          =   315
      Left            =   6240
      TabIndex        =   2
      Tag             =   "0"
      Top             =   4440
      Width           =   855
   End
   Begin VB.Label Label2 
      Caption         =   "Redirect all DNS Queries to IP:"
      Height          =   195
      Left            =   0
      TabIndex        =   0
      Top             =   4500
      Width           =   2235
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'
'Author: david@idefense.com
'
'Purpose: a very quick-n-dirty dns server that allows you to
'         have all dns queries resolve to a predefined ip.
'         Currently only supports A-records, should support
'         MX queries at a latter date. Useful to force bots
'         and other malicious code to use your own services
'         for analysis. (ie. mail, web, irc servers etc)
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

'Private Type dns_pkt
'    transaction_id As Integer
'    flags As Integer 'bit fields
'    ques As Integer
'    ans_rrs As Integer
'    authority_rrs As Integer
'    aditional_rrs As Integer
'    strSize As Byte
'    queries(500) As Byte 'variable should be enough size
'    'format strSize = size of string
'    'ascii string of len strsize
'    'query type as integer
'    'query class as integer
'End Type

'for dns reponse
'mirror transaction_id
'flags 0x8180 = standard query response no error
'questions 1
'answers 1
'mirror question query
'add answer format (A record)
'   name: C0 0C (host name)
'   Type: 00 01 = host address  | 00 0f = MX
'   Class: 00 01
'   ttl:   00 00 34 ef  (some time interval)
'   datalen: 00 04
'   address: 40 eb ea 1e  (example = 64.235.234.30)

'               |name|type| class|   ttl     |len  |   ip      |
'Const reply = "C0 0C 00 01 00 01 00 00 51 81 00 04 7F 00 00 01 00"
'
'
'Updates:
'        8-11-05  added load/unload ws(1) while busy code: some dns
'                 clients would only work on first request and fail
'                 on all subsequent..this seems to fix it (dirty fix)
'
'
'                                                 127. 0. 0. 1
'                                                 \           /
Const reply = "C0 0C 00 01 00 01 00 00 51 81 00 04 7F 00 00 01"
Dim answer() As Byte

Private busy As Boolean
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Dim strings As New CStrings

Function BuildAnswer() As Boolean
    On Error GoTo failed
    
    Dim tmp() As String
    Dim ip() As Byte
    Dim i As Long
    
    tmp = Split(reply, " ")
    
    If Option2.value = True Then 'custom IP not 127.0.0.1
        ip() = GetBytes()
        For i = 12 To 15
            tmp(i) = Hex(ip(i - 12))
        Next
    End If
    
    ReDim answer(16)
     
    For i = 0 To UBound(tmp)
        answer(i) = CByte(CInt("&h" & tmp(i)))
    Next

    BuildAnswer = True
    
failed:

End Function


Private Sub cmdClear_Click()
    On Error Resume Next
    List1.Clear
    txtLog.Text = Empty
End Sub

Private Sub cmdCopy_Click()
    On Error Resume Next
    Dim tmp, i
    For i = 0 To List1.ListCount
        tmp = tmp & List1.List(i) & vbCrLf
    Next
    Clipboard.Clear
    Clipboard.SetText tmp
End Sub

Private Sub cmdListen_Click()
      
      On Error GoTo hell
      
      If cmdListen.Tag = 0 Then
         
        If Not isIpValid() Then
            MsgBox "Ip is not Valid it must be x.x.x.x decimal format", vbInformation
            Exit Sub
        End If
        
        If Not BuildAnswer() Then
            MsgBox "humm could not build answer?"
            Exit Sub
        End If
        
        cmdListen.Caption = "Close"
        cmdListen.Tag = 1
        txtIp.Enabled = False
        Option1.Enabled = False
        Option2.Enabled = False
         
        Load ws(1)
        ws(1).Bind 53
        
      Else
        
        cmdListen.Tag = 0
        cmdListen.Caption = "Listen"
        Option1.Enabled = True
        Option2.Enabled = True
        txtIp.Enabled = Option2.value
        ws(1).Close
        Unload ws(1)
        
      End If
      
    Exit Sub
hell:
    MsgBox "Error: " & Err.Description, vbExclamation
End Sub


Private Sub Form_Load()
    
    On Error Resume Next
    txtIp = GetSetting("iDefense", "fakeDNS", "ip", ws(1).LocalIP)
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    SaveSetting "iDefense", "fakeDNS", "ip", txtIp
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    'Me.Width = 7360
    'Me.Height = 5190
End Sub

Private Sub Option1_Click()
    With txtIp
       txtIp.BackColor = IIf(Option2.value, vbWhite, Me.BackColor)
       txtIp.Enabled = Option2.value
    End With
End Sub

Private Sub Option2_Click()
    With txtIp
       txtIp.BackColor = IIf(Option2.value, vbWhite, Me.BackColor)
       txtIp.Enabled = Option2.value
    End With
End Sub

Private Sub ws_DataArrival(index As Integer, ByVal bytesTotal As Long)
    On Error GoTo hell
   
    Dim i As Integer
    Dim b() As Byte
    Dim tmp
    Dim dmp
    Dim orgLen As Long
    
    While busy
        Sleep 10
        DoEvents
    Wend
    
    busy = True
    ws(1).GetData b()
    Log b(), "Request:  ( " & Now & " )"
    
    'todo: check what kind of query it is support mx and a
    'but for now just blindly reply as if it was a an A record request
    orgLen = UBound(b) + 1
    ReDim Preserve b(UBound(b) + 16)    'space to add our answer field
    CopyMemory b(orgLen), answer(0), 16 'copy our answer to buffer
    
    b(2) = &H81 '\_flags 0x8180 standard query response no error
    b(3) = &H80 '/
    b(6) = 0    '\_1 answer
    b(7) = 1    '/

    Log b(), "Response:"
    ws(1).SendData b()
    ws(1).Close
    
    Unload ws(1)
    Load ws(1)
    ws(1).Bind 53
    
    Sleep 10
    DoEvents
    busy = False
    Exit Sub
    
    
hell:
  busy = False
  'MsgBox Err.Description
  DoEvents
End Sub

Sub Extract(b() As Byte)
    On Error Resume Next
    Dim tmp, x, found, i
    Dim y As String
    
    y = StrConv(b(), vbUnicode)
    For i = 2 To 13 'cheat yet functional..
        y = Replace(y, Chr(i), ".")
    Next
    
    tmp = strings.FromString(y)
    tmp = Split(tmp, vbCrLf)
    For Each x In tmp
        found = False
        While VBA.Left(x, 1) = "."
            x = Mid(x, 2)
        Wend
        For i = 0 To List1.ListCount
            If UCase(List1.List(i)) = UCase(Trim(x)) Then
                found = True
                Exit For
            End If
        Next
        If Not found Then List1.AddItem Trim(x)
    Next
    
End Sub


Sub Log(it() As Byte, Optional header As String)
    
    On Error Resume Next
    
    Extract it()
    If Len(header) > 0 Then txtLog.SelText = IIf(Len(txtLog) > 0, vbCrLf & vbCrLf, "") & header
        
    txtLog.SelText = IIf(Len(txtLog) > 0, vbCrLf & vbCrLf, "") & hexdump(StrConv(it, vbUnicode))
    txtLog.SelStart = Len(txtLog)
 
End Sub

Function isIpValid() As Boolean
    On Error GoTo nope
    Call GetBytes
    isIpValid = True
Exit Function
nope:
End Function

Function GetBytes() As Byte()
    txtIp = Trim(txtIp)
    Dim tmp, i, ret(3) As Byte
    
    If Len(txtIp) = 0 Then Err.Raise 1
    
    tmp = Split(txtIp, ".")
    
    If UBound(tmp) <> 3 Then Err.Raise 2
 
    For i = 0 To UBound(ret)
        ret(i) = CByte(tmp(i))
    Next
    
    GetBytes = ret()
End Function

 

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
        hexdump = my & "  [" & b & "]" & vbCrLf
    Else
        hexdump = Join(lines, vbCrLf)
    End If
    
    
End Function

Sub push(ary, value) 'this modifies parent ary object
    On Error GoTo init
    Dim x As Long
    x = UBound(ary) '<-throws Error If Not initalized
    ReDim Preserve ary(UBound(ary) + 1)
    ary(UBound(ary)) = value
    Exit Sub
init:     ReDim ary(0): ary(0) = value
End Sub



Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function







'A RECORD REQUEST
'______________________________________________________________________
'00 01 01 00 00 01 00 00 00 00 00 00 06 67 6F 6F   [.............goo]
'67 6C 65 03 63 6F 6D 00 00 01 00 01 00 00 00 00   [gle.com.........]
'00 00 00 00 00 00 00 00 00 00 00 00 00            [.............   ]
'
'A RECORD ANSWER
'----------------------------------------------------------------------
'00 01 85 80 00 01 00 01 00 00 00 00 06 67 6F 6F   [.............goo]
'67 6C 65 03 63 6F 6D 00 00 01 00 01 C0 0C 00 01   [gle.com.........]
'00 01 00 00 51 81 00 04 7F 00 00 01 00            [....Q........   ]
'
'
'MX QUERY NOT IMPLEMENTED YET
'
'MX QUERY
'-----------------------------------------------------------------------------
'00 40 05 28 | 0B 24 00 A0 | C9 3D FC B2 | 08 00 45 00 [.@.(.$...=....E.]
'00 3C 35 13 | 00 00 80 11 | A6 19 0A 0A | 0A 07 A6 66 [.<5............f]
'A5 0D 07 7A | 00 35 00 28 | 88 F3 11 DF | 01 00 00 01 [...z.5.(........]
'00 00 00 00 | 00 00 0A 6C | 75 6E 61 72 | 70 61 67 65 [.......lunarpage]
'73 03 63 6F | 6D 00 00 0F | 00 01       |             [s.com.....]
'
'
'MX Response
'-----------------------------------------------------------------------------
'00 A0 C9 3D | FC B2 00 40 | 05 28 0B 24 | 08 00 45 00 [...=...@.(.$..E.]
'00 78 E0 8B | 40 00 F0 11 | 4A 64 A6 66 | A5 0D 0A 0A [.x..@...Jd.f....]
'0A 07 00 35 | 07 7A 00 64 | 2D E7 11 DF | 81 80 00 01 [...5.z.d-.......]
'00 01 00 02 | 00 00 0A 6C | 75 6E 61 72 | 70 61 67 65 [.......lunarpage]
'73 03 63 6F | 6D 00 00 0F | 00 01 C0 0C | 00 0F 00 01 [s.com...........]
'00 00 07 08 | 00 0C 00 00 | 07 6D 78 6C | 6F 67 69 63 [.........mxlogic]
'C0 0C C0 0C | 00 02 00 01 | 00 00 06 55 | 00 06 03 6E [...........U...n]
'73 32 C0 0C | C0 0C 00 02 | 00 01 00 00 | 06 55 00 06 [s2...........U..]
'03 6E 73 31 | C0 0C       |             |             [.ns1..]

