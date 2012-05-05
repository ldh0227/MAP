Attribute VB_Name = "Module1"
Option Explicit
'
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

Global fso As New clsFileSystem
Global hash As New CWinHash
Global dlg As New clsCmnDlg
Global minStrLen As Long
Global Const LANG_US = &H409

Public Const IMAGE_NT_OPTIONAL_HDR32_MAGIC = &H10B

Public Type IMAGEDOSHEADER
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

Public Type IMAGE_FILE_HEADER
    Machine As Integer
    NumberOfSections As Integer
    TimeDateStamp As Long
    PointerToSymbolTable As Long
    NumberOfSymbols As Long
    SizeOfOptionalHeader As Integer
    Characteristics As Integer
End Type

Public Type IMAGE_NT_HEADERS
    Signature As String * 4
    FileHeader As IMAGE_FILE_HEADER
    'OptionalHeader As IMAGE_OPTIONAL_HEADER
End Type

Sub push(ary, value) 'this modifies parent ary object
    On Error GoTo init
    Dim x As Long
    x = UBound(ary) '<-throws Error If Not initalized
    ReDim Preserve ary(UBound(ary) + 1)
    ary(UBound(ary)) = value
    Exit Sub
init:     ReDim ary(0): ary(0) = value
End Sub

Sub SaveMySetting(key, value)
    SaveSetting "iDefense", "ShellExt", key, value
End Sub

Function GetMySetting(key, def)
    GetMySetting = GetSetting("iDefense", "ShellExt", key, def)
End Function

Sub SaveFormSizeAnPosition(f As Form)
    Dim s As String
    If f.WindowState <> 0 Then Exit Sub 'vbnormal
    s = f.Left & "," & f.Top & "," & f.Width & "," & f.Height
    SaveMySetting f.Name & "_pos", s
End Sub

Sub RestoreFormSizeAnPosition(f As Form)
    On Error GoTo hell
    Dim s
    
    s = GetMySetting(f.Name & "_pos", "")
    
    If Len(s) = 0 Then Exit Sub
    If occuranceCount(s, ",") <> 3 Then Exit Sub
    
    s = Split(s, ",")
    f.Left = s(0)
    f.Top = s(1)
    f.Width = s(2)
    f.Height = s(3)
    
    Exit Sub
hell:
End Sub

Function occuranceCount(haystack, match) As Long
    On Error Resume Next
    Dim tmp
    tmp = Split(haystack, match, , vbTextCompare)
    occuranceCount = UBound(tmp)
    If Err.Number <> 0 Then occuranceCount = 0
End Function

Function AryIsEmpty(ary) As Boolean
  On Error GoTo oops
    Dim i As Long
    i = UBound(ary)  '<- throws error if not initalized
    AryIsEmpty = False
  Exit Function
oops: AryIsEmpty = True
End Function

Private Function CompiledDate(stamp As Double) As String

    On Error Resume Next
    Dim Base As Date
    Dim compiled As Date
    
    Base = DateSerial(1970, 1, 1)
    compiled = DateAdd("s", stamp, Base)
    'CompiledDate = Format(compiled, "ddd mmm d h:nn:ss yyyy")
    CompiledDate = Format(compiled, "mmm d h:nn:ss yyyy (ddd)")

End Function

Function GetCompileDateOrType(fpath As String, Optional ByRef out_isType As Boolean) As String
    On Error GoTo hell
        
        Dim i As Long
        Dim f As Long
        Dim buf(20) As Byte
        Dim sbuf As String
        
        Dim DOSHEADER As IMAGEDOSHEADER
        Dim NTHEADER As IMAGE_NT_HEADERS
        
        out_isType = False
        
        If Not fso.FileExists(fpath) Then Exit Function
            
        f = FreeFile
        
        Open fpath For Binary Access Read As f
        Get f, , DOSHEADER
        
        If DOSHEADER.e_magic <> &H5A4D Then
            Get f, 1, buf()
            Close f
            sbuf = StrConv(buf(), vbUnicode, LANG_US)
            GetCompileDateOrType = DetectFileType(sbuf)
            out_isType = True
            Exit Function
        End If
        
        Get f, DOSHEADER.e_lfanew + 1, NTHEADER
        
        If NTHEADER.Signature <> "PE" & Chr(0) & Chr(0) Then
            Get f, 1, buf()
            Close f
            sbuf = StrConv(buf(), vbUnicode, LANG_US)
            GetCompileDateOrType = DetectFileType(sbuf)
            out_isType = True
            Exit Function
        End If
        
        
        Close f
        GetCompileDateOrType = CompiledDate(CDbl(NTHEADER.FileHeader.TimeDateStamp))
        
Exit Function
hell:
    
    Close f
    out_isType = True
    GetCompileDateOrType = Err.Description
   
End Function

Private Function DetectFileType(buf As String) As String
    If VBA.Left(buf, 2) = "PK" Then
        DetectFileType = "Zip file"
    ElseIf InStr(1, buf, "%PDF", vbTextCompare) > 0 Then
        DetectFileType = "Pdf File"
    ElseIf VBA.Left(buf, 4) = Chr(&HD0) & Chr(&HCF) & Chr(&H11) & Chr(&HE0) Then
        DetectFileType = "Office Document"
    ElseIf VBA.Left(buf, 4) = "L" & Chr(0) & Chr(0) & Chr(0) Then
        DetectFileType = "Link File"
    ElseIf VBA.Left(buf, 3) = "CWS" Then
        DetectFileType = "SWF File"
    ElseIf VBA.Left(buf, 3) = "CWF" Then
        DetectFileType = "SWF File"
    Else
        DetectFileType = "Unknown FileType"
    End If
End Function
