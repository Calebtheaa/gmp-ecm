# mp_limb_t mulredc9(mp_limb_t * z, const mp_limb_t * x, const mp_limb_t * y,
#                 const mp_limb_t *m, mp_limb_t inv_m);
#
#  Stack:
#    inv_m    ## parameters
#    m
#    y
#    x
#    z							(4*(2k+7))%esp
#    ???   (1 limb???)
#    ebp      ## pushed registers                  (4*(2k+5))%esp
#    edi
#    esi
#    ebx
#    ...      ## counter (1 mp_limb_t)             (4*(2k+1))%esp
#    ...      ## tmp space (2*k+1 mp_limb_t)

include(`config.m4')
	TEXT
	GLOBL GSYM_PREFIX`'mulredc9
	TYPE(GSYM_PREFIX`'mulredc9,`function')

GSYM_PREFIX`'mulredc9:
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$80, %esp
	movl	%esp, %edi
### set tmp[0..2k+1[ to 0
	movl	$0, (%edi)
	movl	$0, 4(%edi)
	movl	$0, 8(%edi)
	movl	$0, 12(%edi)
	movl	$0, 16(%edi)
	movl	$0, 20(%edi)
	movl	$0, 24(%edi)
	movl	$0, 28(%edi)
	movl	$0, 32(%edi)
	movl	$0, 36(%edi)
	movl	$0, 40(%edi)
	movl	$0, 44(%edi)
	movl	$0, 48(%edi)
	movl	$0, 52(%edi)
	movl	$0, 56(%edi)
	movl	$0, 60(%edi)
	movl	$0, 64(%edi)
	movl	$0, 68(%edi)
	movl	$0, 72(%edi)
###########################################
	movl	$9, 76(%esp)

	.align 32
Loop:
	## compute u and store in %ebp
	movl	104(%esp), %eax
	movl	108(%esp), %esi
	movl	(%eax), %eax
	mull	(%esi)
	addl	(%edi), %eax
	mull	116(%esp)
	movl    %eax, %ebp
	movl	112(%esp), %esi
### addmul1: src[0] is (%esi)
###          dst[0] is (%edi)
###          mult is %ebp
###          k is 9
###          kills %eax, %edx and mmx regs 
###   dst[0,k[ += mult*src[0,k[  plus carry put in ecx
	pxor	%mm0, %mm0
	movd	%ebp, %mm7

	movd	(%esi), %mm1
	movd	(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, (%edi)
	psrlq	$32, %mm0

	movd	4(%esi), %mm1
	movd	4(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 4(%edi)
	psrlq	$32, %mm0

	movd	8(%esi), %mm1
	movd	8(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 8(%edi)
	psrlq	$32, %mm0

	movd	12(%esi), %mm1
	movd	12(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 12(%edi)
	psrlq	$32, %mm0

	movd	16(%esi), %mm1
	movd	16(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 16(%edi)
	psrlq	$32, %mm0

	movd	20(%esi), %mm1
	movd	20(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 20(%edi)
	psrlq	$32, %mm0

	movd	24(%esi), %mm1
	movd	24(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 24(%edi)
	psrlq	$32, %mm0

	movd	28(%esi), %mm1
	movd	28(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 28(%edi)
	psrlq	$32, %mm0

	movd	32(%esi), %mm1
	movd	32(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 32(%edi)
	psrlq	$32, %mm0
	movd	%mm0, %ecx
### carry limb is in %ecx
	addl	%ecx, 36(%edi)
	adcl	$0, 40(%edi)
	movl	104(%esp), %eax
	movl	(%eax), %ebp
	movl	108(%esp), %esi
### addmul1: src[0] is (%esi)
###          dst[0] is (%edi)
###          mult is %ebp
###          k is 9
###          kills %eax, %edx and mmx regs 
###   dst[0,k[ += mult*src[0,k[  plus carry put in ecx
	pxor	%mm0, %mm0
	movd	%ebp, %mm7

	movd	(%esi), %mm1
	movd	(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, (%edi)
	psrlq	$32, %mm0

	movd	4(%esi), %mm1
	movd	4(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 4(%edi)
	psrlq	$32, %mm0

	movd	8(%esi), %mm1
	movd	8(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 8(%edi)
	psrlq	$32, %mm0

	movd	12(%esi), %mm1
	movd	12(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 12(%edi)
	psrlq	$32, %mm0

	movd	16(%esi), %mm1
	movd	16(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 16(%edi)
	psrlq	$32, %mm0

	movd	20(%esi), %mm1
	movd	20(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 20(%edi)
	psrlq	$32, %mm0

	movd	24(%esi), %mm1
	movd	24(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 24(%edi)
	psrlq	$32, %mm0

	movd	28(%esi), %mm1
	movd	28(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 28(%edi)
	psrlq	$32, %mm0

	movd	32(%esi), %mm1
	movd	32(%edi), %mm2
	pmuludq	%mm7, %mm1
	paddq	%mm1, %mm2
	paddq	%mm2, %mm0
	movd	%mm0, 32(%edi)
	psrlq	$32, %mm0
	movd	%mm0, %ecx
### carry limb is in %ecx
   addl    %ecx, 36(%edi)
   adcl    $0, 40(%edi)

	addl	$4, 104(%esp)
	addl	$4, %edi
	decl	76(%esp)
	jnz	Loop
###########################################
### Copy result in z
	movl	100(%esp), %ebx
	movl	(%edi), %eax
	movl	%eax, (%ebx)
	movl	4(%edi), %eax
	movl	%eax, 4(%ebx)
	movl	8(%edi), %eax
	movl	%eax, 8(%ebx)
	movl	12(%edi), %eax
	movl	%eax, 12(%ebx)
	movl	16(%edi), %eax
	movl	%eax, 16(%ebx)
	movl	20(%edi), %eax
	movl	%eax, 20(%ebx)
	movl	24(%edi), %eax
	movl	%eax, 24(%ebx)
	movl	28(%edi), %eax
	movl	%eax, 28(%ebx)
	movl	32(%edi), %eax
	movl	%eax, 32(%ebx)
	movl	36(%edi), %eax	# carry
	addl    $80, %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	emms
	ret

`#'if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
`#'endif

