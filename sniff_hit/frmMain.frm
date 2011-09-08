VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form frmMain 
   Caption         =   "sniff_hit"
   ClientHeight    =   8370
   ClientLeft      =   165
   ClientTop       =   555
   ClientWidth     =   9495
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   8370
   ScaleWidth      =   9495
   StartUpPosition =   2  'CenterScreen
   Begin VB.ListBox lstDNS 
      Height          =   2205
      Left            =   7740
      TabIndex        =   21
      ToolTipText     =   "Double Click to Copy"
      Top             =   6060
      Width           =   1755
   End
   Begin VB.ListBox lstIRC 
      Height          =   840
      Left            =   7680
      TabIndex        =   17
      ToolTipText     =   "Double click to copy irc servers"
      Top             =   4800
      Width           =   1815
   End
   Begin VB.ListBox lstHTTP 
      Height          =   840
      Left            =   7680
      TabIndex        =   16
      ToolTipText     =   "Double click to copy http servers"
      Top             =   3600
      Width           =   1815
   End
   Begin VB.TextBox txtIRCPort 
      Height          =   315
      Left            =   2220
      TabIndex        =   15
      Text            =   "0"
      Top             =   4440
      Width           =   915
   End
   Begin VB.TextBox txtHttpPort 
      Height          =   285
      Left            =   1800
      TabIndex        =   14
      Text            =   "0"
      Top             =   720
      Width           =   915
   End
   Begin VB.CommandButton cmdClearHttp 
      Caption         =   "Clear"
      Height          =   255
      Left            =   6660
      TabIndex        =   11
      Top             =   720
      Width           =   795
   End
   Begin VB.CommandButton cmdCopyAllHTTP 
      Caption         =   "Copy"
      Height          =   255
      Left            =   5640
      TabIndex        =   10
      Top             =   720
      Width           =   1035
   End
   Begin VB.TextBox txtIRC 
      Height          =   3555
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   9
      ToolTipText     =   "Double click to copy"
      Top             =   4800
      Width           =   7515
   End
   Begin VB.ListBox lstIP 
      Height          =   2205
      Left            =   7680
      TabIndex        =   7
      ToolTipText     =   "Dounle click to copy"
      Top             =   1080
      Width           =   1755
   End
   Begin MSComctlLib.ListView lv 
      Height          =   3375
      Left            =   60
      TabIndex        =   5
      Top             =   1020
      Width           =   7515
      _ExtentX        =   13256
      _ExtentY        =   5953
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   2
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Host"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Data"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.Frame fInterface 
      Caption         =   "Network Interfaces"
      Height          =   675
      Left            =   180
      TabIndex        =   0
      Top             =   0
      Width           =   9390
      Begin VB.ComboBox cmbInterface 
         Height          =   315
         Left            =   120
         TabIndex        =   3
         Text            =   "Interface List"
         Top             =   240
         Width           =   6600
      End
      Begin VB.CommandButton cmdStop 
         Caption         =   "Stop"
         Enabled         =   0   'False
         Height          =   315
         Left            =   8160
         TabIndex        =   2
         Top             =   240
         Width           =   1095
      End
      Begin VB.CommandButton cmdStart 
         Caption         =   "Start"
         Height          =   315
         Left            =   6960
         TabIndex        =   1
         Top             =   240
         Width           =   1035
      End
   End
   Begin VB.Label Label1 
      Caption         =   "DNS Requests"
      Height          =   195
      Index           =   5
      Left            =   7740
      TabIndex        =   20
      Top             =   5820
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "IRC Servers"
      Height          =   195
      Index           =   4
      Left            =   7680
      TabIndex        =   19
      Top             =   4560
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "Http Servers"
      Height          =   195
      Index           =   3
      Left            =   7680
      TabIndex        =   18
      Top             =   3360
      Width           =   1335
   End
   Begin VB.Label Label3 
      Caption         =   "Ports: 6660-6690, "
      Height          =   255
      Left            =   840
      TabIndex        =   13
      Top             =   4500
      Width           =   1455
   End
   Begin VB.Label Label2 
      Caption         =   "Ports: 80"
      Height          =   255
      Left            =   1020
      TabIndex        =   12
      Top             =   720
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "IRC"
      Height          =   195
      Index           =   2
      Left            =   120
      TabIndex        =   8
      Top             =   4500
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "Unique IPs"
      Height          =   195
      Index           =   1
      Left            =   7680
      TabIndex        =   6
      Top             =   840
      Width           =   1335
   End
   Begin VB.Label Label1 
      Caption         =   "HTTP"
      Height          =   195
      Index           =   0
      Left            =   60
      TabIndex        =   4
      Top             =   780
      Width           =   615
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuCopyList 
         Caption         =   "Copy All"
      End
      Begin VB.Menu mnuSpacer2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuWhois 
         Caption         =   "Whois"
      End
      Begin VB.Menu mnuSpacer1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuClearList 
         Caption         =   "Clear List"
      End
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
'Author: david@idefense.com
'
'Purpose: this is a lightweight specialized packet sniffer that
'         was designed to snarf out just http and IRC traffic that malcode
'         may send out while its active. Note that packets are not reassembled,
'         they are logged on a perpacket basis. Also some compressed or binary
'         packets may currently be displayed in HTTP pane.
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
'Changelog:
'
'     9.24.05 - added DNS request sniffing
'               added right click menus to copy/clear ip lists
'

Private WithEvents sniffer As CSniffer
Attribute sniffer.VB_VarHelpID = -1

Dim uniqueIPs As New Collection
Dim httpServers As New Collection
Dim ircServers As New Collection
Dim myIPs As New Collection

Dim liHttp As ListItem
Dim ActiveList As ListBox

Dim userHttpPort As Long
Dim userIRCPort As Long

Private Sub cmdClearHttp_Click()
    If MsgBox("Are you sure you want to clear http log?", vbInformation + vbYesNo) = vbYes Then
        lv.ListItems.Clear
    End If
End Sub

Private Sub cmdClearIPs_Click()
    lstIP.Clear
End Sub

Private Sub cmdCopyAllHTTP_Click()
    On Error Resume Next
    Dim li As ListItem, MSG As String
    For Each li In lv.ListItems
        MSG = MSG & li.Text & vbCrLf & li.SubItems(1) & vbCrLf & String(75, "-") & vbCrLf
    Next
    Clipboard.Clear
    Clipboard.SetText MSG
    MsgBox "Done", vbInformation
End Sub

Private Sub cmdCopyIPs_Click()
    On Error Resume Next
    Dim i, MSG
    For i = 1 To lstIP.ListCount - 1
        MSG = MSG & lstIP.List(i) & vbCrLf
    Next
    Clipboard.Clear
    Clipboard.SetText MSG
    MsgBox "Done", vbInformation
End Sub

Private Sub cmdStart_Click()
    
    If Not IsNumeric(txtHttpPort) Then
        MsgBox "User defined HttpPort trigger not numeric!"
        Exit Sub
    End If
    
    If Not IsNumeric(txtIRCPort) Then
        MsgBox "User defined IRC Port trigger not numeric!"
        Exit Sub
    End If
    
    userHttpPort = CLng(txtHttpPort)
    userIRCPort = CLng(txtIRCPort)
    
    If sniffer.Startup(cmbInterface.Text) Then
    
        cmdStart.Enabled = Not cmdStart.Enabled
        cmdStop.Enabled = Not cmdStop.Enabled
        txtHttpPort.Enabled = Not txtHttpPort.Enabled
        txtIRCPort.Enabled = Not txtIRCPort.Enabled
        
        Set uniqueIPs = New Collection
        Set httpServers = New Collection
        Set ircServers = New Collection

        lstIP.Clear
        lstIRC.Clear
        lstHTTP.Clear
        txtIRC = Empty
        lv.ListItems.Clear
    Else
        MsgBox "Error starting sniffer: " & sniffer.ErrorMessage
    End If
    
End Sub

Private Sub cmdStop_Click()
    cmdStart.Enabled = Not cmdStart.Enabled
    cmdStop.Enabled = Not cmdStop.Enabled
    txtHttpPort.Enabled = Not txtHttpPort.Enabled
    txtIRCPort.Enabled = Not txtIRCPort.Enabled
    sniffer.Shutdown
End Sub

Private Sub Form_Load()

    If App.PrevInstance Then
        MsgBox "Another instance is already running", vbExclamation
        End
    End If
    
    Dim str() As String, i As Integer, defaultInterface As Long
    Dim interfaces As Collection, X
    
    lv.ColumnHeaders(2).Width = lv.Width - lv.ColumnHeaders(2).Left - 100
       
    Set sniffer = New CSniffer
    Set sniffer.EventWindow = Me
    Set interfaces = sniffer.AvailableInterfaces
    
    For Each X In interfaces
        cmbInterface.AddItem X
        myIPs.Add X, X
    Next
    
    On Error Resume Next
    defaultInterface = CLng(GetSetting("x", "x", "defaultInterface", 0))
    
    If defaultInterface < 0 Or defaultInterface > (cmbInterface.ListCount - 1) Then
        defaultInterface = 0
    End If
    
    cmbInterface.Text = cmbInterface.List(defaultInterface)

    If Trim(Command) = "/start" Then cmdStart_Click
    
End Sub


Private Sub Form_Unload(Cancel As Integer)
    sniffer.Shutdown
    SaveSetting "x", "x", "defaultInterface", cmbInterface.ListIndex
End Sub

Private Sub lstDNS_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 2 Then
        Set ActiveList = lstDNS
        PopupMenu mnuPopup
    End If
End Sub

Private Sub lstIP_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 2 Then
        Set ActiveList = lstIP
        PopupMenu mnuPopup
    End If
End Sub

Private Sub lstHTTP_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 2 Then
        Set ActiveList = lstHTTP
        PopupMenu mnuPopup
    End If
End Sub

Private Sub lstirc_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 2 Then
        Set ActiveList = lstIRC
        PopupMenu mnuPopup
    End If
End Sub




Private Sub lv_DblClick()
    If liHttp Is Nothing Then Exit Sub
    frmData.Dump liHttp.SubItems(1)
End Sub

Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Set liHttp = Item
End Sub

Private Sub mnuClearList_Click()
    If ActiveList Is Nothing Then
        MsgBox "Click on the target list first to activate it", vbInformation
        Exit Sub
    End If
    ActiveList.Clear
End Sub

Private Sub mnuCopyList_Click()
    
    If ActiveList Is Nothing Then
        MsgBox "Click on the target list first to activate it", vbInformation
        Exit Sub
    End If
    
    Dim i As Long
    Dim t As String
    
    On Error Resume Next
    For i = 0 To ActiveList.ListCount - 1
        t = t & ActiveList.List(i) & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText t
    
End Sub

Private Sub mnuWhois_Click()
    On Error GoTo hell
    If ActiveList Is Nothing Then Exit Sub
    
    Dim ip As String
    ip = ActiveList.List(ActiveList.ListIndex)
    
    If Len(ip) = 0 Then
        MsgBox "Make sure to select a IP first then right click", vbInformation
        Exit Sub
    End If
    
    ip = "cmd /k whois " & ip 'xp, 2k specific, we do not support win98 or me here
    
    Shell ip, vbNormalFocus
    
    Exit Sub
hell:
      MsgBox "Do you have whois.exe in your path? " & vbCrLf & _
             "Note the cmd line we use is cmd.exe specific" & vbCrLf & _
              vbCrLf & _
             "Error: " & Err.Description
             
End Sub

Private Sub sniffer_UDPPacket(packet As CUDPPacket, Data() As Byte)
    On Error Resume Next
    With packet
        If Not KeyExistsInCollection(uniqueIPs, .notMeIP) Then
            uniqueIPs.Add .notMeIP, .notMeIP
            lstIP.AddItem .notMeIP
        End If
        If .isDNS Then lstDNS.AddItem .DNSReqName
    End With
End Sub

Private Sub Sniffer_RecievedPacket(packet As CTcpPacket, Data As String)
  
    On Error Resume Next
    Dim isMeSending As Boolean
    Dim ishttp As Boolean
    Dim notMeIP As String
    Dim isIRC As Boolean
    Dim li As ListItem
    
    With packet
        isMeSending = KeyExistsInCollection(myIPs, .IP_SourceIP)
        notMeIP = IIf(isMeSending, .IP_DestIP, .IP_SourceIP)
        
        If Not KeyExistsInCollection(uniqueIPs, notMeIP) Then
            uniqueIPs.Add notMeIP, notMeIP
            lstIP.AddItem notMeIP
        End If

        If Len(Data) = 0 Then Exit Sub

        If isMeSending Then
        
            If .DestPort = 80 Or .DestPort = userHttpPort Then
                ishttp = True
                If Not KeyExistsInCollection(httpServers, .IP_DestIP) Then
                      httpServers.Add .IP_DestIP, CStr(.IP_DestIP)
                      lstHTTP.AddItem .IP_DestIP & " : " & .DestPort
                End If
            End If
                
            If (.DestPort >= 6660 And .DestPort <= 7000) Or .DestPort = userIRCPort Then
                isIRC = True
                If Not KeyExistsInCollection(ircServers, .IP_DestIP) Then
                      ircServers.Add .IP_DestIP, CStr(.IP_DestIP)
                      lstIRC.AddItem .IP_DestIP & " : " & .DestPort
                End If
            End If
        
            If Not isIRC And Not ishttp Then
                If InStr(Data, "NICK ") > 0 Then
                    isIRC = True
                    If Not KeyExistsInCollection(ircServers, .IP_DestIP) Then
                          ircServers.Add .IP_DestIP, CStr(.IP_DestIP)
                          lstIRC.AddItem .IP_DestIP & " : " & .DestPort
                    End If
                End If
            End If
            
            Dim L5 As String
            If Not isIRC And Not ishttp Then
                L5 = UCase(VBA.Left(Data, 5))
                If InStr(L5, "GET /") > 0 Or InStr(L5, "POST ") > 0 Then
                    ishttp = True
                    If Not KeyExistsInCollection(httpServers, .IP_DestIP) Then
                          httpServers.Add .IP_DestIP, CStr(.IP_DestIP)
                          lstHTTP.AddItem .IP_DestIP & " : " & .DestPort
                    End If
                End If
            End If
            
        End If
        
        If Not ishttp And KeyExistsInCollection(httpServers, notMeIP) Then ishttp = True
        If Not isIRC And KeyExistsInCollection(ircServers, notMeIP) Then isIRC = True

            
        If isIRC Then
            txtIRC = txtIRC & Data
            txtIRC.SelStart = Len(txtIRC)
        End If
        
        If ishttp Then
            If InStr(Data, Chr(0)) < 1 Then 'assume not binary
                Set li = lv.ListItems.Add(, , IIf(isMeSending, "-> ", "<- ") & notMeIP & ":" & IIf(isMeSending, .DestPort, .SourcePort))
                li.SubItems(1) = Data
            End If
        End If
                 
    
    End With
    
End Sub



Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function

 
 
 

Private Sub txtIRC_DblClick()
    Clipboard.Clear
    Clipboard.SetText txtIRC
End Sub
