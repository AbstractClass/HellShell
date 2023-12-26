{.push raises: [].}
import std/random
import winim


type 
    USTRING = object
        Length, MaximumLength: DWORD
        Buffer: PVOID

proc makeRandomBytes(i: int): seq[uint8] =
    for k in 0 .. i:
        result.add(rand(255).uint8)

proc rc4EncryptNTAPI(data, key: PTR): NTSTATUS
    {.discardable, stdcall, dynlib: "Advapi32", importc: "SystemFunction032"}

proc rc4Encrypt*(key, payload: seq[uint8], winapi: bool): string {.raises: [OSError].} =
    if winapi:
        var
            winPayload = payload # need a deep copy because of in-place memory modification
            key = USTRING(
                Length: cast[int32](key.len),
                MaximumLength: cast[int32](key.len),
                Buffer: key.addr # can't use `ptr` because it is a generic
            )
            data = USTRING(
                Length: cast[int32](winPayload.len),
                MaximumLength: cast[int32](winPayload.len),
                Buffer: winPayload.addr
            )
            status = rc4EncryptNTAPI(data.addr, key.addr)
        if not status.NT_SUCCESS:
            echo &"[-] Encryption failed with code: {status}"
            raise newException(OSError, "Encryption failed using NTAPI")
        
        result = $data
