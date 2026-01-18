# Learning from First Principles

## Plan

My plan is to approach from both sides --- i.e., bottom-up and top-down --- alternating when stuck.

### Bottom (Hardware/The phyiscal) Up

- Oscilloscope
- Breadboard
    - https://www.youtube.com/watch?v=CQ5CAqUHHxc&list=PL9o4z4GEXgfe2W4tT88whp0ZbHKGSoQiL&index=3&pp=gAQBiAQB0gcJCU8KAYcqIYzvsAgC
    - Ben Eater series

## Middle / The interface of Hardware and Software

- Boole's thoughts / Boolean algebra
- Why binary and not trinary

### Top (Software) Down

- VMMs (e.g., byhve, firecracker)
    - Implement a super (like really simple) minimal one
- Application hypervisors (e.g., gVisor)
    - Implement a super (like really simple) minimal one
- Containers implemented in Rust
    - Implement a super minimal one
    - [Liz Rice vid](https://www.youtube.com/watch?v=8fi7uSYlOdc&pp=ygUTbGl6IHJpY2UgY29udGFpbmVycw%3D%3D)
- Running an existing minimal kernel config and OS
- Writing a super minimal OS in Rust
    - https://www.youtube.com/watch?v=CQ5CAqUHHxc&list=PL9o4z4GEXgfe2W4tT88whp0ZbHKGSoQiL&index=3&pp=gAQBiAQB0gcJCU8KAYcqIYzvsAgC
- Writing a super minimal Kernel in Rust
    - Maybe doesn't even multi-task
- Writing a bootloader in machine code
    - https://www.youtube.com/watch?v=uQQsDWLRDuI&list=PLP29wDx6QmW7HaCrRydOnxcy8QmW0SNdQ
    - [Nir Lichtman](https://www.youtube.com/watch?v=u2Juz5sQyYQ&list=PL9o4z4GEXgfe2W4tT88whp0ZbHKGSoQiL&index=7&pp=gAQBiAQBsAgC)
