import std/strformat, osproc
import winim/lean

proc injectDLL(hProcess: HANDLE, dllName: string): bool =
    let 
        dllNameFormatted = dllName.winstrConverterStringToLPWSTR
        pLoadLibraryW = GetProcAddress(GetModuleHandle("Kernel32.dll"), "LoadLibraryW")
    if pLoadLibraryW == NULL:
        echo "[!] - Unable to find LoadLibraryW address. Error: ", GetLastError()
        return false
    let 
        sizeToWrite = cast[SIZE_T](dllName.len * 2) # ascii -> widechar
        pRemoteBuf = VirtualAllocEx(hProcess, NULL, sizeToWrite, MEM_COMMIT, PAGE_EXECUTE_READ_WRITE)
    echo "[*] - DLLName as LPWSTR: ", dllName, " of size ", sizeToWrite
    if pRemoteBuf == NULL:
        echo "[!] - Unable to allocate memory in the remote process. Error: ", GetLastError()
        return false

    echo &"[+] Allocated remote buffer of size {sizeToWrite} to {cast[int](pRemoteBuf).toHex}"
    echo "Press enter to continue..."
    discard readLine(stdin)

    var bytesWritten: SIZE_T
    if WriteProcessMemory(hProcess, pRemoteBuf, dllNameFormatted, sizeToWrite, addr bytesWritten) == FALSE or bytesWritten != sizeToWrite:
        echo "[!] - Unable to write process memory. Error: ", GetLastError()
        return false

    echo &"[+] Wrote the phrase {dllName} to the remote process, size ", bytesWritten
    echo "Press enter to continue..."
    discard readLine(stdin)

    let hThread = CreateRemoteThread(
        hProcess, 
        NULL, 
        0, 
        cast[LPTHREAD_START_ROUTINE](pLoadLibraryW), 
        pRemoteBuf, 
        0x04, 
        NULL)
    echo "[+] - Thread created, press enter to start the thread..."
    discard readLine(stdin)
    hThread.ResumeThread()
    echo "[+] - Press enter to close the handle"
    discard readLine(stdin)
    defer: CloseHandle(hThread)
    true

if isMainModule:
    let 
        tProcess = startProcess("notepad.exe")
    tProcess.suspend()
    defer: tProcess.close()
    echo "[*] - Target process: ", tProcess.processID
    let
        hProcess = OpenProcess(PROCESS_ALL_ACCESS, false, cast[DWORD](tProcess.processID))
    defer: hProcess.CloseHandle()
    discard hProcess.injectDLL("c:\\windows\\system32\\dpapi.dll")
    echo "[+] - Done! Press enter to continue..."
    discard readLine(stdin)
