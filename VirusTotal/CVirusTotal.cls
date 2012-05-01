VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CVirusTotal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Dim http As XMLHTTP

Const URL_API_BASIS = "https://www.virustotal.com/vtapi/v2/"
Const URL_SCAN_FILE = "file/scan"
Const URL_FILE_REPORT = "file/report"
Const URL_SCAN_URL = "url/scan"
Const URL_URL_REPORT = "url/report"
Const URL_MAKE_COMMENT = "comments/put"
Const API_KEY = "a949ea9c64e7145a065b0e562673a66216a132712e958168c8c00ee5f451485b"

Private List1 As ListBox 'for logging...
Private WithEvents Timer1 As Timer
Attribute Timer1.VB_VarHelpID = -1
Private NeedsDelay As Boolean
Private LastQueryTime As Long

Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function GetTickCount Lib "kernel32" () As Long

Public report_cache_dir As String 'if this is set it will cache the results here in case looked up again.

'this class supports a couple nice things..
'1) if you set the cache dir, it will save raw json there as optimization in case you lookup the same file
'    file again. this will sve you the 4sec delay per request.
'2) this class tracks when the last request was made, and implements its own optimized delay so that the
'   4 second threshold is not exceeded.
'3) since vb doesnt support json, a CScan object is always passed back with details of the scan. parsing
'    was just done in VB and is VT json specific and maybe a bit shady as it was done quickly..

Function GetReport(hash As String, list As ListBox, tmr As Timer) As CScan

    On Error Resume Next
    
    Dim scan As New CScan
   
    Dim my_json As String
    Dim sStatus As String
    Dim status As Long
    Dim curtime As Long
    Dim success As Boolean
    Dim errorMsg As String
    
    Set List1 = list
    Set Timer1 = tmr
    Timer1.Enabled = False
    Timer1.Interval = 4500

    Set http = New XMLHTTP
    
    If http Is Nothing Then
        errorMsg = "Could not create XMLHTTP Object"
        GoTo errorExit
    End If

    curtime = GetTickCount
    If LastQueryTime = 0 Then
        LastQueryTime = curtime
        NeedsDelay = False
    Else
        If NeedsDelay = True Then
            Interval = curtime - LastQueryTime
            If Interval < 4200 Then
                Interval = 4200 - Interval
                List1.AddItem "Must delay for " & Interval & " milliseconds"
                Timer1.Interval = Interval
                Timer1.Enabled = True
                While Timer1.Enabled
                    DoEvents
                    Sleep 20
                Wend
                NeedsDelay = False
                LastQueryTime = curtime
            End If
        Else
            NeedsDelay = False
            LastQueryTime = curtime
        End If
    End If
        
    If FolderExists(report_cache_dir) Then
        If FileExists(report_cache_dir & "\" & hash & ".txt") Then
            List1.AddItem "Cached report found for" & hash
            my_json = ReadFile(report_cache_dir & "\" & hash & ".txt")
            GoTo parse_json
        End If
    End If
            
    List1.Clear
    List1.AddItem "Connecting to VirusTotal to query report for " & hash
    
    DoEvents
    
    NeedsDelay = True 'need 4 second delay for next
    
    LastQueryTime = GetTickCount
    success = Get_Web_Report(hash, my_json, sStatus, status)
    scan.HTTP_ResponseCode = status
    scan.HTTP_StatusMessage = sStatus
    
    If Not success Then
        errorMsg = "Web request failure - status code: " & status & " " & sStatus
        GoTo errorExit
    End If
   
    List1.AddItem "Query successful for hash: " & hash
         
    If FolderExists(report_cache_dir) Then
        writeFile report_cache_dir & "\" & hash & ".txt", my_json
    End If
    
parse_json:
    scan.ParseResponse my_json
    Set GetReport = scan
    
    List1.AddItem "Detections: " & scan.positives & " Response Code: " & scan.response_code
    If scan.HadError Then List1.AddItem "Had JSON Parsing error..."
    
Exit Function

errorExit:

    List1.AddItem errorMsg
    scan.Errors.Add errorMsg
    scan.HadError = True
    Set GetReport = scan
    
End Function



Private Function Get_Web_Report(hash, out_response As String, out_status As String, out_statusCode As Long) As Boolean
    
    Err.Clear
    On Error GoTo hell
    
    Dim x As Variant
    out_status = Empty
    out_response = Empty
    
1    http.Open "POST", URL_API_BASIS & URL_FILE_REPORT, False
2    http.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
3    http.send "key=" & API_KEY & "&resource=" & hash
    
     DoEvents
     
5    out_status = http.statusText
6    out_statusCode = http.status
7    out_response = http.responseText
     If out_status = "OK" Then Get_Web_Report = True
    
hell:
    DoEvents
    If Err.Number <> 0 Then
        List1.AddItem "Error in Get_Web_Report Line: " & Erl & " desc: " & Err.Description
    End If
    
End Function

Function AddComment(hash, comment, out_response As String, out_status As String, out_statusCode As Long) As Boolean
    
    Err.Clear
    On Error GoTo hell
    
    Dim x As Variant
    out_status = Empty
    out_response = Empty
    
1    http.Open "POST", URL_API_BASIS & URL_MAKE_COMMENT, False
2    http.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
3    http.send "key=" & API_KEY & "&resource=" & hash & "&comment=" & comment
    
     DoEvents
     
5    out_status = http.statusText
6    out_statusCode = http.status
7    out_response = http.responseText
     If out_status = "OK" Then AddComment = True
    
hell:
    DoEvents
    If Err.Number <> 0 Then
        List1.AddItem "Error in AddComment Line: " & Erl & " desc: " & Err.Description
    End If
    
End Function

Function FolderExists(path) As Boolean
  If Len(path) = 0 Then Exit Function
  If Dir(path, vbDirectory) <> "" Then FolderExists = True _
  Else FolderExists = False
End Function

Function FileExists(p) As Boolean
    If Len(p) = 0 Then Exit Function
    If Dir(p, vbNormal Or vbHidden Or vbReadOnly Or vbSystem) <> "" Then FileExists = True
End Function

Function ReadFile(filename) As String 'this one should be binary safe...
  On Error GoTo hell
  f = FreeFile
  Dim b() As Byte
  Open filename For Binary As #f
  ReDim b(LOF(f) - 1)
  Get f, , b()
  Close #f
  ReadFile = StrConv(b(), vbUnicode, LANG_US)
  Exit Function
hell:   ReadFile = ""
End Function

Function writeFile(path, it) As Boolean 'this one should be binary safe...
    On Error GoTo hell
    Dim b() As Byte
    If FileExists(path) Then Kill path
    f = FreeFile
    b() = StrConv(it, vbFromUnicode, LANG_US)
    Open path For Binary As #f
    Put f, , b()
    Close f
    writeFile = True
    Exit Function
hell: writeFile = False
End Function


Private Sub Class_Initialize()
    NeedsDelay = False
End Sub

Private Sub Timer1_Timer()
    Timer1.Enabled = False
End Sub
