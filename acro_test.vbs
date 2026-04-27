Dim pdDoc, jso, path, count, i, s
path = "C:\Users\aserc\Documents\@@aeu\@@aeu_5th\cdw310\cdw310_C5.pdf"
Set pdDoc = CreateObject("AcroExch.PDDoc")
WScript.Echo "START"
If pdDoc.Open(path) Then
  WScript.Echo "OPENED"
  WScript.Echo "PAGES=" & pdDoc.GetNumPages()
  Set jso = pdDoc.GetJSObject
  count = jso.getPageNumWords(0)
  WScript.Echo "WORDS=" & count
  s = ""
  For i = 0 To count - 1
    s = s & jso.getPageNthWord(0, i, True) & " "
    If i >= 50 Then Exit For
  Next
  WScript.Echo s
  pdDoc.Close
Else
  WScript.Echo "OPEN_FAIL"
End If
Set jso = Nothing
Set pdDoc = Nothing
