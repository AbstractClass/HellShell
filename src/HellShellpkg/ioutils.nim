import std / [ streams, sequtils ]

proc readFileToBytes*(fileLocation: string, ): seq[uint8] =
    let hFile = newFileStream(fileLocation)
    defer: hFile.close()
    result = result.toSeq()
    while not hFile.atEnd():
        result.add(hFile.readUint8())

