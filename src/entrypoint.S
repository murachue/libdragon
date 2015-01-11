/*
 *   N64 init code for GNU as
 */

#include "regs.S"

	.set at
	.set reorder
	.set mips64

	.section .boot, "x", @progbits
	.global _start
_start:
	lw t0, 0x80000318			/* memory size */
	li t1, 0x7FFFFFF0
	addu sp,t0,t1				/* init stack */
	la gp, _gp					/* init data pointer */
	li v0, 8
	sw v0,(0xbfc007fc)			/* magic N64 hardware init */

	/* a bit from libgloss so we start at a known state */
	/* note: newlib assume ~SR_FR... */
	li v0,SR_CU1|SR_PE|/*SR_FR|*/SR_KX|SR_SX|SR_UX
	mtc0 v0,C0_SR
	mtc0 $0,C0_CAUSE

	/* already copied (1MB that is enough) by 2nd-boot. skip. */
	/* and if you want it, use PI DMA! (dont forget to invalidate that area...) */
#if 0
	/* copy code and data */
	la a0, __text_start
	la a1, __data_end
	subu a2,a0,0x80000400		/* skip over .boot section */
	addu a2,a2,0xB0001000		/* address in rom */
data_init:
	lw t0,(a2)
	addiu a2,4
	sw t0,(a0)
	addiu a0,4
	bltu a0,a1, data_init

	/* make sure code and data are actually written */
	la a0,__text_start
	la a1,__data_end
	sub a1,a0
	jal data_cache_hit_writeback_invalidate
#endif

	/* fill .bss with 0s */
	la a0, __bss_start
	la a1, __bss_end
bss_init:
	sd $0,(a0)
	addiu a0,8
	bltu a0,a1, bss_init

	/* make sure .bss is actually written */
	la a0,__bss_start
	la a1,__bss_end
	sub a1,a0
	jal data_cache_hit_writeback_invalidate

	/* load interrupt vector */
	la t0,intvector
	la t1,0xa0000000
	la t2,4         # # of words of intvector. note: "la" takes 2 ops!
loadintvectorloop:
	lw t3,(t0)
	sw t3,0(t1)     # TLB refill, EXL = 0
	sw t3,0x80(t1)  # XTLB refill, EXL = 0 (X = 64-bit TLB)
	sw t3,0x100(t1) # Cache Error
	sw t3,0x180(t1) # Others (ex. SysCall)
	/* sync */
	cache HIT_INVALIDATE_I,0(t1)
	cache HIT_INVALIDATE_I,0x80(t1)
	cache HIT_INVALIDATE_I,0x100(t1)
	cache HIT_INVALIDATE_I,0x180(t1)
	addi t0,4
	addi t1,4
	addiu t2,-1
	bnez t2,loadintvectorloop

	jal main					/* call main app */

deadloop:
	j deadloop

intvector:
	la k1,inthandler
	jr k1

	.section .code
