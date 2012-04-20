VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CResult"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public scanner
Public detected As Boolean
Public version
Public result
Public update

Public Function PaddedScanner(Optional bufSz As Long = 20) As String
    Dim tmp As String
    tmp = scanner
    While Len(tmp) < bufSz
        tmp = tmp & " "
    Wend
    PaddedScanner = tmp
End Function

Public Function setbyname(name As Variant, value As Variant)
    
    name = Trim(Replace(name, """", Empty))
    value = Trim(Replace(value, """", Empty))
    value = Replace(value, "\\", Chr(5))
    value = Replace(value, "\", Empty)
    value = Replace(value, Chr(5), "\\")
    If value = "null" Then
        value = ""
    End If
    
    If value = "false" Then value = False
    If value = "true" Then value = True
    If name = "detected" And Len(value) = 0 Then value = False
    
    Select Case LCase(name)
        Case "scanner": scanner = value
        Case "detected": detected = CBool(value)
        Case "version": version = value
        Case "result": result = value
        Case "update": update = value
    End Select
    
    
End Function


Public Sub ParseResponse(scanner_name, json)

    scanner = scanner_name
    
    '"detected": false, "version": "11.00", "result": null, "update": "20110421"
    
    On Error Resume Next
    Dim a As Long, b As Long
    Dim main As String, name As String, value As String, scans As String
    
    tmp = Split(json, ",")
    For Each entry In tmp
        entry = Trim(entry)
        If Len(entry) = 0 Then GoTo nextone
        b = InStr(1, entry, ":")
        If b < 2 Then GoTo nextone
        name = Mid(entry, 1, b - 1)
        value = Mid(entry, b + 1)
        If name = "result" And detected = True Then Stop
        CallByName Me, "setbyname", VbMethod, name, value
        'If detected = True Then Stop
nextone:
    Next
    
    DoEvents
    
    '"scans": {"CAT-QuickHeal": {"detected": false, "version": "11.00", "result": null, "update": "20110421"},
    

End Sub
