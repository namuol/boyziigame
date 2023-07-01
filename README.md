# BoyZ II Game

Another Game Boy emulator written in Zig, for fun.

At least that's the plan.

## Why the name?

- Zig, Game Boy
- Boy (Zig) Game
- Boy(Z II G)ame

It's a play on "[Boyz II Men](https://en.wikipedia.org/wiki/Boyz_II_Men)", the
name of an R&B group I know mainly for their hits from the 90s, which were on
the radio around the same time I would spend countless hours on my Game Boy.

## Dependencies

- Tested with zig 0.11.x
- [raylib](https://github.com/raysan5/raylib) is expected to be installed as a
  system dependency.
- A boot ROM is required to be downloaded manually to `src/dmg_boot.bin`
    - Tests expect to use the standard DMG boot ROM
    - For other purposes you can use something open source like the ones
      [SameBoy](https://sameboy.github.io) uses. You can download SameBoy and
      find pre-built boot ROMs in its application folder.

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
