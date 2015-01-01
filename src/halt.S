#include "regs.S"

/*
   halt: Notice system that "I am idle," this is sooooo important on emulators such as Project64...
         It exits from this inf-loop by inthandler.
*/

	.global halt
halt:
	b halt
	nop

	jr ra
	nop
