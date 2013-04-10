VERSION 5.00
Begin VB.Form frmFileHash 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "File Hash"
   ClientHeight    =   1710
   ClientLeft      =   45
   ClientTop       =   615
   ClientWidth     =   5970
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1710
   ScaleWidth      =   5970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame fraLower 
      BorderStyle     =   0  'None
      Height          =   435
      Left            =   60
      TabIndex        =   1
      Top             =   1260
      Width           =   5835
      Begin VB.CommandButton cmdCopyHash 
         Caption         =   "Copy Hash"
         Height          =   345
         Left            =   3060
         TabIndex        =   3
         Top             =   0
         Width           =   1125
      End
      Begin VB.CommandButton cmdCopyAll 
         Caption         =   "Copy All"
         Height          =   345
         Left            =   4560
         TabIndex        =   2
         Top             =   0
         Width           =   1215
      End
      Begin VB.Label lblMore 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "More"
         ForeColor       =   &H80000008&
         Height          =   255
         Left            =   60
         TabIndex        =   4
         Top             =   60
         Width           =   615
      End
   End
   Begin VB.TextBox Text1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1065
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   0
      Top             =   120
      Width           =   5775
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Begin VB.Menu mnuStrings 
         Caption         =   "Strings"
      End
      Begin VB.Menu mnuSearch 
         Caption         =   "Search"
         Begin VB.Menu mnuSearchHash 
            Caption         =   "Hash"
         End
         Begin VB.Menu mnuSearchFileName 
            Caption         =   "File Name"
         End
      End
      Begin VB.Menu mnuVt 
         Caption         =   "Virus Total"
      End
      Begin VB.Menu mnuFileProps 
         Caption         =   "File Properties"
      End
   End
End
Attribute VB_Name = "frmFileHash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim myMd5 As String
Dim LoadedFile As String
Dim isPE As Boolean

Sub ShowFileStats(fpath As String)
    
    On Error Resume Next
    Dim ret() As String
    Dim istype As Boolean
    Dim compiled As String
    Dim fs As Long, sz As Long
    Dim fname As String
    Dim mySHA As String
    
    
    LoadedFile = fpath
    fs = DisableRedir()
    myMd5 = hash.HashFile(fpath)
    'mySHA = hash.HashFile(fpath, SHA, HexFormat)
    sz = FileLen(fpath)
    RevertRedir fs
    
    fname = fso.FileNameFromPath(fpath)
    If Len(fname) > 50 Then
        fname = GetShortName(fpath)
        fname = fso.FileNameFromPath(fname)
    End If
    
    If LCase(fname) <> LCase(myMd5) Then
        push ret(), rpad("File:") & fname
    End If
    
    push ret(), rpad("Size:") & sz
    push ret(), rpad("MD5:") & myMd5
    'push ret(), rpad("SHA:") & mySHA
    
    compiled = GetCompileDateOrType(fpath, istype, isPE)
    push ret(), IIf(istype, rpad("FileType: "), rpad("Compiled:")) & compiled
    
    If isPE Then
        Dim fp As FILEPROPERTIE
        fp = FileProps.FileInfo(fpath)
        If Len(fp.FileVersion) > 0 Then
            push ret(), rpad("Version:") & fp.FileVersion
        End If
    End If
        
    mnuFileProps.Enabled = isPE
    
    Text1 = Join(ret, vbCrLf)
    
    Font = Text1.Font
    Text1.Height = TextHeight(Text1.Text) + 200
    Text1.Width = TextWidth(Text1.Text) + 200
    Me.Height = Text1.Top + Text1.Height + fraLower.Height + 400
    Me.Width = Text1.Width + Text1.Left + 400
    fraLower.Top = Me.Height - fraLower.Height - 400
    
    Dim minWidth  As Long
    minWidth = fraLower.Width + fraLower.Left + 300
    If Me.Width < minWidth Then Me.Width = minWidth
    
    Me.Show 1
        
End Sub

Private Sub cmdCopyAll_Click()
    Clipboard.Clear
    Clipboard.SetText Text1
    Unload Me
    End
End Sub

Private Sub cmdCopyHash_Click()
    Clipboard.Clear
    Clipboard.SetText myMd5
    Unload Me
    End
End Sub

Private Sub cmdVT_Click()
    On Error Resume Next
    Dim vt As String
    vt = App.path & IIf(IsIde(), "\..\", "") & "\virustotal.exe"
    If Not fso.FileExists(vt) Then
        MsgBox "VirusTotal app not found?: " & vt, vbInformation
        Exit Sub
    End If
    Shell vt & " /hash " & myMd5
End Sub

Private Sub Form_Load()
    mnuPopup.Visible = False 'IsIde()
End Sub

Private Sub lblMore_Click()
    PopupMenu mnuPopup
End Sub

Private Sub mnuFileProps_Click()
    On Error Resume Next
    Dim fs As Long, f As String
    fs = DisableRedir()
    tmp = FileProps.QuickInfo(LoadedFile)
    RevertRedir fs
    f = fso.GetFreeFileName(Environ("temp"))
    fso.WriteFile vbCrLf & vbCrLf & f, tmp
    Shell "notepad.exe """ & f & """", vbNormalFocus
End Sub

Private Sub mnuSearchFileName_Click()
    Dim f As String
    f = fso.FileNameFromPath(LoadedFile)
    Google f, Me.hWnd
End Sub

Private Sub mnuSearchHash_Click()
    Google myMd5, Me.hWnd
End Sub

Private Sub mnuStrings_Click()
    On Error Resume Next
    exe = App.path & IIf(IsIde(), "\..\", "") & "\shellext.exe"
    Shell exe & " """ & LoadedFile & """ /peek"
End Sub

Private Sub mnuVt_Click()
    cmdVT_Click
End Sub
