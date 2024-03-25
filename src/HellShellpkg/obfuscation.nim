import std/[sequtils,strformat,strutils, sugar]


proc toEvenHex(bytes: seq[uint8], sizeNeeded: int8): seq[string] =
    let 
        hex = bytes.toSeq.mapIt(it.toHex.toLower)
        offset = hex.len.mod(sizeNeeded)
        remainder = case offset:
            of 0: 0
            else: sizeNeeded - offset
        padding = @["90"].cycle(remainder)
    #echo "Offset: ", offset, " Remainder: ", remainder
    writeLine(stderr, &"[*] Shellcode is {hex.len} bytes, adding {remainder} NOPs to make payload")
    
    return concat(padding, hex) # add NOP sled to make the sequence evenly devisible
    

proc toUUIDs*(bytes: seq[uint8]): seq[string] =
    let hex = bytes.toEvenHex(16)
    result = collect:
        for i in countup(0, hex.len-16, 16):
            let uuidGroups = hex[i ..< i+16].distribute(4)
            &"{uuidGroups[0].join}-{uuidGroups[1].join}-{uuidGroups[2].join}{uuidGroups[3].join}"

proc fromUUID*(uuid: string): seq[uint8] =
    let bytes = uuid
        .filterIt(it != '-')
        .distribute(16)
        .mapIt(fromHex[uint8](join(it)))
    result = collect(newSeq):
        for b in bytes: b

proc toMAC*(bytes: seq[uint8]): seq[string] =
    let hex = bytes.toEvenHex(8)
    for i in countup(0, hex.len-8, 8):
        let mac = hex[i ..< i+8].join("-")
        result.add(mac)

proc fromMAC*(mac: string): seq[uint8] =
    result = mac.split(".").mapIt(cast[uint8](it.parseUInt))

proc toIPv6*(bytes: seq[uint8]): seq[string] =
    let hex = bytes.toEvenHex(16)
    result = collect:
        for i in countup(0, hex.len-16, 16):
            let uuidGroups = hex[i ..< i+16].distribute(4)
            join(uuidGroups.mapIt(join(it)),":")
            #let uuid = &"{uuidGroups[0].join(":")}:{uuidGroups[1].join(":")}:{uuidGroups[2].join(":")}{uuidGroups[3].join(":")}"

proc fromIPv6*(ipv6: string): seq[uint8] =
    let bytes = ipv6
        .filterIt(it != ':')
        .distribute(16)
        .mapIt(fromHex[uint8](join(it)))
    result = collect:
        for b in bytes: b

proc toIPv4*(bytes: seq[uint8]): seq[string] =
    let 
        remainder = 4 - bytes.len.mod(4)
        buffer = @[144'u8].cycle(remainder) # 144d = 90h (NOP)
        alignedBytes = concat(buffer, bytes)
    for i in countup(0, alignedBytes.len-4, 4):
        result.add(alignedBytes[i ..< i+4].join("."))

proc fromIPv4*(ipv4: string): seq[uint8] =
    result = ipv4.split(".").mapIt(cast[uint8](it.parseUInt))
