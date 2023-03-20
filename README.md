# Boyz II Game

Another Game Boy emulator written in Zig, for fun.

At least that's the plan.

## Building

Because [Zig](https://ziglang.org) is still working on a package manager, this
project makes heavy use of git submodules (I am sorry).

When you clone this repo, be sure to pass the `--recursive` flag (it can take
quite a while to clone the raylib dependency, so be patient):

```sh
git clone --recursive git@github.com:namuol/boyziigame.git
```

Then to try to build and run it, run this command:

```sh
zig build run
```

The basic project was bootstrapped with
[raylib-zig](https://github.com/Not-Nik/raylib-zig)'s
[`project_setup.sh`](https://github.com/Not-Nik/raylib-zig/blob/1e06706bff87c39738b339eec90e8d20db2ba122/project_setup.sh)
and only tested on Zig 0.10.1 on an M1 Mac.

## Acknowledgements

- `src/sm83-opcodes.json` originally sourced from https://gbdev.io/gb-opcodes