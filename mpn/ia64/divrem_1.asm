dnl  IA-64 mpn_divrem_1 and mpn_preinv_divrem_1 -- Divide an mpn number by an
dnl  unnormalized limb.

dnl  Copyright 2002, 2004, 2005 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.

dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of the GNU Lesser General Public License as published
dnl  by the Free Software Foundation; either version 3 of the License, or (at
dnl  your option) any later version.

dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
dnl  License for more details.

dnl  You should have received a copy of the GNU Lesser General Public License
dnl  along with the GNU MP Library.  If not, see http://www.gnu.org/licenses/.

include(`../config.m4')


C         cycles/limb
C Itanium 2:  29-30

C This was generated by gcc, then the loops were optimized.  The preinv entry
C point was shoehorned into the file.  Lots of things outside the loops could
C be streamlined.  It would probably be a good idea to merge the loops for
C normalized and unnormalized divisor, since the shifting stuff is done for
C free in parallel with other operations.  It would even be possible to merge
C all loops, if the ld8 were made conditional.

C TODO
C  * Consider delaying inversion for normalized mpn_divrem_1 entry till after
C    computing leading limb.
C  * Inline and interleave limb inversion code with loop setup code.

ASM_START()

C HP's assembler requires these declarations for importing mpn_invert_limb
	.global	mpn_invert_limb
	.type	mpn_invert_limb,@function

C INPUT PARAMETERS
C rp    = r32
C qxn   = r33
C up    = r34
C n     = r35
C vl    = r36
C vlinv = r37  (preinv only)
C cnt = r38    (preinv only)

PROLOGUE(mpn_preinv_divrem_1)
	.prologue
	.save	ar.pfs, r42
	alloc		r42 = ar.pfs, 7, 8, 1, 0
	.save	ar.lc, r44
	mov		r44 = ar.lc
	.save	rp, r41
	mov		r41 = b0
	.body
ifdef(`HAVE_ABI_32',
`	addp4		r32 = 0, r32
	sxt4		r33 = r33
	addp4		r34 = 0, r34
	sxt4		r35 = r35
	;;
')
	mov		r40 = r38
	shladd		r34 = r35, 3, r34
	;;
	adds		r34 = -8, r34
	;;
	ld8		r39 = [r34], -8
	;;

	add		r15 = r35, r33
	;;
	mov		r8 = r37
	shladd		r32 = r15, 3, r32	C r32 = rp + n + qxn
	cmp.le		p8, p0 = 0, r36
	;;
	adds		r32 = -8, r32		C r32 = rp + n + qxn - 1
	cmp.leu		p6, p7 = r36, r39
   (p8)	br.cond.dpnt	.Lpunnorm
	;;

   (p6)	addl		r15 = 1, r0
   (p7)	mov		r15 = r0
	;;
   (p6)	sub		r38 = r39, r36
   (p7)	mov		r38 = r39
	st8		[r32] = r15, -8
	adds		r35 = -2, r35		C un -= 2
	br	.Lpn

.Lpunnorm:
   (p6)	add		r34 = 8, r34
	mov		r38 = 0			C r = 0
	shl		r36 = r36, r40
   (p6)	br.cond.dptk	.Lpu
	;;
	shl		r38 = r39, r40		C r = ahigh << cnt
	cmp.ne		p8, p0 = 1, r35
	st8		[r32] = r0, -8
	adds		r35 = -1, r35		C un--
   (p8)	br.cond.dpnt	.Lpu

	mov		r23 = 1
	;;
	setf.sig	f6 = r8
	setf.sig	f12 = r23
	br		.L435
EPILOGUE()


PROLOGUE(mpn_divrem_1)
	.prologue
	.save	ar.pfs, r42
	alloc		r42 = ar.pfs, 5, 8, 1, 0
	.save	ar.lc, r44
	mov		r44 = ar.lc
	.save	rp, r41
	mov		r41 = b0
	.body
ifdef(`HAVE_ABI_32',
`	addp4		r32 = 0, r32
	sxt4		r33 = r33
	addp4		r34 = 0, r34
	sxt4		r35 = r35
	;;
')
	mov		r38 = r0
	add		r15 = r35, r33
	;;
	cmp.ne		p6, p7 = 0, r15
	;;
   (p7)	mov		r8 = r0
   (p7)	br.cond.dpnt	.Lret
	shladd		r14 = r15, 3, r32	C r14 = rp + n + qxn
	cmp.le		p6, p7 = 0, r36
	;;
	adds		r32 = -8, r14		C r32 = rp + n + qxn - 1
   (p6)	br.cond.dpnt	.Lunnorm
	cmp.eq		p6, p7 = 0, r35
   (p6)	br.cond.dpnt	.L179
	shladd		r14 = r35, 3, r34
	;;
	adds		r14 = -8, r14
	adds		r35 = -1, r35
	;;
	ld8		r38 = [r14]
	;;
	cmp.leu		p6, p7 = r36, r38
	;;
   (p6)	addl		r15 = 1, r0
   (p7)	mov		r15 = r0
	;;
	st8		[r32] = r15, -8
  (p6)	sub		r38 = r38, r36

.L179:
	mov		r45 = r36
	adds		r35 = -1, r35
	br.call.sptk.many b0 = mpn_invert_limb
	;;
	shladd		r34 = r35, 3, r34
.Lpn:
	mov		r23 = 1
	;;
	setf.sig	f6 = r8
	setf.sig	f12 = r23
	cmp.le		p6, p7 = 0, r35
	mov		r40 = 0
   (p7)	br.cond.dpnt	.L435
	setf.sig	f10 = r36
	mov		ar.lc = r35
	setf.sig	f7 = r38
	;;
	sub		r28 = -1, r36
C Develop quotient limbs for normalized divisor
.Loop1:		C 00				C q=r18 nh=r38/f7
	ld8		r20 = [r34], -8
	xma.hu		f11 = f7, f6, f0
	;;	C 04
	xma.l		f8 = f11, f12, f7	C q = q + nh
	;;	C 08
	getf.sig	r18 = f8
	xma.hu		f9 = f8, f10, f0
	xma.l		f8 = f8, f10, f0
	;;	C 12
	getf.sig	r16 = f9
		C 13
	getf.sig	r15 = f8
	;;	C 18
	cmp.ltu		p6, p7 = r20, r15
	sub		r15 = r20, r15
	sub		r16 = r38, r16
	;;	C 19
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0?
   (p6)	add		r16 = -1, r16
   (p0)	cmp.ne.unc	p6, p7 = r0, r0
	;;	C 20
   (p8)	cmp.ltu		p6, p7 = r15, r36
   (p8)	sub		r15 = r15, r36
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;	C 21
	.pred.rel "mutex",p6,p7
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0 still?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0 still?
	cmp.ltu		p6, p7 = r15, r36	C speculative
	sub		r28 = r15, r36		C speculative, just for cmp
	;;	C 22
   (p8)	cmp.ltu		p6, p7 = r28, r36	C redo last cmp if needed
   (p8)	mov		r15 = r28
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;	C 23
   (p6)	setf.sig	f7 = r15
   (p7)	sub		r15 = r15, r36
   (p7)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;	C 24
   (p7)	setf.sig	f7 = r15
	st8		[r32] = r18, -8
	mov		r38 = r15
	br.cloop.dptk	.Loop1
		C 29/30
	br.sptk		.L435
	;;
.Lunnorm:
	mux1		r16 = r36, @rev
	cmp.eq		p6, p7 = 0, r35
   (p6)	br.cond.dpnt	.L322
	shladd		r34 = r35, 3, r34
	;;
	adds		r34 = -8, r34
	;;
	ld8		r39 = [r34]
	;;
	cmp.leu		p6, p7 = r36, r39
   (p6)	br.cond.dptk	.L322
	adds		r34 = -8, r34
	;;
	mov		r38 = r39
	;;
	cmp.ne		p6, p7 = 1, r15
	st8		[r32] = r0, -8
	;;
   (p7)	mov		r8 = r38
   (p7)	br.cond.dpnt	.Lret
	adds		r35 = -1, r35
.L322:
	sub		r14 = r0, r16
	;;
	or		r14 = r16, r14
	;;
	mov		r16 = -8
	czx1.l		r14 = r14
	;;
	shladd		r16 = r14, 3, r16
	;;
	shr.u		r14 = r36, r16
	;;
	cmp.geu		p6, p7 = 15, r14
	;;
   (p7)	shr.u		r14 = r14, 4
   (p7)	adds		r16 = 4, r16
	;;
	cmp.geu		p6, p7 = 3, r14
	;;
   (p7)	shr.u		r14 = r14, 2
   (p7)	adds		r16 = 2, r16
	;;
	tbit.nz		p6, p7 = r14, 1
	;;
	.pred.rel "mutex",p6,p7
  (p6)	sub		r40 = 62, r16
  (p7)	sub		r40 = 63, r16
	;;
	shl		r45 = r36, r40
	shl		r36 = r36, r40
	shl		r38 = r38, r40
	br.call.sptk.many b0 = mpn_invert_limb
	;;
.Lpu:
	mov		r23 = 1
	;;
	setf.sig	f6 = r8
	setf.sig	f12 = r23
	cmp.eq		p6, p7 = 0, r35
   (p6)	br.cond.dpnt	.L435
	sub		r16 = 64, r40
	adds		r35 = -2, r35
	;;
	ld8		r39 = [r34], -8
	cmp.le		p6, p7 = 0, r35
	;;
	shr.u		r14 = r39, r16
	;;
	or		r38 = r14, r38
   (p7)	br.cond.dpnt	.Lend3
	;;
	mov		r22 = r16
	setf.sig	f10 = r36
	setf.sig	f7 = r38
	mov		ar.lc = r35
	;;
C Develop quotient limbs for unnormalized divisor
.Loop3:
	ld8		r14 = [r34], -8
	xma.hu		f11 = f7, f6, f0
	;;
	xma.l		f8 = f11, f12, f7	C q = q + nh
	;;
	getf.sig	r18 = f8
	xma.hu		f9 = f8, f10, f0
	shl		r20 = r39, r40
	xma.l		f8 = f8, f10, f0
	shr.u		r24 = r14, r22
	;;
	getf.sig	r16 = f9
	getf.sig	r15 = f8
	or		r20 = r24, r20
	;;
	cmp.ltu		p6, p7 = r20, r15
	sub		r15 = r20, r15
	sub		r16 = r38, r16
	;;
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0?
   (p6)	add		r16 = -1, r16
   (p0)	cmp.ne.unc	p6, p7 = r0, r0
	;;
   (p8)	cmp.ltu		p6, p7 = r15, r36
   (p8)	sub		r15 = r15, r36
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
	.pred.rel "mutex",p6,p7
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0 still?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0 still?
	cmp.ltu		p6, p7 = r15, r36	C speculative
	sub		r28 = r15, r36		C speculative, just for cmp
	;;
   (p8)	cmp.ltu		p6, p7 = r28, r36	C redo last cmp if needed
   (p8)	mov		r15 = r28
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
   (p6)	setf.sig	f7 = r15
   (p7)	sub		r15 = r15, r36
   (p7)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
   (p7)	setf.sig	f7 = r15
	st8		[r32] = r18, -8
	mov		r39 = r14
	mov		r38 = r15
	br.cloop.dptk	.Loop3
	;;
.Lend3:
	setf.sig	f10 = r36
	setf.sig	f7 = r38
	;;
	xma.hu		f11 = f7, f6, f0
	;;
	xma.l		f8 = f11, f12, f7	C q = q + nh
	;;
	getf.sig	r18 = f8
	xma.hu		f9 = f8, f10, f0
	shl		r20 = r39, r40
	xma.l		f8 = f8, f10, f0
	;;
	getf.sig	r16 = f9
	getf.sig	r15 = f8
	;;
	cmp.ltu		p6, p7 = r20, r15
	sub		r15 = r20, r15
	sub		r16 = r38, r16
	;;
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0?
   (p6)	add		r16 = -1, r16
   (p0)	cmp.ne.unc	p6, p7 = r0, r0
	;;
   (p8)	cmp.ltu		p6, p7 = r15, r36
   (p8)	sub		r15 = r15, r36
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
	.pred.rel "mutex",p6,p7
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0 still?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0 still?
	;;
   (p8)	sub		r15 = r15, r36
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
	cmp.ltu		p6, p7 = r15, r36
	;;
   (p7)	sub		r15 = r15, r36
   (p7)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
	st8		[r32] = r18, -8
	mov		r38 = r15
.L435:
	adds		r35 = -1, r33
	cmp.le		p6, p7 = 1, r33
   (p7)	br.cond.dpnt	.Lend4
	;;
	setf.sig	f7 = r38
	setf.sig	f10 = r36
	mov		ar.lc = r35
	;;
.Loop4:
	xma.hu		f11 = f7, f6, f0
	;;
	xma.l		f8 = f11, f12, f7	C q = q + nh
	;;
	getf.sig	r18 = f8
	xma.hu		f9 = f8, f10, f0
	xma.l		f8 = f8, f10, f0
	;;
	getf.sig	r16 = f9
	getf.sig	r15 = f8
	;;
	cmp.ltu		p6, p7 = 0, r15
	sub		r15 = 0, r15
	sub		r16 = r38, r16
	;;
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0?
   (p6)	add		r16 = -1, r16
   (p0)	cmp.ne.unc	p6, p7 = r0, r0
	;;
   (p8)	cmp.ltu		p6, p7 = r15, r36
   (p8)	sub		r15 = r15, r36
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
	.pred.rel "mutex",p6,p7
   (p6)	cmp.ne		p8, p9 = 1, r16		C is rH != 0 still?
   (p7)	cmp.ne		p8, p9 = 0, r16		C is rH != 0 still?
	cmp.ltu		p6, p7 = r15, r36	C speculative
	sub		r28 = r15, r36		C speculative, just for cmp
	;;
   (p8)	cmp.ltu		p6, p7 = r28, r36	C redo last cmp if needed
   (p8)	mov		r15 = r28
   (p8)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
   (p6)	setf.sig	f7 = r15
   (p7)	sub		r15 = r15, r36
   (p7)	add		r18 = 1, r18		C q = q + 1;	done if: rH > 0
	;;
   (p7)	setf.sig	f7 = r15
	st8		[r32] = r18, -8
	mov		r38 = r15
	br.cloop.dptk	.Loop4
	;;
.Lend4:
	shr.u		r8 = r38, r40
.Lret:
	mov		ar.pfs = r42
	mov		ar.lc = r44
	mov		b0 = r41
	br.ret.sptk.many b0
EPILOGUE()
ASM_END()
