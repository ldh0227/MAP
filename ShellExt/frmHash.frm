VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmHash 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Directory File Hasher - Right Click on ListView for Menu Options"
   ClientHeight    =   4080
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   12060
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4080
   ScaleWidth      =   12060
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ProgressBar pb 
      Height          =   225
      Left            =   30
      TabIndex        =   1
      Top             =   0
      Width           =   11955
      _ExtentX        =   21087
      _ExtentY        =   397
      _Version        =   393216
      Appearance      =   1
   End
   Begin MSComctlLib.ListView lv 
      Height          =   3735
      Left            =   0
      TabIndex        =   0
      Top             =   240
      Width           =   11955
      _ExtentX        =   21087
      _ExtentY        =   6588
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   0   'False
      HideSelection   =   0   'False
      OLEDropMode     =   1
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      OLEDropMode     =   1
      NumItems        =   4
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "File"
         Object.Width           =   3528
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Byte Size"
         Object.Width           =   2647
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "md5"
         Object.Width           =   5292
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "CompileDate (GMT)"
         Object.Width           =   4410
      EndProperty
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuCopyTable 
         Caption         =   "Copy Table"
      End
      Begin VB.Menu mnuCopyTableCSV 
         Caption         =   "Copy Table (CSV)"
      End
      Begin VB.Menu mnuCopyHashs 
         Caption         =   "Copy Hashs"
      End
      Begin VB.Menu mnuDiv 
         Caption         =   "-"
      End
      Begin VB.Menu mnuDisplayUnique 
         Caption         =   "Display unique"
      End
      Begin VB.Menu mnuRenameToMD5 
         Caption         =   "Rename All to MD5"
      End
      Begin VB.Menu mnuMakeExtSafe 
         Caption         =   "Make All Extensions Safe"
      End
      Begin VB.Menu mnuCustomExtension 
         Caption         =   "Set All Custom Extension "
      End
      Begin VB.Menu mnuSpacer33 
         Caption         =   "-"
      End
      Begin VB.Menu mnuVTAll 
         Caption         =   "Virus Total Lookup On All"
      End
      Begin VB.Menu mnuVTLookupSelected 
         Caption         =   "Virus Total Lookup On Selected"
      End
      Begin VB.Menu mnudivider 
         Caption         =   "-"
      End
      Begin VB.Menu mnuDeleteSelected 
         Caption         =   "Deleted Selected Files"
      End
      Begin VB.Menu mnuDeleteDuplicates 
         Caption         =   "Delete All Duplicates"
      End
   End
End
Attribute VB_Name = "frmHash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
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

'7-6-05 Added Delete All Duplicates option
'4-19-12 moved buttons to right click menu options, integrated VirusTotal.exe options
'5.17.12 added progress bar, fixed integer overflow in vbDevKit.CWinHash

Dim path As String
Sub setpb(cur, max)
    On Error Resume Next
    pb.value = (cur / max) * 100
    Me.Refresh
    DoEvents
End Sub

Sub HashDir(dPath As String)
   
    On Error GoTo out
    Dim f() As String, i As Long
    Dim pf As String
    
    'MsgBox "entering hash dir"
    
    path = dPath
    pf = fso.GetParentFolder(path) & "\"
    pf = Replace(path, pf, Empty)
    
    Me.Caption = Me.Caption & "    Folder: " & pf
        
    If Not fso.FolderExists(dPath) Then
        MsgBox "Folder not found: " & dPath
        GoTo done
    End If
             
    f() = fso.GetFolderFiles(dPath)
    
    If AryIsEmpty(f) Then
        MsgBox "No files in this directory", vbInformation
        GoTo done
    End If
     
    'MsgBox "Going to scan " & UBound(f) & " files"
    pb.value = 0
    Me.Visible = True
    
    For i = 0 To UBound(f)
         handleFile f(i)
         setpb i, UBound(f)
    Next
    pb.value = 0
    'MsgBox "ready to show"
     
    On Error Resume Next
    Me.Show 1
   
    Exit Sub
out:
    MsgBox "HashFiles Error: " & Err.Description, vbExclamation
done:
    'Unload Me
    End
End Sub



Function KeyExistsInCollection(c As Collection, val As String) As Boolean
    On Error GoTo nope
    Dim t
    t = c(val)
    KeyExistsInCollection = True
 Exit Function
nope: KeyExistsInCollection = False
End Function

Private Sub lv_MouseDown(Button As Integer, Shift As Integer, x As Single, y As Single)
    If Button = vbRightButton Then PopupMenu mnuPopup
End Sub

Private Sub mnuCopyHashs_Click()
    Dim li As ListItem
    Dim t As String
    
    For Each li In lv.ListItems
        t = t & li.SubItems(2) & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText t
    MsgBox "Copy Complete", vbInformation
End Sub

Private Sub mnuCopyTableCSV_Click()
    mnuCopyTable_Click
    t = Clipboard.GetText
    Clipboard.SetText Replace(t, vbTab, ",")
End Sub

Private Sub mnuCustomExtension_Click()
    On Error Resume Next
    Dim li As ListItem
    Dim pdir As String
    Dim i As Long
    Dim ext As String
    
    ext = InputBox("Enter custom extension. Can not be blank")
    If Len(ext) = 0 Then Exit Sub
    If VBA.Left(ext, 1) <> "." Then ext = "." & ext
    
    For Each li In lv.ListItems
        i = 1
        fpath = li.Tag
        fname = li.Text
        pdir = fso.GetParentFolder(fpath) & "\"
        
        If InStr(fname, ".") > 0 Then
            fname = Mid(fname, 1, InStr(fname, "."))
        End If
        
        h = fname & ext
        
        If LCase(VBA.Right(fname, 4)) = ".txt" Then GoTo nextone  'txt files are fine..
        If LCase(VBA.Right(fname, Len(ext))) = LCase(ext) Then GoTo nextone   'already set
        
        While fso.FileExists(pdir & h) 'dont delete dups, but append counter onto end..
            h = fname & "_" & i
            i = i + 1
        Wend
        
        Name fpath As pdir & h
    
        li.Text = h
        li.Tag = pdir & h
        li.EnsureVisible
        lv.Refresh
        DoEvents
        
nextone:
    Next

End Sub

Private Sub mnuDeleteDuplicates_Click()
    
    Dim li As ListItem
    Dim hashs As New Collection
    Dim h As String
    Dim f As String
    
    Const msg As String = "Are you sure you want to DELETE all DUPLICATE files?"
    If MsgBox(msg, vbYesNo) = vbNo Then Exit Sub
    
    For Each li In lv.ListItems
        h = li.SubItems(2)
        If InStr(h, "Error") < 1 Then
            If KeyExistsInCollection(hashs, h) Then
                li.Tag = "DeleteMe"
            Else
                li.Tag = ""
                hashs.Add h, h
            End If
        End If
    Next
        
nextone:
    For Each li In lv.ListItems
        If li.Tag = "DeleteMe" Then
            f = path & "\" & li.Text
            If fso.FileExists(f) Then
                Kill f
            End If
            lv.ListItems.Remove li.Index
            GoTo nextone
        End If
    Next
    
End Sub

Private Sub mnuDisplayUnique_Click()

     Dim li As ListItem
     Dim hashs As New Collection 'to perform unique value lookup and corrolate to ary index
     Dim h() As String 'count per hash    '\_matched arrays
     Dim b() As String 'actual hash value '/
     Dim hash As String
     Dim v As Long
     Dim i As Long
     
     On Error GoTo hell
     
     ReDim h(0) 'we cant use 0 anyway cause collections index start at 1
     ReDim b(0)
     
     For Each li In lv.ListItems
        hash = li.SubItems(2)
        If KeyExistsInCollection(hashs, hash) Then
            i = hashs(hash)
            h(i) = h(i) + 1
        Else
            push h, 1
            push b, hash
            i = UBound(h)
            hashs.Add i, hash
        End If
     Next
     
     Dim tmp() As String
         
     For i = 1 To UBound(h)
        push tmp, h(i) & "   -   " & b(i)
     Next
     
     Dim t As String
     t = Environ("TMP")
     If Len(t) = 0 Then t = Environ("TEMP")
     If Len(t) = 0 Or Not fso.FolderExists(t) Then
            MsgBox Join(tmp, vbCrLf)
            Exit Sub
     End If
     
     t = fso.GetFreeFileName(t)
     fso.WriteFile t, Join(tmp, vbCrLf)
     
     Shell "notepad """ & t & """", vbNormalFocus
     fso.DeleteFile t
     
Exit Sub
hell: MsgBox Err.Description
End Sub

Private Sub mnuDeleteSelected_Click()
    Dim li As ListItem
    Dim f As String
    On Error Resume Next
    
    Const msg As String = "Are you sure you want to delete these files?"
    If MsgBox(msg, vbYesNo + vbInformation) = vbNo Then Exit Sub
    
    
nextone:
    For Each li In lv.ListItems
        If li.Selected Then
            f = path & "\" & li.Text
            If fso.FileExists(f) Then
                Kill f
            End If
            lv.ListItems.Remove li.Index
            GoTo nextone
        End If
    Next
    
End Sub


Private Sub mnuCopyTable_Click()

    Dim li As ListItem
    Dim t As String
    
    For Each li In lv.ListItems
        t = t & li.Text & vbTab & li.SubItems(1) & vbTab & li.SubItems(2) & vbTab & li.SubItems(3) & vbCrLf
    Next
    
    Clipboard.Clear
    Clipboard.SetText t
    'MsgBox "Copy Complete", vbInformation
    
End Sub

Sub handleFile(f As String)
    Dim h  As String
    Dim li As ListItem
    Dim e
    
    On Error Resume Next
    
    h = LCase(hash.HashFile(f))
    
    If Len(h) = 0 Then
        e = Split(hash.error_message, "-")
        e = Replace(e(UBound(e)), vbCrLf, Empty)
        h = "Error: " & e 'library error...can happen if filesize > maxlong i think?
    End If
    
    Set li = lv.ListItems.Add(, , fso.FileNameFromPath(f))
    li.SubItems(1) = FileLen(f)
    li.SubItems(2) = h
    li.SubItems(3) = GetCompileDateOrType(f)
    li.Tag = f
    
End Sub

Private Sub Form_Load()
    lv.ColumnHeaders(1).Width = lv.Width - lv.ColumnHeaders(2).Width - 400 - lv.ColumnHeaders(3).Width - lv.ColumnHeaders(4).Width
End Sub

Private Sub Form_Resize()
    On Error Resume Next
    lv.Width = Me.Width - lv.Left - 140
    lv.Height = Me.Height - lv.Top - 450
    pb.Width = lv.Width
End Sub

Private Sub mnuMakeExtSafe_Click()
     On Error Resume Next
    Dim li As ListItem
    Dim pdir As String
    Dim i As Long
    
    For Each li In lv.ListItems
        i = 1
        fpath = li.Tag
        fname = li.Text
        pdir = fso.GetParentFolder(fpath) & "\"
        h = fname & "_"
        
        If LCase(VBA.Right(fname, 4)) = ".txt" Then GoTo nextone  'txt files are fine..
        If InStr(fname, ".") < 1 Then GoTo nextone                'no extension
        If VBA.Right(fname, 1) = "_" Then GoTo nextone            'already safe
        
        While fso.FileExists(pdir & h) 'dont delete dups, but append counter onto end..
            h = fname & "_" & i
            i = i + 1
        Wend
        
        Name fpath As pdir & h
    
        li.Text = h
        li.Tag = pdir & h
        li.EnsureVisible
        lv.Refresh
        DoEvents
        
nextone:
    Next
   
End Sub

Private Sub mnuRenameToMD5_Click()
    
    On Error Resume Next
    Dim li As ListItem
    Dim pdir As String
    Dim i As Long
    Dim rlog As String
    
    If MsgBox("Are you sure you want to rename all of these files to their MD5 hash values?", vbYesNo) = vbNo Then
        Exit Sub
    End If
    
    For Each li In lv.ListItems
        i = 2
        fpath = li.Tag
        fname = li.Text
        h = li.SubItems(2)
        pdir = fso.GetParentFolder(fpath) & "\"
        
        If InStr(h, "Error") >= 1 Then GoTo nextone
        If LCase(fname) = LCase(h) Then GoTo nextone
        While fso.FileExists(pdir & h) 'dont delete dups, but append counter onto end..
            h = li.SubItems(2) & "_" & i
            i = i + 1
        Wend
        
        rlog = rlog & fname & vbTab & "->" & vbTab & h & vbCrLf
        Name fpath As pdir & h
    
        li.Text = h
        li.Tag = pdir & h
        li.EnsureVisible
        lv.Refresh
        DoEvents
        
nextone:
    Next
        
    fso.WriteFile pdir & "\rename_log.txt", rlog
    
End Sub

Private Sub mnuVTAll_Click()

    On Error Resume Next
    Dim li As ListItem
    Dim t As String
    
    For Each li In lv.ListItems
        If InStr(h, "Error") < 1 Then
             t = t & li.SubItems(2) & vbCrLf
        End If
    Next
    
    If Len(t) = 0 Then Exit Sub
    
    Clipboard.Clear
    Clipboard.SetText t
    Shell App.path & "\virustotal.exe /bulk", vbNormalFocus
    
End Sub

Private Sub mnuVTLookupSelected_Click()
    On Error Resume Next
    Dim hashs() As String
    Dim li As ListItem
    Dim h As String
    Dim i As Long
    
    For Each li In lv.ListItems
        If li.Selected Then
            h = li.SubItems(2)
            If Len(h) > 0 And InStr(h, "Error") < 1 Then
                push hashs, li.SubItems(2)
                i = i + 1
            End If
        End If
    Next

    If i = 0 Then
        MsgBox "No items were selected!", vbInformation
        Exit Sub
    End If
    
    If i = 1 Then
        Shell App.path & "\virustotal.exe """ & lv.SelectedItem.Tag & """", vbNormalFocus
    Else
        Clipboard.Clear
        Clipboard.SetText Join(hashs, vbCrLf)
        Shell App.path & "\virustotal.exe /bulk", vbNormalFocus
    End If
    
End Sub
