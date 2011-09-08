VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CmaiLog"
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

Public mailTo As String
Public mailFrom As String
Public MessageBody As String
Public DataMode As Boolean
Public FileName As String
Public RawData As String
Public DebugMode As Boolean
Public RemoteHost As String
Public Stage As String
Public TmpBuffer As String
Public myLi As ListItem

Sub AddRaw(s)
    RawData = RawData & CStr(s)
End Sub

Property Get SubjectLine() As String
    Dim tmp() As String
    Dim i As Integer
    
    tmp() = Split(MessageBody, vbCrLf, 40)
    For i = 0 To UBound(tmp)
        If LCase(Left(tmp(i), 7)) = "subject" Then
            SubjectLine = Trim(Mid(tmp(i), 8))
            If Left(SubjectLine, 1) = ":" Then
                SubjectLine = Mid(SubjectLine, 2, Len(SubjectLine))
            End If
            Exit For
        End If
    Next
    
End Property

Property Get AttachmentName() As String
   'filename=
   Dim s As Long
   Dim e As Long
   Dim l As Long
   Dim nextChar As String
   
   Const marker As String = "filename="
   s = InStr(MessageBody, marker)
   
   If s < 1 Then Exit Sub
   
   e = s + Len(marker)
   nextChar = Mid(MessageBody, e, 1)
   If nextChar <> "'" And nextChar <> """" Then
        nextChar = " "
   Else
        e = e + 1
   End If
   
tryAgain:
    l = InStr(e, MessageBody, nextChar)
    If l < 1 And nextChar = " " Then
        nextChar = vbCr
        GoTo tryAgain
    End If
    
    If l < 1 Then
        AttachmentName = "PARSE ERROR"
        Exit Sub
    End If
    
    l = l - e
    
    AttachmentName = Mid(MessageBody, e, l)
   
    If Len(AttachmentName) > 254 Then
        AttachmentName = Mid("TRUNCATED: " & AttachmentName, 1, 150)
    End If
    
End Property

Property Get MailSize() As Long
    MailSize = Len(MessageBody)
End Property

Sub ReceivedMessageChunk(strChunk As String)
    MessageBody = MessageBody & strChunk
End Sub

Sub ResetClass()
    If Not myLi Is Nothing Then SetLVData
    mailTo = Empty
    mailFrom = Empty
    MessageBody = Empty
    DataMode = False
    RawData = Empty
    Stage = 0
    TmpBuffer = Empty
End Sub

Sub MailComplete(Optional errDesc As String = Empty)
    Dim f As Long
    On Error Resume Next
    f = FreeFile
    Open FileName For Binary As f
    
    Put f, , "Received From: " & RemoteHost & vbCrLf
    
    If Len(errDesc) > 0 Then
        Put f, , "Error: " & errDesc & vbCrLf & String(75, "-") & vbCrLf & vbCrLf
    End If
    
    Put f, , "TO:" & mailTo & vbCrLf
    Put f, , "FROM:" & mailFrom & vbCrLf & vbCrLf & String(75, "-") & vbCrLf & vbCrLf
    
    If DebugMode Then
        Put f, , "DEBUGMODE RAW DATA FOLLOWS" & vbCrLf & String(50, "_") & vbCrLf
        Put f, , RawData
    Else
        Put f, , MessageBody
    End If
    
    Close f
    
End Sub


Sub SetLVData()
    On Error Resume Next
    
    If myLi Is Nothing Then Exit Sub
    
    With myLi
        .SubItems(1) = mailTo
        .SubItems(2) = MailSize
        .SubItems(5) = SubjectLine
        .SubItems(6) = AttachmentName
        .SubItems(7) = Stage
    End With
    
    Set myLi = Nothing
    
End Sub

Private Sub Class_Terminate()
    SetLVData
End Sub
 

