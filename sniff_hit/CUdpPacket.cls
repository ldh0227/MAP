VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CUDPPacket"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public SourceIP As String
Public DestIP As String
Public SrcPort As Long
Public DstPort As Long
Public Data As Variant

Public isMeSending As Boolean
Public notMeIP As String
Public isDNS As Boolean
Public DNSReqName As String

