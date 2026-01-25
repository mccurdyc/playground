# Understanding setting up a stack

Chapter 4 (p56) talks about function parameters. `rbp` is an address that can be used to relatively
refer to function parameters that is "out of the way" of the stack pointer.

For parameters, we "reserve space" --- relative to `rbp` --- on the stack. Then, within
the function we can use locations relative to `rbp` for accessing the paramters as well
as local variables.

```txt
--- bottom ---

     --- _start ---
param 2        -- 12(%rbp)
param 1        --  8(%rbp)
return address --  4(%rbp)
     --- some_fn ---
backup rbp     --   (%rbp)
local 1        -- -4(%rbp)
local 2        -- -8(%rbp) and %rsp

--- top ---
```

