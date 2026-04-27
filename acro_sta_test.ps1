$pd = New-Object -ComObject AcroExch.PDDoc
Write-Output 'CREATED'
$ok = $pd.Open('C:\Users\aserc\Documents\@@aeu\@@aeu_5th\cdw310\cdw310_C5.pdf')
Write-Output ('OPEN=' + $ok)
if ($ok) {
  Write-Output ('PAGES=' + $pd.GetNumPages())
  $jso = $pd.GetJSObject()
  $n = $jso.getPageNumWords(0)
  Write-Output ('WORDS=' + $n)
  $sample = @()
  for ($i=0; $i -lt [Math]::Min(40,$n); $i++) { $sample += $jso.getPageNthWord(0,$i,$true) }
  Write-Output ($sample -join ' ')
  $pd.Close()
}
