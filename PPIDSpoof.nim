import winim/lean
import std/os, osproc

type
    Process = object
        hProcess: HANDLE
        hThread: HANDLE
        processId: DWORD


proc spawnChild(hProcess: HANDLE, processName: string): Process =
    defer: CloseHandle(hProcess)
    var 
        sie: STARTUPINFOEXA
        pi: PROCESS_INFORMATION
        threadAttrListSize: SIZE_T
    
    let processFQDN = os.getEnv("WINDIR") & "\\system32\\" & processName
    echo "[+] - Process FQDN: ", processFQDN
    
    sie.StartupInfo.cb = DWORD sizeof(STARTUPINFOEXA)
    discard InitializeProcThreadAttributeList(nil, 1, 0, addr threadAttrListSize)
    var 
        threadAttrList = newSeq[byte](threadAttrListSize)
        pThreadAttrList = cast[PPROC_THREAD_ATTRIBUTE_LIST](addr threadAttrList[0])
    
    if InitializeProcThreadAttributeList(pThreadAttrList, 1, 0, addr threadAttrListSize) == 0:
        echo "[!] - InitializeProcThreadAttributeList failed: ", GetLastError()
        return

    echo "[+] - InitializeProcThreadAttributeList success"
    defer: DeleteProcThreadAttributeList(pThreadAttrList)

    if UpdateProcThreadAttribute(pThreadAttrList, 0, PROC_THREAD_ATTRIBUTE_PARENT_PROCESS, addr hProcess, sizeof(HANDLE), nil, nil) == 0:
        echo "[!] - UpdateProcThreadAttribute failed: ", GetLastError()
        return

    echo "[+] - UpdateProcThreadAttribute success"

    sie.lpAttributeList = pThreadAttrList

    if CreateProcessA(nil, processFQDN, nil, nil, false, EXTENDED_STARTUPINFO_PRESENT, nil, nil, addr sie.StartupInfo, addr pi) == 0:
        echo "[!] - CreateProcess failed: ", GetLastError()
        return

    echo "[+] - CreateProcess success"

    result.hProcess = pi.hProcess
    result.hThread = pi.hThread
    result.processId = pi.dwProcessId

if isMainModule:
    let 
        processName = "notepad.exe"
        parentProcess = startProcess(processName)
    Sleep(1000)
    let hProcess = OpenProcess(PROCESS_ALL_ACCESS, false, DWORD parentProcess.processId)
    echo "[+] - OpenProcess success: ", parentProcess.processId
    let childProcess = hProcess.spawnChild("calc.exe")
    
    echo "Parent Process ID: ", parentProcess.processId
    echo "Child Process ID: ", childProcess.processId
    echo "Child Process Handle: ", cast[int](childProcess.hProcess).toHex
    echo "Press any key to exit..."
    discard readLine(stdin)
