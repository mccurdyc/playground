# Downstairs

Building the stack that my career is built upon; from scratch.

I know what the components _do_ (generally), but I've never actually looked at the
code or wrote the code for any of them.

How much of what exists has grown --- possibly unnecessarily --- in complexity
either to be generalized, keep up with competing solutions or some company's priorities? What

What if we remove all of these assumptions, goals and/or priorities?

I wouldn't be surprised if I never "finished" this project. I want to be
careful not to set too high of expectations or lofty goals such that I
end up paralyzing myself from continuing. Keep things "bite sized". Plan
to just have this as a career-long running side project. Today, everything
feels so instantenous until you peel back or dig deeper. You often see or hear
about the results or final thing (e.g., Unix or someone built some awesome new thing)
but no one talks about how it took years or decades until it got to the recognizable point.

## "Whys?"

## "What Ifs?"

1. What if the Unix philosphy wasn't "do one thing well; and pipes"?

    Honestly, I agree quite strongly with this principle. But, what if.

2. What if `ls` and some (none?) of these core binaries weren't a thing? And instead
the OS had no interactivity at all? No shell (I mean this is like "distroless" containers (https://github.com/GoogleContainerTools/distroless).

3. What if there were fewer syscalls? What if syscalls weren't the interface?

4. What if we applied the Rust ownership model to the kernel? (What does this even mean?)

5. What if systems were more homogenous? e.g., one language? less "pluggable"?

## Things that I appreciate, but bother me, today

- Containers no longer feel simple, cross-platform, "fast" or lightweight
- Nix's (not the language) goal is beautiful, but the interface (Nix the language) is too complex

## Proposed Learning Path

What if we implemented a very trivial stack? Can I even do it?

0. Might start with https://www.linuxfromscratch.org/lfs/view/stable/index.html

    Then replace components with self-built versions.

1. What really is a VM? Can we build an extremely trivial one? Do I understand the difference between a VM and a MicroVM (uses virtio drivers)

    Maybe I end up just building a trivial Linux container, but then I can't play with the kernel used safely. Nor will I learn about hypervisors.

2. (might need to be first) What is a hypervisor? Build one. gvisor.

3. What is a kernel? Can we build one?

4. What is an OS? Can we build a trivial one?

## Alternative Paths

### Can I get Oxide to run outside of an Oxide rack?

Kernel
- https://github.com/oxidecomputer/hubris

OS
- https://illumos.org/man/8/bhyve
- https://code.illumos.org/plugins/gitiles/illumos-gate/+/refs/heads/master/usr/src
- https://github.com/oxidecomputer/helios
- https://github.com/oxidecomputer/propolis

## From Zero

From AI:

### The CPU's First Assumption: The Reset Vector

When you press the power button, the CPU is in a very primitive state, running in what is called "real mode" (on x86/x64 architectures) and assuming minimal resources.  

    1. The Power-On Signal: The power supply stabilizes and sends a Power Good signal to the motherboard's chipset.  

    2. The Reset Vector: The chipset drops the CPU's reset line, and the CPU wakes up. The CPU is hardwired to immediately start executing instructions from a specific memory address, known as the Reset Vector.

        - The Assumption: The CPU assumes that the first set of instructions it needs is located at this pre-defined, fixed address, which points to the start of the system firmware (BIOS/UEFI).  

    3. Loading the BIOS/UEFI: The Reset Vector is mapped not to RAM (which is uninitialized) but to a small, non-volatile memory chip on the motherboard that holds the BIOS (Basic Input/Output System) or the more modern UEFI (Unified Extensible Firmware Interface).

        - How it's loaded: It's not "loaded" into RAM initially; the CPU just starts executing the code directly from the flash memory chip because that memory is mapped into the address space the CPU is told to look at.

Okay, this reminds me of https://www.youtube.com/watch?v=LnzuMJLZRdU by Ben Eater.

Then, BIOS (system checks), bootloader (find, copy to RAM and start the kernel), then the kernel.
