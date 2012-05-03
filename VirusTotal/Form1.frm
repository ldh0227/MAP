VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form Form1 
   Caption         =   "Bulk Hash Lookup"
   ClientHeight    =   7770
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   11190
   LinkTopic       =   "Form2"
   ScaleHeight     =   7770
   ScaleWidth      =   11190
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdBrowse 
      Caption         =   "..."
      Height          =   285
      Left            =   8190
      TabIndex        =   8
      Top             =   150
      Width           =   645
   End
   Begin VB.TextBox txtCacheDir 
      Height          =   285
      Left            =   3780
      TabIndex        =   7
      Text            =   "C:\VT_Cache\"
      Top             =   120
      Width           =   4335
   End
   Begin VB.CheckBox chkCache 
      Caption         =   "Cache Reports"
      Height          =   285
      Left            =   2130
      TabIndex        =   6
      Top             =   120
      Width           =   1545
   End
   Begin VB.Timer tmrDelay 
      Enabled         =   0   'False
      Interval        =   4500
      Left            =   8700
      Top             =   540
   End
   Begin VB.CommandButton cmdAbort 
      Caption         =   "Abort"
      Height          =   405
      Left            =   9510
      TabIndex        =   5
      Top             =   60
      Width           =   1455
   End
   Begin MSComctlLib.ProgressBar pb 
      Height          =   285
      Left            =   60
      TabIndex        =   4
      Top             =   1740
      Width           =   10875
      _ExtentX        =   19182
      _ExtentY        =   503
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.CommandButton cmdQuery 
      Caption         =   "Begin Query"
      Height          =   405
      Left            =   60
      TabIndex        =   3
      Top             =   60
      Width           =   1605
   End
   Begin VB.TextBox Text2 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3165
      Left            =   30
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   4530
      Width           =   10965
   End
   Begin MSComctlLib.ListView lv 
      Height          =   2445
      Left            =   30
      TabIndex        =   1
      Top             =   2040
      Width           =   10935
      _ExtentX        =   19288
      _ExtentY        =   4313
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   0   'False
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   4
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "hash"
         Object.Width           =   7056
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "detections"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Date"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Description"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.ListBox List1 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1230
      Left            =   30
      TabIndex        =   0
      Top             =   510
      Width           =   10935
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuCopyTable 
         Caption         =   "Copy Table"
      End
      Begin VB.Menu mnuCopyResult 
         Caption         =   "Copy Result"
      End
      Begin VB.Menu mnuCopyAll 
         Caption         =   "Copy All Results"
      End
      Begin VB.Menu mnuSaveReports 
         Caption         =   "Save Reports to Files"
      End
      Begin VB.Menu mnuDivider 
         Caption         =   "-"
      End
      Begin VB.Menu mnuRemoveSelected 
         Caption         =   "Remove Selected"
      End
      Begin VB.Menu mnuClearList 
         Caption         =   "Remove All"
      End
      Begin VB.Menu mnuDivider2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAddHashs 
         Caption         =   "Load Hashs from Clipboard"
      End
      Begin VB.Menu mnuViewRaw 
         Caption         =   "View raw JSON"
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim vt As New CVirusTotal
Dim selli As ListItem
Dim abort As Boolean
Dim dlg As New clsCmnDlg
Dim fso As New CFileSystem2

Private Sub cmdAbort_Click()
    abort = True
End Sub

Private Sub cmdClear_Click()
    List1.Clear
    lv.ListItems.Clear
    Text2 = Empty
    Set selli = Nothing
End Sub

Private Sub cmdBrowse_Click()
    Dim f As String
    f = dlg.FolderDialog()
    If Len(f) = 0 Then Exit Sub
    txtCacheDir = f
End Sub


Private Sub cmdQuery_Click()
    
    Dim report As String
    Dim detections As Long
    Dim li As ListItem
    Dim scan As CScan
    
    On Error Resume Next
    
    If lv.ListItems.Count = 0 Then
        MsgBox "Load hashs first!"
        Exit Sub
    End If
    
    vt.report_cache_dir = Empty
    
    If chkCache.value = 1 Then
        If Len(txtCacheDir) = 0 Then
            chkCache.value = 0
        Else
            If Not fso.FolderExists(txtCacheDir) Then
                If Not fso.buildPath(txtCacheDir) Then
                    chkCache.value = 0
                End If
            End If
        End If
        If fso.FolderExists(txtCacheDir) Then vt.report_cache_dir = txtCacheDir
    End If
        
    
    abort = False
    
    pb.Max = lv.ListItems.Count
    
    For Each li In lv.ListItems
    
        If abort Then Exit For
        
        If Len(Trim(li.Text)) = 0 Then GoTo nextone
        
        Set scan = vt.GetReport(li.Text, List1, tmrDelay)
        
        If Not scan.HadError Then
            li.SubItems(1) = scan.positives
            li.SubItems(2) = scan.scan_date
            li.SubItems(3) = scan.verbose_msg
            Set li.Tag = scan
        Else
            li.SubItems(1) = "Failure"
        End If
        
        li.EnsureVisible
        DoEvents
        Me.Refresh
        pb.value = pb.value + 1
        
        If pb.value = lv.ListItems.Count Then GoTo nextone
        
nextone:
    Next
    
    pb.value = 0
    MsgBox "Queries Complete" & vbCrLf & vbcrllf & "Click on an item to view report.", vbInformation
 
 
End Sub



Private Sub Command2_Click()
'    Dim m_json As String
'    Dim b As String
'    Dim c As Long
'    Dim d As Dictionary
'
'    If AddComment(txtHash, Text2, m_json, b, c) Then
'        Set d = JSON.parse(m_json)
'        If d Is Nothing Then
'            List1.AddItem "AddComment JSON parsing error"
'            Exit Sub
'        End If
'
'        If JSON.GetParserErrors <> "" Then
'            List1.AddItem "AddComment Json Parse Error: " & JSON.GetParserErrors
'            Exit Sub
'        End If
'
'        If d.Item("response") <> 1 Then
'            MsgBox d.Item("verbose_msg")
'            Exit Sub
'        End If
'
'        MsgBox "Comment was added successfully", vbInformation
'
'    Else
'        MsgBox "Add Comment Failed Status code: " & c & " " & b
'    End If
        
   
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    SaveSetting "vt", "settings", "cachedir", txtCacheDir.Text
    SaveSetting "vt", "settings", "usecache", chkCache.value
End Sub

Private Sub mnuAddHashs_Click()
    On Error Resume Next
    x = Clipboard.GetText
    tmp = Split(x, vbCrLf)
    For Each x In tmp
        If Len(Trim(x)) > 0 Then lv.ListItems.Add , , Trim(x)
    Next
End Sub


Private Sub Form_Load()
    
    On Error Resume Next
    
    Dim path As String
    Dim hash_mode As Boolean
    
    txtCacheDir = GetSetting("vt", "settings", "cachedir", "c:\VT_Cache")
    chkCache.value = GetSetting("vt", "settings", "usecache", 0)
    
    lv.ColumnHeaders(4).Width = lv.Width - lv.ColumnHeaders(4).Left - 150
    
    If InStr(Command, "/bulk") > 0 Then
       Me.Show
       mnuAddHashs_Click
       cmdQuery_Click
    Else
        hash_mode = IIf(InStr(Command, "/hash") > 0, True, False)
        path = Replace(Command, """", Empty)
        If hash_mode Then path = Replace(path, "/hash", Empty)
        path = Trim(path)
        
        If Len(path) = 0 Then GoTo errorStartup
            
        If hash_mode Then
            Form2.StartFromHash path
        Else
            If Not fso.FileExists(path) Then GoTo errorStartup
            Form2.StartFromFile path
        End If
        Unload Me
    End If
    
    Exit Sub
errorStartup:
    List1.AddItem "Designed to be run from right click menus in explorer."
    List1.AddItem "You can add bulk hash lists to lookup by right click on listview"
    Me.Show
End Sub


Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    On Error Resume Next
    Dim scan As CScan
    Set selli = Item
    Set scan = Item.Tag
    If scan Is Nothing Then Exit Sub
    Text2 = scan.GetReport()
End Sub

Private Sub lv_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = 2 Then PopupMenu mnuPopup
End Sub


Private Sub mnuClearList_Click()
    cmdClear_Click
End Sub

Private Sub mnuCopyAll_Click()
    Dim li As ListItem
    Dim r
    Dim scan As CScan
    
    On Error Resume Next
    
    For Each li In lv.ListItems
        r = r & li.Text & "  Detections: " & li.SubItems(1) & "  ScanDate: " & li.SubItems(2) & vbCrLf
    Next
    
    r = r & vbCrLf & vbCrLf
    
    For Each li In lv.ListItems
        Set scan = li.Tag
        r = r & li.Text & vbCrLf & scan.GetReport() & vbCrLf & String(50, "-") & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuCopyResult_Click()

On Error Resume Next

    If selli Is Nothing Then
        MsgBox "Nothing selected"
        Exit Sub
    End If
    
    Dim r As String
    Dim scan As CScan
    Set scan = selli.Tag
    
    r = selli.Text & "  Detections: " & selli.SubItems(1) & "  ScanDate: " & li.SubItems(2) & vbCrLf & String(50, "-") & vbCrLf & scan.GetReport()
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuCopyTable_Click()

On Error Resume Next

    Dim li As ListItem
    Dim r
    
    For Each li In lv.ListItems
        r = r & li.Text & "  Detections: " & li.SubItems(1) & "  ScanDate: " & li.SubItems(2) & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText r
    MsgBox Len(r) & " bytes copied to clipboard"
    
End Sub

Private Sub mnuRemoveSelected_Click()
    On Error Resume Next
    
    For i = lv.ListItems.Count To 1 Step -1
        If lv.ListItems(i).Selected Then lv.ListItems.Remove i
    Next
    
End Sub

Private Sub mnuSaveReports_Click()
    
    On Error Resume Next
    Dim li As ListItem
    Dim pf As String
    Dim scan As CScan
    
    pf = dlg.FolderDialog()
    If Len(pf) = 0 Then Exit Sub
    
    For Each li In lv.ListItems
        hash = li.Text
        Set scan = li.Tag
        fso.writeFile pf & "\VT_" & hash & ".txt", li.Text & "  Detections: " & li.SubItems(1) & "  ScanDate: " & li.SubItems(2) & vbCrLf & String(50, "-") & vbCrLf & scan.GetReport()
    Next

End Sub

Private Sub mnuViewRaw_Click()
    On Error Resume Next
    If selli Is Nothing Then Exit Sub
    Dim scan As CScan
    Set scan = selli.Tag
    Text2 = scan.RawJson
End Sub
