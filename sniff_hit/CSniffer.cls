VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CSniffer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
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

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (pDst As Any, ByVal pSrc As Long, ByVal ByteLen As Long)
Private Declare Function RegisterWindowMessage Lib "user32" Alias "RegisterWindowMessageA" (ByVal lpString As String) As Long
Private Declare Function WSAStartup Lib "ws2_32.dll" (ByVal wVR As Long, lpWSAD As WSAData) As Long
Private Declare Function WSACleanup Lib "ws2_32.dll" () As Long
Private Declare Function socket Lib "ws2_32.dll" (ByVal af As Long, ByVal s_type As Long, ByVal Protocol As Long) As Long
Private Declare Function closesocket Lib "ws2_32.dll" (ByVal s As Long) As Long
Private Declare Function WSAAsyncSelect Lib "wsock32.dll" (ByVal s As Long, ByVal hWnd As Long, ByVal wMsg As Long, ByVal lEvent As Long) As Long
Private Declare Function WSAGetLastError Lib "wsock32.dll" () As Long
Private Declare Function setsockopt Lib "wsock32.dll" (ByVal s As Long, ByVal Level As Long, ByVal optname As Long, optval As Any, ByVal optlen As Long) As Long
Private Declare Function bind Lib "ws2_32.dll" (ByVal s As Long, ByRef name As sockaddr_in, ByRef namelen As Long) As Long
Private Declare Function WSAIoctl Lib "ws2_32.dll" (ByVal s As Long, ByVal dwIoControlCode As Long, lpvInBuffer As Any, ByVal cbInBuffer As Long, lpvOutBuffer As Any, ByVal cbOutBuffer As Long, lpcbBytesReturned As Long, lpOverlapped As Long, lpCompletionRoutine As Long) As Long
Private Declare Function ntohl Lib "ws2_32.dll" (ByVal netlong As Long) As Long
Private Declare Function ntohs Lib "ws2_32.dll" (ByVal netshort As Integer) As Integer
Private Declare Function htons Lib "ws2_32.dll" (ByVal hostshort As Integer) As Integer
Private Declare Function htonl Lib "ws2_32.dll" (ByVal hostlong As Long) As Long
Private Declare Function inet_addr Lib "ws2_32.dll" (ByVal cp As String) As Long
Private Declare Function gethostbyname Lib "ws2_32.dll" (ByVal host_name As String) As Long
Private Declare Function recv Lib "ws2_32.dll" (ByVal s As Long, ByRef buf As Any, ByVal buflen As Long, ByVal Flags As Long) As Long

Private Const WSADESCRIPTION_LEN As Long = 256
Private Const WSASYS_STATUS_LEN  As Long = 128
Private Const INADDR_NONE As Long = &HFFFFFFFF
Private Const INVALID_SOCKET As Long = 0
Private Const SOCKET_ERROR As Long = -1
Private Const SOCK_RAW As Long = 3
Private Const AF_INET As Long = 2
Private Const SOL_SOCKET As Long = &HFFFF&
Private Const SO_RCVTIMEO As Long = &H1006
Private Const SIO_RCVALL As Long = &H98000001
Private Const FD_READ As Long = &H1
Private Const IPPROTO_TCP = 6
Private Const IPPROTO_UDP = 17

Private Type WSAData
    wVersion As Integer
    wHighVersion As Integer
    szDescription As String * WSADESCRIPTION_LEN
    szSystemStatus As String * WSASYS_STATUS_LEN
    iMaxSockets As Integer
    iMaxUdpDg As Integer
    lpVendorInfo As Long
End Type

Private Type sockaddr_in
    sin_family As Integer
    sin_port As Integer
    sin_addr As Long
    sin_zero As String * 8
End Type

Private Type HostEnt
    h_name As Long
    h_aliases As Long
    h_addrtype As Integer
    h_length As Integer
    h_addr_list As Long
End Type

Private Type TCPHeader
    src_portno  As Integer
    dst_portno As Integer
    Sequenceno As Long
    Acknowledgeno As Long
    DataOffset  As Byte
    flag As Byte
    Windows As Integer
    Checksum As Integer
    UrgentPointer As Integer
End Type

Private Type UDPHeader
    src_portno As Integer
    dst_portno As Integer
    udp_length As Integer
    udp_checksum As Integer
End Type

Private Type IPHeader
    ip_verlen As Byte
    ip_tos As Byte
    ip_totallength As Integer
    IP_ID As Integer
    IP_Offset As Integer
    ip_ttl As Byte
    IP_Protocol As Byte
    IP_Checksum As Integer
    ip_srcaddr As Long
    ip_destaddr As Long
End Type

Private Type sockaddr_gen
    AddressIn As sockaddr_in
    filler(0 To 7) As Byte
End Type

Private Type INTERFACE_INFO
    iiFlags  As Long
    iiAddress As sockaddr_gen
    iiBroadcastAddress As sockaddr_gen
    iiNetmask As sockaddr_gen
End Type

Private Type INTERFACEINFO
    iInfo(0 To 7) As INTERFACE_INFO
End Type

Private Type dns_pkt
    transaction_id As Integer
    Flags As Integer 'bit fields
    ques As Integer
    ans_rrs As Integer
    authority_rrs As Integer
    aditional_rrs As Integer
    strSize As Byte
    queries(500) As Byte 'variable should be enough size
    'format strSize = size of string
    'ascii string of len strsize
    'query type as integer
    'query class as integer
End Type

Private Enum WsaError
         WSABASEERR = 10000
         WSAEINTR = (WSABASEERR + 4)
         WSAEBADF = (WSABASEERR + 9)
         WSAEACCES = (WSABASEERR + 13)
         WSAEFAULT = (WSABASEERR + 14)
         WSAEINVAL = (WSABASEERR + 22)
         WSAEMFILE = (WSABASEERR + 24)
         WSAEWOULDBLOCK = (WSABASEERR + 35)
         WSAEINPROGRESS = (WSABASEERR + 36)
         WSAEALREADY = (WSABASEERR + 37)
         WSAENOTSOCK = (WSABASEERR + 38)
         WSAEDESTADDRREQ = (WSABASEERR + 39)
         WSAEMSGSIZE = (WSABASEERR + 40)
         WSAEPROTOTYPE = (WSABASEERR + 41)
         WSAENOPROTOOPT = (WSABASEERR + 42)
         WSAEPROTONOSUPPORT = (WSABASEERR + 43)
         WSAESOCKTNOSUPPORT = (WSABASEERR + 44)
         WSAEOPNOTSUPP = (WSABASEERR + 45)
         WSAEPFNOSUPPORT = (WSABASEERR + 46)
         WSAEAFNOSUPPORT = (WSABASEERR + 47)
         WSAEADDRINUSE = (WSABASEERR + 48)
         WSAEADDRNOTAVAIL = (WSABASEERR + 49)
         WSAENETDOWN = (WSABASEERR + 50)
         WSAENETUNREACH = (WSABASEERR + 51)
         WSAENETRESET = (WSABASEERR + 52)
         WSAECONNABORTED = (WSABASEERR + 53)
         WSAECONNRESET = (WSABASEERR + 54)
         WSAENOBUFS = (WSABASEERR + 55)
         WSAEISCONN = (WSABASEERR + 56)
         WSAENOTCONN = (WSABASEERR + 57)
         WSAESHUTDOWN = (WSABASEERR + 58)
         WSAETOOMANYREFS = (WSABASEERR + 59)
         WSAETIMEDOUT = (WSABASEERR + 60)
         WSAECONNREFUSED = (WSABASEERR + 61)
         WSAELOOP = (WSABASEERR + 62)
         WSAENAMETOOLONG = (WSABASEERR + 63)
         WSAEHOSTDOWN = (WSABASEERR + 64)
         WSAEHOSTUNREACH = (WSABASEERR + 65)
         WSAENOTEMPTY = (WSABASEERR + 66)
         WSAEPROCLIM = (WSABASEERR + 67)
         WSAEUSERS = (WSABASEERR + 68)
         WSAEDQUOT = (WSABASEERR + 69)
         WSAESTALE = (WSABASEERR + 70)
         WSAEREMOTE = (WSABASEERR + 71)
         WSAEDISCON = (WSABASEERR + 101)
         WSASYSNOTREADY = (WSABASEERR + 91)
         WSAVERNOTSUPPORTED = (WSABASEERR + 92)
         WSANOTINITIALISED = (WSABASEERR + 93)
End Enum

Private hSocket As Long
Private WithEvents Subclass As CSubclass2
Attribute Subclass.VB_VarHelpID = -1
Private WskMsg As Long
Private hWnd As Long
Private WsaStrErrors As New Collection

Public ErrorMessage As String
Public EventWindow As Form

Public PromisciousMode As Boolean

Event RecievedPacket(packet As CTcpPacket, Data As String)
Event UDPPacket(packet As CUDPPacket, Data() As Byte)

Private myInterfaces As Collection
Private ListeningIP As Long

Public Function Startup(interfaceAddress As String) As Boolean

    Dim sAdr As sockaddr_in, oBuf As Long, retVal As Long
    Const iBuf As Long = 1
       
    If EventWindow Is Nothing Then
        ErrorMessage = "Class Usage Error: Set EventWindow First!"
        Exit Function
    End If
  
    hWnd = EventWindow.hWnd

    sAdr.sin_family = AF_INET
    sAdr.sin_port = 0
    sAdr.sin_addr = GetHostLng(interfaceAddress)
    ListeningIP = sAdr.sin_addr

    If sAdr.sin_addr = INADDR_NONE Then
        ErrorMessage = "Invalid Interface Address"
        GoTo generalFail
    End If

    hSocket = socket(AF_INET, SOCK_RAW, 0)
    
    If hSocket = INVALID_SOCKET Then
        ErrorMessage = "Could not create socket" & LastError
        GoTo generalFail
    End If

    If setsockopt(hSocket, SOL_SOCKET, SO_RCVTIMEO, 5000, 4) <> 0 Then
        ErrorMessage = "Failed to set timeout " & LastError
        GoTo generalFail
    End If

    If bind(hSocket, sAdr, LenB(sAdr)) <> 0 Then
        ErrorMessage = "Failed to bind socket " & LastError
        GoTo generalFail
    End If

    If WSAIoctl(hSocket, SIO_RCVALL, iBuf, 4, oBuf, 4, retVal, ByVal 0, ByVal 0) <> 0 Then
        ErrorMessage = "WSAIoctl failed " & LastError
        GoTo generalFail
    End If
        
    If WSAAsyncSelect(hSocket, hWnd, WskMsg, FD_READ) <> 0 Then
        ErrorMessage = "WSAAsyncSelect failed " & LastError
        GoTo generalFail
    End If
    
    Subclass.AttachMessage hWnd, WskMsg
    Startup = True
    
Exit Function
generalFail: closesocket hSocket
End Function

Sub Shutdown()
    On Error Resume Next
    'Subclass.DetatchMessage hWnd, WskMsg
    closesocket hSocket
End Sub
 


Private Sub Subclass_MessageReceived(hWnd As Long, wMsg As Long, lSocket As Long, lParam As Long, Cancel As Boolean)
    
   Dim udtIP  As IPHeader, udtTCP As TCPHeader, packet As New CTcpPacket
   Dim offset As Integer, datLen As Long, sData As String, packetsize As Long
   Dim buf() As Byte, dat() As Byte
   Dim lngIp As Long, ip(3) As Byte
   Dim srcIp As String, dstIp As String
   
   ReDim buf(2000) As Byte
    
   packetsize = recv(lSocket, ByVal VarPtr(buf(0)), 1500, 0)
   If packetsize <= LenB(udtIP) Then Exit Sub
    
   ReDim Preserve buf(packetsize - 1) As Byte
    
   CopyMemory udtIP, VarPtr(buf(0)), LenB(udtIP)
                             
   If Not PromisciousMode Then
        If udtIP.ip_destaddr <> ListeningIP And udtIP.ip_srcaddr <> ListeningIP Then
            Exit Sub
        End If
   End If
   
   If udtIP.IP_Protocol = IPPROTO_UDP Then
        HandleUDP udtIP, buf, packetsize
        Exit Sub
   End If
   
   If udtIP.IP_Protocol <> IPPROTO_TCP Then Exit Sub 'ignore others
    
   CopyMemory udtTCP, VarPtr(buf(0)) + 20, LenB(udtTCP)
   
   offset = 20 + (udtTCP.DataOffset \ &H10) * 4
   datLen = packetsize - offset
    
   If datLen > 0 Then
        ReDim dat(1 To datLen)
        CopyMemory ByVal VarPtr(dat(1)), ByVal VarPtr(buf(offset)), datLen
        sData = StrConv(dat, vbUnicode)
   End If
    
   lngIp = udtIP.ip_srcaddr
   CopyMemory ByVal VarPtr(ip(0)), VarPtr(lngIp), 4
   srcIp = ip(0) & "." & ip(1) & "." & ip(2) & "." & ip(3)
      
   lngIp = udtIP.ip_destaddr
   CopyMemory ByVal VarPtr(ip(0)), VarPtr(lngIp), 4
   dstIp = ip(0) & "." & ip(1) & "." & ip(2) & "." & ip(3)
   
   With packet
          .IP_DestIP = dstIp
          .IP_SourceIP = srcIp
          .AckNumber = LongToUnsigned(ntohl(udtTCP.Acknowledgeno))
          .DestPort = ntohs(udtTCP.dst_portno)
          .SequenceNumber = LongToUnsigned(ntohl(udtTCP.Sequenceno))
          .SourcePort = ntohs(udtTCP.src_portno)
          .Flags = udtTCP.flag
   End With
      
   RaiseEvent RecievedPacket(packet, sData)

End Sub

Private Function HandleUDP(udtIP As IPHeader, buf() As Byte, packetsize As Long)
  
  Dim udtUDP As UDPHeader
  Dim offset As Integer
  Dim tmp() As Byte
  Dim ip(4) As Byte
  Dim dns As dns_pkt
  Dim t As String
  Dim udp As New CUDPPacket
  Dim i As Integer
  
  CopyMemory udtUDP, ByVal VarPtr(buf(0)) + 20, LenB(udtUDP)
    
  offset = 20 + LenB(udtUDP)
  packetsize = packetsize - offset
    
  If packetsize > 0 Then
      ReDim tmp(0 To packetsize - 1)
      CopyMemory ByVal VarPtr(tmp(0)), ByVal VarPtr(buf(offset)), packetsize
  End If
  
  With udp
      CopyMemory ByVal VarPtr(ip(0)), VarPtr(udtIP.ip_srcaddr), 4
      .SourceIP = ip(0) & "." & ip(1) & "." & ip(2) & "." & ip(3)
          
      CopyMemory ByVal VarPtr(ip(0)), VarPtr(udtIP.ip_destaddr), 4
      .DestIP = ip(0) & "." & ip(1) & "." & ip(2) & "." & ip(3)
     
      .SrcPort = ntohs(udtUDP.src_portno)
      .DstPort = ntohs(udtUDP.dst_portno)
          
      .isMeSending = Me.isMyIP(.SourceIP)
      .notMeIP = IIf(.isMeSending, .DestIP, .SourceIP)
        
      If .isMeSending And .DstPort = 53 Then
         .isDNS = True
    
         CopyMemory ByVal VarPtr(dns), VarPtr(tmp(0)), packetsize - 1
          
         i = 0
         Do While dns.queries(i) <> 0 'not so proper extractor
            t = t & IIf(dns.queries(i) < &H20, ".", Chr(dns.queries(i)))
            i = i + 1
            If i > 255 Then Exit Do
         Loop
            
         udp.DNSReqName = Replace(t, Chr(3), ".")
         
        End If
 End With
    
    
  RaiseEvent UDPPacket(udp, tmp)

End Function

Private Function LastError() As String
    On Error Resume Next
    LastError = WsaStrErrors("id:" & WSAGetLastError)
End Function

Private Function LongToUnsigned(Value As Long) As Double
    LongToUnsigned = Value + IIf(Value < 0, 4294967296#, 0)
End Function


Private Sub Class_Terminate()
    closesocket hSocket
    WSACleanup
End Sub



Private Sub Class_Initialize()
    
    Dim WSAInfo As WSAData
    
    WSAStartup &H202, WSAInfo
    WskMsg = RegisterWindowMessage("MyWindowMessage")
    
    Set Subclass = New CSubclass2
    
    WsaStrErrors.Add "WSABASEERR", "id:" & WSABASEERR
    WsaStrErrors.Add "WSAEINTR", "id:" & WSAEINTR
    WsaStrErrors.Add "WSAEBADF", "id:" & WSAEBADF
    WsaStrErrors.Add "WSAEACCES", "id:" & WSAEACCES
    WsaStrErrors.Add "WSAEFAULT", "id:" & WSAEFAULT
    WsaStrErrors.Add "WSAEINVAL", "id:" & WSAEINVAL
    WsaStrErrors.Add "WSAEMFILE", "id:" & WSAEMFILE
    WsaStrErrors.Add "WSAEWOULDBLOCK", "id:" & WSAEWOULDBLOCK
    WsaStrErrors.Add "WSAEINPROGRESS", "id:" & WSAEINPROGRESS
    WsaStrErrors.Add "WSAEALREADY", "id:" & WSAEALREADY
    WsaStrErrors.Add "WSAENOTSOCK", "id:" & WSAENOTSOCK
    WsaStrErrors.Add "WSAEDESTADDRREQ", "id:" & WSAEDESTADDRREQ
    WsaStrErrors.Add "WSAEMSGSIZE", "id:" & WSAEMSGSIZE
    WsaStrErrors.Add "WSAEPROTOTYPE", "id:" & WSAEPROTOTYPE
    WsaStrErrors.Add "WSAENOPROTOOPT", "id:" & WSAENOPROTOOPT
    WsaStrErrors.Add "WSAEPROTONOSUPPORT", "id:" & WSAEPROTONOSUPPORT
    WsaStrErrors.Add "WSAESOCKTNOSUPPORT", "id:" & WSAESOCKTNOSUPPORT
    WsaStrErrors.Add "WSAEOPNOTSUPP", "id:" & WSAEOPNOTSUPP
    WsaStrErrors.Add "WSAEPFNOSUPPORT", "id:" & WSAEPFNOSUPPORT
    WsaStrErrors.Add "WSAEAFNOSUPPORT", "id:" & WSAEAFNOSUPPORT
    WsaStrErrors.Add "WSAEADDRINUSE", "id:" & WSAEADDRINUSE
    WsaStrErrors.Add "WSAEADDRNOTAVAIL", "id:" & WSAEADDRNOTAVAIL
    WsaStrErrors.Add "WSAENETDOWN", "id:" & WSAENETDOWN
    WsaStrErrors.Add "WSAENETUNREACH", "id:" & WSAENETUNREACH
    WsaStrErrors.Add "WSAENETRESET", "id:" & WSAENETRESET
    WsaStrErrors.Add "WSAECONNABORTED", "id:" & WSAECONNABORTED
    WsaStrErrors.Add "WSAECONNRESET", "id:" & WSAECONNRESET
    WsaStrErrors.Add "WSAENOBUFS", "id:" & WSAENOBUFS
    WsaStrErrors.Add "WSAEISCONN", "id:" & WSAEISCONN
    WsaStrErrors.Add "WSAENOTCONN", "id:" & WSAENOTCONN
    WsaStrErrors.Add "WSAESHUTDOWN", "id:" & WSAESHUTDOWN
    WsaStrErrors.Add "WSAETOOMANYREFS", "id:" & WSAETOOMANYREFS
    WsaStrErrors.Add "WSAETIMEDOUT", "id:" & WSAETIMEDOUT
    WsaStrErrors.Add "WSAECONNREFUSED", "id:" & WSAECONNREFUSED
    WsaStrErrors.Add "WSAELOOP", "id:" & WSAELOOP
    WsaStrErrors.Add "WSAENAMETOOLONG", "id:" & WSAENAMETOOLONG
    WsaStrErrors.Add "WSAEHOSTDOWN", "id:" & WSAEHOSTDOWN
    WsaStrErrors.Add "WSAEHOSTUNREACH", "id:" & WSAEHOSTUNREACH
    WsaStrErrors.Add "WSAENOTEMPTY", "id:" & WSAENOTEMPTY
    WsaStrErrors.Add "WSAEPROCLIM", "id:" & WSAEPROCLIM
    WsaStrErrors.Add "WSAEUSERS", "id:" & WSAEUSERS
    WsaStrErrors.Add "WSAEDQUOT", "id:" & WSAEDQUOT
    WsaStrErrors.Add "WSAESTALE", "id:" & WSAESTALE
    WsaStrErrors.Add "WSAEREMOTE", "id:" & WSAEREMOTE
    WsaStrErrors.Add "WSAEDISCON", "id:" & WSAEDISCON
    WsaStrErrors.Add "WSASYSNOTREADY", "id:" & WSASYSNOTREADY
    WsaStrErrors.Add "WSAVERNOTSUPPORTED", "id:" & WSAVERNOTSUPPORTED
    WsaStrErrors.Add "WSANOTINITIALISED", "id:" & WSANOTINITIALISED
    
End Sub

Private Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function

Function isMyIP(ip As String) As Boolean
    If myInterfaces Is Nothing Then AvailableInterfaces
    isMyIP = KeyExistsInCollection(myInterfaces, ip)
End Function

Function AvailableInterfaces() As Collection

  If Not myInterfaces Is Nothing Then
        Set AvailableInterfaces = myInterfaces
  Else
  
    Dim hSocket As Long, size As Long, count As Integer
    Dim i As Integer, lngIp As Long, ip(3) As Byte
    Const SIO_GET_INTERFACE_LIST As Long = &H4004747F
    Dim buf As INTERFACEINFO
    Dim sIp As String
    Dim ret As New Collection
    
    On Error GoTo failed
    Set AvailableInterfaces = ret
      
    hSocket = socket(AF_INET, 1, 0)
    If hSocket = INVALID_SOCKET Then Exit Function
    If WSAIoctl(hSocket, SIO_GET_INTERFACE_LIST, ByVal 0, 0, buf, 1024, size, ByVal 0, ByVal 0) Then GoTo failed
    
    count = CInt(size / 76) - 1
     
    For i = 0 To count
        lngIp = buf.iInfo(i).iiAddress.AddressIn.sin_addr
        CopyMemory ByVal VarPtr(ip(0)), VarPtr(lngIp), 4
        sIp = ip(0) & "." & ip(1) & "." & ip(2) & "." & ip(3)
        ret.Add sIp, sIp
    Next i
      
    Set myInterfaces = ret
    
failed:
    closesocket hSocket
    
  End If
    
End Function

'sHost = ip or hostname
Private Function GetHostLng(ByVal sHost As String) As Long
  On Error Resume Next
  Dim lpHostent As Long, AddrList As Long, lngIp As Long, udtHostent As HostEnt
   
  lngIp = inet_addr(sHost)
   
  If lngIp = INADDR_NONE Then
        lpHostent = gethostbyname(sHost)
        If lpHostent <> 0 Then
            CopyMemory udtHostent, ByVal lpHostent, LenB(udtHostent)
            CopyMemory AddrList, ByVal udtHostent.h_addr_list, 4
            CopyMemory lngIp, ByVal AddrList, udtHostent.h_length
        Else
           lngIp = INADDR_NONE
        End If
  End If
    
  GetHostLng = lngIp

End Function
 
