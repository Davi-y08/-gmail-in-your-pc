$SQLite  = "C:\Users\Downloads\sqlite-tools-win-x64-3510100\sqlite3.exe"
$Strings = "C:\Users\Downloads\Strings\strings.exe"

$OutFile   = "gmails.txt"
$OutUnique = "gmails_unicos.txt"

Remove-Item $OutFile, $OutUnique -ErrorAction SilentlyContinue

Write-Host "[+] Fechando Chrome..."
taskkill /F /IM chrome.exe 2>$null

Start-Sleep -Seconds 2

$ChromeDB = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Web Data"
$TempDB   = "$env:TEMP\webdata_copy.db"

if (Test-Path $ChromeDB) {
    Write-Host "[+] Copiando banco do Chrome..."
    Copy-Item $ChromeDB $TempDB -Force

    Write-Host "[+] Extraindo @gmail.com do Autofill..."
    & $SQLite $TempDB `
    "SELECT value FROM autofill WHERE value LIKE '%@gmail.com%';" |
    Out-File -Append $OutFile
}
else {
    Write-Host "[-] Banco do Chrome não encontrado"
}

Write-Host "[+] Tentando extrair do pagefile.sys (resultados limitados)..."

& $Strings -n 8 "$env:SystemDrive\pagefile.sys" 2>$null |
Select-String "@gmail.com" |
ForEach-Object { $_.Line } |
Out-File -Append $OutFile

if (Test-Path $OutFile) {
    Write-Host "[+] Removendo duplicatas..."
    Get-Content $OutFile |
        Sort-Object -Unique |
        Out-File $OutUnique
}

Write-Host ""
Write-Host "✔ Coleta finalizada"
Write-Host "Resultado final: $OutUnique"
