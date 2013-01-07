VERSION 5.00
Begin VB.Form frmFileHash 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "File Hash"
   ClientHeight    =   1560
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5970
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1560
   ScaleWidth      =   5970
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdSearch 
      Caption         =   "Search Hash"
      Height          =   345
      Left            =   1590
      TabIndex        =   4
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdVT 
      Caption         =   "VirusTotal"
      Height          =   345
      Left            =   120
      TabIndex        =   3
      Top             =   1200
      Width           =   1155
   End
   Begin VB.CommandButton cmdCopyAll 
      Caption         =   "Copy All"
      Height          =   345
      Left            =   4680
      TabIndex        =   2
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdCopyHash 
      Caption         =   "Copy Hash"
      Height          =   345
      Left            =   3180
      TabIndex        =   1
      Top             =   1200
      Width           =   1125
   End
   Begin VB.TextBox Text1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000004&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Arial"
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
End
Attribute VB_Name = "frmFileHash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim myMd5 As String

Sub ShowFileStats(fpath As String)
    
    On Error Resume Next
    Dim ret() As String
    Dim istype As Boolean
    Dim compiled As String
    Dim fs As Long, sz As Long
    Dim fname As String
    
    fs = DisableRedir()
    myMd5 = hash.HashFile(fpath)
    sz = FileLen(fpath)
    RevertRedir fs
    
    fname = fso.FileNameFromPath(fpath)
    If Len(fname) > 50 Then
        fname = GetShortName(fpath)
        fname = fso.FileNameFromPath(fname)
    End If
    
    push ret(), "File: " & fname
    push ret(), "Size: " & sz
    push ret(), "MD5:  " & myMd5
    
    compiled = GetCompileDateOrType(fpath, istype)
    push ret(), IIf(istype, "FileType: ", "Compiled Date: ") & compiled
    
    Text1 = Join(ret, vbCrLf)
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

Private Sub cmdSearch_Click()
   Google myMd5, Me.hwnd
End Sub

Private Sub cmdVT_Click()
    On Error Resume Next
    Dim vt As String
    vt = App.path & "\virustotal.exe"
    If Not fso.FileExists(vt) Then
        MsgBox "VirusTotal app not found?: " & vt, vbInformation
        Exit Sub
    End If
    Shell vt & " /hash " & myMd5
End Sub

