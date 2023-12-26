import HellShellpkg / [ ioutils, obfuscation ]
import std/strutils

type
  Operations = enum
    UUID = "uuid", 
    IPv4 = "ipv4", 
    IPv6 = "ipv6", 
    MAC = "mac"


when isMainModule:
  proc argParser(obfuscation: Operations, filename: string, outfile:string = "stdout") =
    var 
      shellcode: seq[uint8] = filename.readFileToBytes()
      obfuscated: seq[string]
    case obfuscation:
      of UUID:
        obfuscated = shellcode.toUUIDs
      of IPv4:
        obfuscated = shellcode.toIPv4
      of IPv6:
        obfuscated = shellcode.toIPv6
      of MAC:
        obfuscated = shellcode.toMAC
    
    if outfile == "stdout":
      stdout.write(obfuscated.join("\n"))
    else:
      outfile.writeFile(obfuscated.join("\n"))
    
  import cligen; dispatch argParser, help={
    "obfuscation": "one of: uuid, ipv4, ipv6, mac", 
    "filename": "a file to read from", 
    "outfile": "file to write results to"},
    short={"obfuscation": 't'}