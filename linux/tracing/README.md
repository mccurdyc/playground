# tracing

This exercise was inspired by this talk by Steven Rostedt - _Learning the Linux Kernel with Tracing_.

- https://youtu.be/JRyrhsx-L5Y?si=x6xw_E-Jrbt9pWLK

Is this still current? It's 7-years old and I think eBPF has matured a lot in the last seven years. Replacing ftrace?
Using ftrace under the hood?

## strace, ftrace, and eBPF?

- strace is userspace tracing
- ftrace is kernel space tracing

- Ftrace directly: Learning internals, quick investigations, minimal dependencies
- eBPF/bpftrace: Custom metrics, production systems, complex filtering
- perf: CPU profiling, cache analysis, hotspot identification
- trace-cmd: Recording/analyzing complex trace sessions

## `trace-cmd`


