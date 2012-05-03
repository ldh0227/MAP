VERSION 5.00
Begin VB.Form Form2 
   Caption         =   "Virus Total Sample Lookup"
   ClientHeight    =   6345
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9210
   LinkTopic       =   "Form2"
   ScaleHeight     =   6345
   ScaleWidth      =   9210
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer Timer1 
      Left            =   7830
      Top             =   390
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4155
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   5
      Top             =   2100
      Width           =   9165
   End
   Begin VB.TextBox txtFile 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   315
      Left            =   870
      TabIndex        =   4
      Top             =   60
      Width           =   8265
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
      Left            =   0
      TabIndex        =   2
      Top             =   810
      Width           =   9165
   End
   Begin VB.TextBox txtHash 
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   840
      TabIndex        =   1
      Top             =   480
      Width           =   4635
   End
   Begin VB.Label Label3 
      Caption         =   "Raw Json"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   225
      Left            =   8340
      TabIndex        =   6
      Top             =   540
      Width           =   795
   End
   Begin VB.Label Label2 
      Caption         =   "File: "
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   315
      Left            =   60
      TabIndex        =   3
      Top             =   60
      Width           =   735
   End
   Begin VB.Label Label1 
      Caption         =   "MD5"
      BeginProperty Font 
         Name            =   "Courier"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   225
      Left            =   120
      TabIndex        =   0
      Top             =   510
      Width           =   615
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuCopyLine 
         Caption         =   "Copy Line"
      End
      Begin VB.Menu mnuCopyTable 
         Caption         =   "Copy Table"
      End
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim md5 As New MD5Hash
Dim vt As New CVirusTotal
Dim scan As CScan

Public Function StartFromFile(fpath As String)

    On Error Resume Next
        
    txtFile = fpath
    
    If Not FileExists(fpath) Then
        List1.AddItem "File not found"
        Exit Function
    End If
    
    StartFromHash md5.HashFile(fpath)

End Function

Public Function StartFromHash(hash As String)
    
    On Error Resume Next
    
    
    If Len(hash) = 0 Then
        MsgBox "Error starting up from hash, no value specified?", vbInformation
        Exit Function
    End If
    
    
    Me.Show
    txtHash = hash
    Set scan = vt.GetReport(hash, List1, Timer1)
    Text1 = scan.GetReport()
    
End Function

Private Function FileExists(p) As Boolean
    If Len(p) = 0 Then Exit Function
    If Dir(p, vbNormal Or vbHidden Or vbReadOnly Or vbSystem) <> "" Then FileExists = True
End Function

Private Sub Form_Load()
    Me.Show
End Sub

Private Sub Label3_Click()
    On Error Resume Next
    Text1 = scan.RawJson
End Sub
