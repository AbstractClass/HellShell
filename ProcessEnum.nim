import winim/lean

proc GetRemoteProcess(pid: int): HANDLE =
    var 
        returnLengthA: ULONG = 0
        returnLengthB: ULONG = 0
    # Get size of data using a dummy call
    NtQuerySystemInformation(systemProcessInformation, NULL, 0, addr returnLengthA)
    #var system_process_info = cast[PSYSTEM_PROCESS_INFORMATION](HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, SIZE_T returnLengthA))
    var system_process_info = newSeq[byte](returnLengthA)
    echo "returnLength ", returnLengthA
    
    # The actual call
    var STATUS: NTSTATUS = NtQuerySystemInformation(
        systemProcessInformation, 
        addr system_process_info[0], 
        returnLengthA, 
        addr returnLengthB)
    #echo "check mem @ ", system_process_info.repr
    #discard readLine(stdin)
    if STATUS != 0:
        echo "[!] - Unable to query system info. Error: ", GetLastError()
        return 0
    
    echo "check mem @", cast[int](addr system_process_info[0]).toHex
    discard readLine(stdin)
    var 
        offset = 0
        sysproc: PSYSTEM_PROCESS_INFORMATION
    while true:
        sysproc = cast[PSYSTEM_PROCESS_INFORMATION](addr system_process_info[offset])
        if sysproc.NextEntryOffset == 0:
            echo "EOL"
            break
        
        offset += sysproc.NextEntryOffset
        #echo "@", cast[int](sysproc).toHex
        echo sysproc.UniqueProcessId, " - ", sysproc.ImageName.Buffer
        
    # var offset = cast[int](system_process_info)
    # while true:
    #     echo "Offset ", offset.toHex
    #     echo "Proc"
    #     echo "\t | name ", system_process_info.ImageName.Buffer
    #     echo "\t | pid ", system_process_info.UniqueProcessId
    #     echo "\t | offset ", system_process_info.NextEntryOffset
    
    #     if system_process_info.NextEntryOffset == 0:
    #         echo "[-] End of list, offset is ", system_process_info.NextEntryOffset
    #         break

    #     offset += system_process_info.NextEntryOffset
    #     # Do pointer math to get the next struct
    #     offset += system_process_info.NextEntryOffset
    #     echo "new offset ", offset.toHex
    #     system_process_info = cast[PSYSTEM_PROCESS_INFORMATION](offset)
    #     discard readLine(stdin)
    

if isMainModule:
    discard GetRemoteProcess(1)