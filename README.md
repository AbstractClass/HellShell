## Overview
Port of the logic from https://github.com/NUL0x4C/HellShell into Nim.

I made this as a part of my journey through [Maldev Academy](https://maldevacademy.com/). I like Nim much more than I like C++ so here we are.

This works as a library (`HellShellPkg`) or a standalone CLI tools (`HellShell.nim`).

## CLI Tool
Compiling the CLI tool (nim >= 2.0.0):
```sh
nimble install cligen
nim c HellShell.nim
```

## Package
Totally unfinished, the only part that works to spec is the obfuscation tools and helpers (`obfuscation.nim` and `ioutils.nim` respectively)

I'm pretty sure I didn't even write the .nimble correctly, but the obfuscation works so, yeah.
