VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CPEEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'dzzie@yahoo.com
'http://sandsprite.com

Public Sections As Collection
Public errMessage As String
Public ImageBase As Long
Public isLoaded As Boolean

Private DOSHEADER As IMAGEDOSHEADER
Private NTHEADER As IMAGE_NT_HEADERS
Private myFile As String

Private Const IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16
Private Const IMAGE_SIZEOF_SHORT_NAME = 8
Private Const IMAGE_NT_OPTIONAL_HDR32_MAGIC = &H10B

Private Type IMAGEDOSHEADER
    e_magic As Integer
    e_cblp As Integer
    e_cp As Integer
    e_crlc As Integer
    e_cparhdr As Integer
    e_minalloc As Integer
    e_maxalloc As Integer
    e_ss As Integer
    e_sp As Integer
    e_csum As Integer
    e_ip As Integer
    e_cs As Integer
    e_lfarlc As Integer
    e_ovno As Integer
    e_res(1 To 4) As Integer
    e_oemid As Integer
    e_oeminfo As Integer
    e_res2(1 To 10)    As Integer
    e_lfanew As Long
End Type

Private Type IMAGE_SECTION_HEADER
    nameSec As String * 6
    PhysicalAddress As Integer
    VirtualSize As Long
    VirtualAddress As Long
    SizeOfRawData As Long
    PointerToRawData As Long
    PointerToRelocations As Long
    PointerToLinenumbers As Long
    NumberOfRelocations As Integer
    NumberOfLinenumbers As Integer
    Characteristics As Long
End Type

Private Type IMAGE_FILE_HEADER
    Machine As Integer
    NumberOfSections As Integer
    TimeDateStamp As Long
    PointerToSymbolTable As Long
    NumberOfSymbols As Long
    SizeOfOptionalHeader As Integer
    Characteristics As Integer
End Type

Private Type IMAGE_NT_HEADERS
    Signature As String * 4
    FileHeader As IMAGE_FILE_HEADER
    OptionalHeader_0 As String * 28 '224 total, we cheat here...
    ImageBase As Long
    OptionalHeader_1 As String * 192
End Type

Function LoadFile(fpath As String) As Boolean
    On Error GoTo hell
        
        Dim i As Long
        Dim f As Long
        Dim udtSH As IMAGE_SECTION_HEADER
        
        isLoaded = False
        errMessage = Empty
        If Not FileExists(fpath) Then Err.Raise 1
            
        Set Sections = New Collection

        f = FreeFile
        
        Open fpath For Binary Access Read As f
        Get f, , DOSHEADER
        Get f, DOSHEADER.e_lfanew + 1, NTHEADER
        
        If NTHEADER.Signature <> "PE" & Chr(0) & Chr(0) Then Err.Raise 2
        
        Me.ImageBase = NTHEADER.ImageBase
        LoadSections f, NTHEADER
        
        Close f
        LoadFile = True
        myFile = fpath
        isLoaded = True
        
Exit Function
hell:
    
    Close f
    
    Select Case Err.Number
        Case 1: errMessage = "File not found: " & fpath
        Case 2: errMessage = "Invalid PE signature: " & NTHEADER.Signature
        Case Else: errMessage = Err.Description
    End Select
    
End Function

Private Sub LoadSections(fhand As Long, nth As IMAGE_NT_HEADERS)
    
    Dim i As Long
    Dim udtSH As IMAGE_SECTION_HEADER
    Dim CSect As CSection
    
    Set Sections = New Collection
    
    For i = 1 To nth.FileHeader.NumberOfSections
        Get fhand, , udtSH
        Set CSect = New CSection
        With udtSH
            CSect.nameSec = Replace(.nameSec, Chr(0), "")
            CSect.PhysicalAddress = .PhysicalAddress
            CSect.VirtualSize = .VirtualSize
            CSect.VirtualAddress = .VirtualAddress
            CSect.SizeOfRawData = .SizeOfRawData
            CSect.PointerToRawData = .PointerToRawData
            CSect.PointerToRelocations = .PointerToRelocations
            CSect.PointerToLinenumbers = .PointerToLinenumbers
            CSect.NumberOfRelocations = .NumberOfRelocations
            CSect.NumberOfLinenumbers = .NumberOfLinenumbers
            CSect.Characteristics = .Characteristics
        End With
        CSect.index = i
        Sections.Add CSect
    Next
    
End Sub

Function OffsetToVA(ByVal foffset As Long, Optional sectName As String) As Long
    Dim rva As Long
    
    rva = OffsetToRVA(foffset, sectName)
    
    If rva <> 0 Then
        OffsetToVA = rva + NTHEADER.ImageBase
    End If
    
End Function

 
Function RvaToOffset(ByVal rva As Long, Optional ByRef VirtualSectionBase As Long, Optional sectName As String)
        
    If Sections.Count = 0 Then
        MsgBox "No Sections Loaded", vbInformation
        Exit Function
    End If
    
    Dim c As CSection
    Dim vBase As Long, vSize As Long, vMax As Long
    
    For Each c In Sections
       vBase = c.VirtualAddress
       vSize = c.VirtualSize
       vMax = vBase + vSize
       
       If rva >= vBase And rva < vMax Then 'right section
            rva = rva - vBase
            rva = rva + c.PointerToRawData
            RvaToOffset = rva
            VirtualSectionBase = vBase
            sectName = c.nameSec
            Exit Function
       End If
    Next
       
    
End Function

Function OffsetToRVA(ByVal foffset As Long, Optional sectName As String)
    
    If Sections.Count = 0 Then
        'MsgBox "No Sections Loaded", vbInformation
        Exit Function
    End If
    
    Dim c As CSection
    Dim rBase As Long, rSize As Long, rMax As Long
    
    For Each c In Sections
       rBase = c.PointerToRawData
       rSize = c.SizeOfRawData
       rMax = rBase + rSize
       
       If foffset >= rBase And foffset < rMax Then 'right section
            OffsetToRVA = c.VirtualAddress + foffset - rBase
            sectName = c.nameSec
            Exit Function
       End If
    Next

End Function

Function GetSectionFromRVA(rva As Long) As CSection
      
    If Sections.Count = 0 Then
        MsgBox "No Sections Loaded", vbInformation
        Exit Function
    End If
    
    Dim c As CSection
    Dim vBase As Long, vSize As Long, vMax As Long
    
    For Each c In Sections
       vBase = c.VirtualAddress
       vSize = c.VirtualSize
       vMax = vBase + vSize
       
       If rva >= vBase And rva < vMax Then 'right section
            Set GetSectionFromRVA = c
            Exit Function
       End If
    Next
    
End Function

Private Function FileExists(path) As Boolean
  If Len(path) = 0 Then Exit Function
  If Dir(path, vbHidden Or vbNormal Or vbReadOnly Or vbSystem) <> "" Then FileExists = True
End Function




