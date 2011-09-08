VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form Form1 
   Caption         =   "Mailpot SMTP Trap"
   ClientHeight    =   4935
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   11880
   Icon            =   "Form1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   4935
   ScaleWidth      =   11880
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame1 
      BorderStyle     =   0  'None
      Height          =   495
      Left            =   0
      TabIndex        =   2
      Top             =   4320
      Width           =   11895
      Begin VB.TextBox txtServerBanner 
         Height          =   315
         Left            =   4800
         TabIndex        =   5
         Text            =   " "
         Top             =   120
         Width           =   5235
      End
      Begin VB.TextBox txtLocalPort 
         Height          =   285
         Left            =   2640
         TabIndex        =   4
         Text            =   "25"
         Top             =   120
         Width           =   735
      End
      Begin VB.CommandButton cmdListen 
         Caption         =   "Listen"
         Height          =   315
         Left            =   10200
         TabIndex        =   3
         Tag             =   "0"
         Top             =   120
         Width           =   1635
      End
      Begin VB.Label Label1 
         Caption         =   "Log Dir = C:\mailpot\    Listen Port = "
         Height          =   315
         Index           =   0
         Left            =   0
         TabIndex        =   7
         Top             =   180
         Width           =   2595
      End
      Begin VB.Label Label1 
         Caption         =   "Server Banner"
         Height          =   255
         Index           =   1
         Left            =   3660
         TabIndex        =   6
         Top             =   180
         Width           =   1275
      End
   End
   Begin MSWinsockLib.Winsock ws 
      Index           =   0
      Left            =   10560
      Top             =   3120
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin VB.Timer Timer1 
      Interval        =   20000
      Left            =   11400
      Top             =   3120
   End
   Begin VB.Timer tmrTimeout 
      Enabled         =   0   'False
      Index           =   0
      Interval        =   8000
      Left            =   10980
      Top             =   3120
   End
   Begin MSComctlLib.ListView lv 
      Height          =   4335
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   10155
      _ExtentX        =   17912
      _ExtentY        =   7646
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      HotTracking     =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   8
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "ConnectedAt"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "RcptTo"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Bytes"
         Object.Width           =   1235
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "FileName"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(5) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   4
         Text            =   "RemoteIP"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(6) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   5
         Text            =   "Subject"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(7) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   6
         Text            =   "Attachment"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(8) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   7
         Text            =   "Stage"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.ListBox lst2 
      Height          =   4350
      Left            =   10200
      TabIndex        =   0
      Top             =   0
      Width           =   1635
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuViewFile 
         Caption         =   "View File"
      End
      Begin VB.Menu mnuCloseConnection 
         Caption         =   "Close Connection"
      End
      Begin VB.Menu mnuCopytoDesktop 
         Caption         =   "Copy file to desktop"
      End
      Begin VB.Menu mnuSpacer1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuClearListview 
         Caption         =   "Clear ListView"
      End
      Begin VB.Menu mnuCopyAll 
         Caption         =   "Copy All Fields"
      End
      Begin VB.Menu mnuSpacer 
         Caption         =   "-"
      End
      Begin VB.Menu mnuWhois 
         Caption         =   "Whois"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'Author: david@idefense.com
'
'Purpose: small lab quality tool for capturing emails sent out my
'         trojans and mass mailers. If they use Outlook automation,
'         configure your outlook client to this server. If they
'         connect to an open relay to send by domain name, use fakedns
'         to redirect them here. If they do a MX lookup then you need to
'         do something different I dont support that yet in fakedns.
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
'
'
'ChangeLog
'           12.30.05 - removed splash, option to set port, save settings
'           01.09.05 - added 500 err msg for unsupported smtp cmds (Zori.c)
'                    - increased timeout to 8 seconds idle
'                    - implemented cmd recv buffer, wait till CR or LF before eval smtp cmd
'                    - changed method of adding items to listview could bug out on fast sends
'                    - added form resize code so you can maximize
'                    - fixed display bug with right hand log window
'           02.03.06 - added support for rset, noop, vrfy commands (thanks vinoo)


Public fso As New clsFileSystem
Dim mailLog() As CmaiLog
Dim selLi As ListItem
'Public db As New clsAdoKit

Const MAXFILESIZE As Long = 2433998 '~2.3MB
Const MAXCONNECTS As Long = 50
Const txtLogDir = "c:\mailpot\"

Private Declare Function SHGetPathFromIDList Lib "Shell32" Alias "SHGetPathFromIDListA" (ByVal pidl As Long, ByVal pszPath As String) As Long
Private Declare Function SHGetSpecialFolderLocation Lib "Shell32" (ByVal hwndOwner As Long, ByVal nFolder As Long, pidl As Long) As Long
Private Declare Sub CoTaskMemFree Lib "ole32" (ByVal pv As Long)


Private Sub cmdListen_Click()
   On Error GoTo hell
   Dim locPort As Long
   
    With cmdListen
        If .Tag = 0 Then
           
            If Not fso.FolderExists(txtLogDir) Then
                MsgBox "Log Dir does not exist!", vbCritical
                Exit Sub
            End If
            
1            locPort = CLng(txtLocalPort)
            
            ws(0).LocalPort = locPort
2            ws(0).Listen
            Me.Caption = "Mailpot Active: Listening on:" & locPort
            .Tag = 1
            .Caption = "Close"
            
            log "Started: " & Now
            txtLocalPort.Enabled = False
        Else
            ws(0).Close
            .Tag = 0
            .Caption = "Listen"
            Me.Caption = "Closed"
            log "Stopped: " & Now
            txtLocalPort.Enabled = True
        End If
    End With
    
    
    
Exit Sub
hell:
      If Erl = 1 Then
            MsgBox "Invalid port specified"
      ElseIf Erl = 2 Then
            MsgBox "This port must already be in use " & Err.Description
      Else
            MsgBox Err.Description
      End If
      txtLocalPort.Enabled = True
      
      
End Sub

Private Sub Form_Load()

    'db.BuildConnectionString Access, "mailpot.mdb"
    
    ReDim mailLog(MAXCONNECTS)
    
    If Not fso.FolderExists(txtLogDir) Then
        fso.CreateFolder txtLogDir
    End If
    
    txtServerBanner = GetSetting("MailPot", "Settings", "Banner", "Maillennium ESMTP/MULTIBOX")
    txtLocalPort = GetSetting("MailPot", "Settings", "LocalPort", "25")
    
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    
    If Me.WindowState = vbMinimized Then Exit Sub
    
    If Me.Height < (Frame1.Height * 4) Then Me.Height = (Frame1.Height * 4)
    If Me.Width < (Frame1.Width + 80) Then Me.Width = Frame1.Width + 80
    
    lv.Width = Me.Width - lst2.Width - 150
    lst2.Left = Me.Width - lst2.Width - 100
    
    lv.Height = Me.Height - Frame1.Height - 400
    lst2.Height = lv.Height
    Frame1.Top = Me.Height - Frame1.Height - 400
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    SaveSetting "MailPot", "Settings", "Banner", txtServerBanner
    SaveSetting "MailPot", "Settings", "LocalPort", txtLocalPort
End Sub

Private Sub lv_DblClick()
    If selLi Is Nothing Then Exit Sub
    
    On Error Resume Next
    Shell "notepad """ & txtLogDir & selLi.SubItems(3) & """", vbNormalFocus
    
End Sub

Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Set selLi = Nothing
    Set selLi = Item
End Sub

Private Sub lv_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then PopupMenu mnuPopup
End Sub

 

Private Sub mnuClearListview_Click()
    If MsgBox("Are you sure?", vbYesNo) = vbYes Then
        lv.ListItems.Clear
    End If
End Sub

Private Sub mnuCloseConnection_Click()
    
    On Error Resume Next
    Dim parts() As String
    Dim sckHnd As Integer, host As String
    
    If selLi Is Nothing Then Exit Sub
    
    parts = Split(selLi.Tag, ":")
    sckHnd = CInt(parts(0))
    host = parts(1)
    
    If sckHnd = 0 Then
        MsgBox "Handle = 0 oops"
        Exit Sub
    End If
    
    If ws(sckHnd).State <> sckConnected Then
        MsgBox "Ws(" & sckHnd & ").State = " & ws(sckHnd).State
    End If
    
    If ws(sckHnd).RemoteHostIP <> host Then
        If MsgBox("Current Host: " & ws(sckHnd).RemoteHostIP & vbCrLf & _
                   " Should be  : " & host & vbCrLf & vbCrLf & _
                   "Should I close it?", vbYesNo) = vbNo Then
                   
            Exit Sub
        End If
    End If
            
    ws(sckHnd).Close
    ws_Close sckHnd
    
End Sub

Private Sub mnuCopyAll_Click()
    On Error Resume Next
    Clipboard.Clear
    Clipboard.SetText GetAllElements(lv)
End Sub

Function GetAllElements(lv As ListView) As String
    Dim ret() As String, i As Integer, tmp As String
    Dim li As ListItem

    For i = 1 To lv.ColumnHeaders.Count
        tmp = tmp & lv.ColumnHeaders(i).Text & vbTab
    Next

    push ret, tmp

    For Each li In lv.ListItems
        tmp = li.Text & vbTab
        For i = 1 To lv.ColumnHeaders.Count - 1
            tmp = tmp & li.SubItems(i) & vbTab
        Next
        push ret, tmp
    Next

    GetAllElements = Join(ret, vbCrLf)

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

Private Sub mnuCopytoDesktop_Click()
     On Error GoTo hell
    If selLi Is Nothing Then Exit Sub
    
    Dim fName As String
    fName = selLi.SubItems(3)
    fName = txtLogDir & "\" & fName
    
    If Not fso.FileExists(fName) Then
        MsgBox "File not found: " & vbCrLf & vbCrLf & fName
    Else
        fso.Copy fName, UserDeskTopFolder()
        'Shell "notepad """ & fName & """", vbNormalFocus
        MsgBox "Copy Complete", vbInformation
    End If
    
    Exit Sub
hell: MsgBox Err.Description
End Sub
 
 



Private Sub mnuViewFile_Click()
    On Error GoTo hell
    If selLi Is Nothing Then Exit Sub
    
    Dim fName As String
    fName = selLi.SubItems(3)
    fName = txtLogDir & "\" & fName
    
    If Not fso.FileExists(fName) Then
        MsgBox "File not found: " & vbCrLf & vbCrLf & fName
    Else
        Shell "notepad """ & fName & """", vbNormalFocus
    End If
    
    Exit Sub
hell: MsgBox Err.Description
End Sub

Private Sub mnuWhois_Click()
    On Error GoTo hell
    If selLi Is Nothing Then Exit Sub
    
    Dim ip As String
    ip = Trim(selLi.SubItems(4))
    
    If Len(ip) = 0 Then Exit Sub
    
    ip = "cmd /k whois " & ip 'xp, 2k specific, we do not support win98 or me here
    
    Shell ip, vbNormalFocus
    
    Exit Sub
hell:
      MsgBox "Do you have whois.exe in your path? " & vbCrLf & _
             "Note the cmd line we use is cmd.exe specific" & vbCrLf & _
              vbCrLf & _
             "Error: " & Err.Description
             
End Sub

Private Sub Timer1_Timer()
    lst2.Clear
End Sub

Private Sub tmrTimeout_Timer(Index As Integer)
    On Error Resume Next
    ws(Index).Close
    ws_Close Index
    tmrTimeout(Index).Enabled = False
End Sub

 

Private Sub ws_Close(Index As Integer)
    On Error Resume Next
    Dim li As ListItem
      
    mailLog(Index).SetLVData
    log "Closed: " & Index & " Bytes: " & mailLog(Index).MailSize
    
    'we should also add in FROM and TO and SUBJECT
    'db.Update "tbldata", "where fsize=" & ObjPtr(li), "endtime,fsize,malcode,attachmentname", Now, li.SubItems(2), li.SubItems(5), li.SubItems(6)
      
    ws(Index).Close
    tmrTimeout(Index).Enabled = False
     
End Sub

Private Sub ws_ConnectionRequest(Index As Integer, ByVal requestID As Long)
    Dim x As Integer
    Dim i As Integer
    On Error Resume Next
    
    x = -1
    For i = 1 To ws.UBound
        If ws(i).State <> sckConnected And _
           ws(i).State <> sckConnecting And _
           ws(i).State <> sckConnectionPending Then
           '------
           x = i
           Exit For
        End If
    Next

    If x < 1 Then
        If ws.UBound > MAXCONNECTS Then
            log MAXCONNECTS & " Sockets Reached Denying connection>" & ws(Index).RemoteHostIP
            Exit Sub
        Else
            x = ws.UBound + 1
            Load ws(x)
            Load tmrTimeout(x)
        End If
    End If
    
    Dim tmp As String, tmpHnd As Long
    
    tmp = fso.GetFreeFileName(txtLogDir, ".txt")
        
    Dim li As ListItem
    Set li = lv.ListItems.Add(, , Now)
    li.SubItems(3) = fso.FileNameFromPath(tmp)
    li.SubItems(4) = ws(0).RemoteHostIP
    li.Tag = x & ":" & ws(0).RemoteHostIP 'socket index:remote host
    
    
    'fsize = objptr(li) (cheat!)
    'db.Insert "tbldata", "starttime,ip,fname,localport,fsize, remoteport", _
    '                     li.Text, li.SubItems(4), li.SubItems(3), txtLocalPort, ObjPtr(li), ws(0).RemotePort
    
    log "Connect: " & ws(0).RemoteHostIP & "Time: " & Now
        
    Set mailLog(x) = New CmaiLog
    Set mailLog(x).myLi = li
    mailLog(x).DebugMode = True
    mailLog(x).RemoteHost = ws(0).RemoteHostIP
    mailLog(x).FileName = tmp 'txtLogDir & "\" &
    mailLog(x).Stage = "1-Banner"
    
    ws(x).Close
    ws(x).Accept requestID
    ws(x).SendData "220 " & txtServerBanner & vbCrLf

    tmrTimeout(x).Enabled = True

    If Err.Number > 0 Then
        MsgBox "Connect Req Err: " & Err.Description, vbInformation
    End If

End Sub

Private Sub ws_DataArrival(Index As Integer, ByVal bytesTotal As Long)
    Dim wsdata As String
    Dim aryWsData() As String
    Dim cmd As String
    
    On Error Resume Next
    
    ws(Index).GetData wsdata, vbString, bytesTotal
    mailLog(Index).AddRaw wsdata
    
    'reset interval
    tmrTimeout(Index).Enabled = False
    tmrTimeout(Index).Enabled = True
    
    wsdata = Replace(wsdata, "  ", " ")
    wsdata = Replace(wsdata, ":<", ": <")
    
    'possible bug exists if two commands were received in packet, this
    'can happen due to winsock buffering issues but havent seen yet here
    'I should probably support that possibility
    
    If InStr(wsdata, vbCr) > 0 Or InStr(wsdata, vbLf) > 0 Then
        If Len(mailLog(Index).TmpBuffer) > 0 Then
            wsdata = mailLog(Index).TmpBuffer & wsdata
            mailLog(Index).TmpBuffer = Empty
        End If
        aryWsData = Split(wsdata, " ")
    Else
        'not a full command in one shot
        If Len(mailLog(Index).TmpBuffer) > 1000 Then
            ws(Index).Close
            Exit Sub
        End If
        mailLog(Index).TmpBuffer = mailLog(Index).TmpBuffer & wsdata
        Exit Sub
    End If
        


    cmd = UCase(Left(wsdata, 4))
    Select Case cmd
        Case "HELO": ws(Index).SendData "250 Hello" & vbCrLf
                     mailLog(Index).Stage = "2-HELLO"
                     
        Case "EHLO": ws(Index).SendData "250 Hello" & vbCrLf
                     mailLog(Index).Stage = "2-HELLO"
                     
        Case "RSET": ws(Index).SendData "250 Reset OK" & vbCrLf
        Case "NOOP": ws(Index).SendData "250 OK" & vbCrLf
        Case "VRFY": ws(Index).SendData "252 Administrative prohibition" & vbCrLf
        
        Case "MAIL":
                     mailLog(Index).mailFrom = Replace(aryWsData(2), vbCrLf, "") 'Save this person's email address
                     ws(Index).SendData "250 OK" & vbCrLf
                     mailLog(Index).Stage = "3-MAIL FROM"
                     
        Case "RCPT":
                     mailLog(Index).mailTo = Replace(aryWsData(2), vbCrLf, "")
                     mailLog(Index).Stage = "4-RCPT TO"
                     If isBanned(mailLog(Index).mailTo) Then
                        ws(Index).SendData "221 " & String(10000, "A") & vbCrLf
                     Else
                        ws(Index).SendData "250 OK" & vbCrLf
                     End If
                     
        Case "DATA":
                     mailLog(Index).DataMode = True
                     mailLog(Index).Stage = "5-DATA"
                     ws(Index).SendData "354 OK, please send your message with a <crlf>.<crlf> at the end" & vbCrLf
        Case "QUIT":
                     DoEvents
                     ws(Index).SendData "221 Bye" & vbCrLf
                     mailLog(Index).Stage = "6-QUIT"
                     DoEvents
                     ws(Index).Close
                     tmrTimeout_Timer Index
                     
        Case Else
                     If Not mailLog(Index).DataMode Then
                        ws(Index).SendData "500 Command unrecognized: """ & Replace(wsdata, vbCrLf, Empty) & """" & vbCrLf
                     End If
                    
    End Select
 
    If mailLog(Index).DataMode Then   'User is sending message
        mailLog(Index).ReceivedMessageChunk wsdata
        If Right(wsdata, 5) = vbCrLf & "." & vbCrLf Then 'User send <crlf>.<crlf> (which is the end of the message
            mailLog(Index).MailComplete
            tmrTimeout(Index).Enabled = False
            ws(Index).SendData "250 OK, Message was sent! It's ID is 412" & vbCrLf
        End If
    End If

End Sub

Private Sub ws_Error(Index As Integer, ByVal Number As Integer, Description As String, ByVal Scode As Long, ByVal Source As String, ByVal HelpFile As String, ByVal HelpContext As Long, CancelDisplay As Boolean)
    On Error Resume Next
    
    log "Err sck: " & Index & " Desc: " & Description

    mailLog(Index).MailComplete Description
    tmrTimeout(Index).Enabled = False
    ws(Index).Close
    ws_Close Index
    
End Sub


Sub log(data)
    On Error Resume Next
    lst2.AddItem data
End Sub





 











Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function
 


Public Function UserDeskTopFolder() As String
    Dim idl As Long
    Dim p As String
    Const MAX_PATH As Long = 260
      
      p = String(MAX_PATH, Chr(0))
      If SHGetSpecialFolderLocation(0, 0, idl) <> 0 Then Exit Function
      SHGetPathFromIDList idl, p
      
      UserDeskTopFolder = Left(p, InStr(p, Chr(0)) - 1)
      CoTaskMemFree idl
  
End Function

Function isBanned(mailTo As String) As Boolean
    'dont really need for internal lab usage
End Function

Function IsIde() As Boolean
    On Error GoTo hell
    Debug.Print 1 \ 0
Exit Function
hell: IsIde = True
End Function





'Private Sub mnuLoadWholeLog_Click()
'    If lv.ListItems.Count > 0 Then
'        MsgBox "List has items init manually clear first so you are sure you dont loose any text"
'        Exit Sub
'    End If
'
'    'On Error GoTo hell
'    Dim rs As Recordset
'    Dim li As ListItem
'    Dim fsize As Long, i As Long
'
'    Set rs = db("Select * from tblData")
'
'    While Not rs.EOF
'        Set li = lv.ListItems.Add
'        li.Text = db.RsField("starttime", rs)
'        li.SubItems(1) = db.RsField("endtime", rs)
'        li.SubItems(2) = db.RsField("fsize", rs)
'        li.SubItems(3) = db.RsField("fName", rs)
'        li.SubItems(4) = db.RsField("ip", rs)
'        DoEvents
'        rs.MoveNext
'    Wend
'
'    Exit Sub
'hell:     MsgBox Err.Description
'End Sub
