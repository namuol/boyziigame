# Boyz II Game

Another Game Boy emulator written in Zig, for fun.

At least that's the plan.

## Dependencies

- Tested with zig 0.11.x
- [raylib](https://github.com/raysan5/raylib) is expected to be installed as a system dependency.

### OSX

```sh
brew install --HEAD zig # verify that this installs zig 0.11.x
brew install raylib # only tested with 4.5.0
```

### Windows

TODO

### Linux

TODO

## Building

```sh
zig build
```

## Acknowledgements

- `src/sm83-opcodes.json` originally sourced from https://gbdev.io/gb-opcodes
- `dmg_boot.bin` sourced from [SameBoy](https://github.com/LIJI32/SameBoy) ([MIT License](https://github.com/LIJI32/SameBoy/blob/master/LICENSE))
