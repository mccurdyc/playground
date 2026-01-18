# Debugging

```
gdb ./regs
```

# `gdb`

First, it's amazing.

1. `help <command>` or `help all`
2. `show breakpoints`
3. `run`
4. `layout split`

## `apropos` "search"

From French: à propos = "to the purpose"

It's a Unix command for searching man pages and documentation.

```shell
(gdb) help apropos
(gdb) apropos memory # shows all memory-related commands
```

## `breakpoints`

```shell
(gdb) break some_function
(gdb) break file.c:42
```

## restarting

```shell
(gdb) kill
(gdb) delete # if you want to clear breakpoints
(gdb) run
(gdb) run <cli args>
```

## Current location

```shell
(gdb) backtrace
(gdb) where
(gdb) frame
(gdb) info frame
(gdb) info line
```

## `info`

```shell
(gdb) help info
(gdb) info all-registers (or just registers)
(gdb) info registers $rax
(gdb) info stack
(gdb) info breakpoints
```

## `layout`

```shell
(gdb) layout src
(gdb) layout regs
(gdb) layout next # prev; to switch between split panes
C+X a # to close; or `tui disable` if that doesnt work
```
