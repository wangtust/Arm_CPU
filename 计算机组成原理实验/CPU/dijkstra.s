	.file	"dijkstra.c"
	.text
	.globl	minDistance
	.type	minDistance, @function
minDistance:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movl	$2147483647, -12(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L2
.L4:
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	testl	%eax, %eax
	jne	.L3
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	cmpl	%eax, -12(%rbp)
	jl	.L3
	movl	-4(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	movl	%eax, -12(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, -8(%rbp)
.L3:
	addl	$1, -4(%rbp)
.L2:
	cmpl	$7, -4(%rbp)
	jle	.L4
	movl	-8(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	minDistance, .-minDistance
	.section	.rodata
.LC0:
	.string	" -> %c"
	.text
	.globl	printPath
	.type	printPath, @function
printPath:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movl	-12(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	cmpl	$-1, %eax
	je	.L9
	movl	-12(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %edx
	movq	-8(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	printPath
	movl	-12(%rbp), %eax
	addl	$65, %eax
	movl	%eax, %esi
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L6
.L9:
	nop
.L6:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	printPath, .-printPath
	.section	.rodata
.LC1:
	.string	"Vertex\t Distance\tPath"
.LC2:
	.string	"%c -> %c \t %d\t\t%c"
	.text
	.globl	printSolution
	.type	printSolution, @function
printSolution:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	movl	%edx, -20(%rbp)
	movl	%ecx, -24(%rbp)
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movl	-20(%rbp), %eax
	leal	65(%rax), %edi
	movl	-24(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	movl	-24(%rbp), %edx
	addl	$65, %edx
	movl	-20(%rbp), %ecx
	leal	65(%rcx), %esi
	movl	%edi, %r8d
	movl	%eax, %ecx
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	-24(%rbp), %edx
	movq	-16(%rbp), %rax
	movl	%edx, %esi
	movq	%rax, %rdi
	call	printPath
	movl	$10, %edi
	call	putchar@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	printSolution, .-printSolution
	.globl	dijkstra
	.type	dijkstra, @function
dijkstra:
.LFB3:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$144, %rsp
	movq	%rdi, -136(%rbp)
	movl	%esi, -140(%rbp)
	movl	%edx, -144(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -128(%rbp)
	jmp	.L12
.L13:
	movl	-128(%rbp), %eax
	cltq
	movl	$2147483647, -112(%rbp,%rax,4)
	movl	-128(%rbp), %eax
	cltq
	movl	$0, -80(%rbp,%rax,4)
	movl	-128(%rbp), %eax
	cltq
	movl	$-1, -48(%rbp,%rax,4)
	addl	$1, -128(%rbp)
.L12:
	cmpl	$7, -128(%rbp)
	jle	.L13
	movl	-140(%rbp), %eax
	cltq
	movl	$0, -112(%rbp,%rax,4)
	movl	$0, -124(%rbp)
	jmp	.L14
.L18:
	leaq	-80(%rbp), %rdx
	leaq	-112(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	minDistance
	movl	%eax, -116(%rbp)
	movl	-116(%rbp), %eax
	cltq
	movl	$1, -80(%rbp,%rax,4)
	movl	$0, -120(%rbp)
	jmp	.L15
.L17:
	movl	-120(%rbp), %eax
	cltq
	movl	-80(%rbp,%rax,4), %eax
	testl	%eax, %eax
	jne	.L16
	movl	-116(%rbp), %eax
	cltq
	salq	$5, %rax
	movq	%rax, %rdx
	movq	-136(%rbp), %rax
	addq	%rax, %rdx
	movl	-120(%rbp), %eax
	cltq
	movl	(%rdx,%rax,4), %eax
	testl	%eax, %eax
	je	.L16
	movl	-116(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %eax
	cmpl	$2147483647, %eax
	je	.L16
	movl	-116(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %edx
	movl	-116(%rbp), %eax
	cltq
	salq	$5, %rax
	movq	%rax, %rcx
	movq	-136(%rbp), %rax
	addq	%rax, %rcx
	movl	-120(%rbp), %eax
	cltq
	movl	(%rcx,%rax,4), %eax
	addl	%eax, %edx
	movl	-120(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %eax
	cmpl	%eax, %edx
	jge	.L16
	movl	-116(%rbp), %eax
	cltq
	movl	-112(%rbp,%rax,4), %edx
	movl	-116(%rbp), %eax
	cltq
	salq	$5, %rax
	movq	%rax, %rcx
	movq	-136(%rbp), %rax
	addq	%rax, %rcx
	movl	-120(%rbp), %eax
	cltq
	movl	(%rcx,%rax,4), %eax
	addl	%eax, %edx
	movl	-120(%rbp), %eax
	cltq
	movl	%edx, -112(%rbp,%rax,4)
	movl	-120(%rbp), %eax
	cltq
	movl	-116(%rbp), %edx
	movl	%edx, -48(%rbp,%rax,4)
.L16:
	addl	$1, -120(%rbp)
.L15:
	cmpl	$7, -120(%rbp)
	jle	.L17
	addl	$1, -124(%rbp)
.L14:
	cmpl	$6, -124(%rbp)
	jle	.L18
	movl	-144(%rbp), %ecx
	movl	-140(%rbp), %edx
	leaq	-48(%rbp), %rsi
	leaq	-112(%rbp), %rax
	movq	%rax, %rdi
	call	printSolution
	nop
	movq	-8(%rbp), %rax
	xorq	%fs:40, %rax
	je	.L19
	call	__stack_chk_fail@PLT
.L19:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	dijkstra, .-dijkstra
	.section	.rodata
.LC3:
	.string	"Enter start point (A-H): "
.LC4:
	.string	" %c"
.LC5:
	.string	"Enter end point (A-H): "
	.text
	.globl	main
	.type	main, @function
main:
.LFB4:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$288, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -272(%rbp)
	movl	$4, -268(%rbp)
	movl	$0, -264(%rbp)
	movl	$0, -260(%rbp)
	movl	$0, -256(%rbp)
	movl	$0, -252(%rbp)
	movl	$0, -248(%rbp)
	movl	$8, -244(%rbp)
	movl	$4, -240(%rbp)
	movl	$0, -236(%rbp)
	movl	$8, -232(%rbp)
	movl	$0, -228(%rbp)
	movl	$0, -224(%rbp)
	movl	$0, -220(%rbp)
	movl	$0, -216(%rbp)
	movl	$11, -212(%rbp)
	movl	$0, -208(%rbp)
	movl	$8, -204(%rbp)
	movl	$0, -200(%rbp)
	movl	$7, -196(%rbp)
	movl	$0, -192(%rbp)
	movl	$4, -188(%rbp)
	movl	$0, -184(%rbp)
	movl	$0, -180(%rbp)
	movl	$0, -176(%rbp)
	movl	$0, -172(%rbp)
	movl	$7, -168(%rbp)
	movl	$0, -164(%rbp)
	movl	$9, -160(%rbp)
	movl	$14, -156(%rbp)
	movl	$0, -152(%rbp)
	movl	$0, -148(%rbp)
	movl	$0, -144(%rbp)
	movl	$0, -140(%rbp)
	movl	$0, -136(%rbp)
	movl	$9, -132(%rbp)
	movl	$0, -128(%rbp)
	movl	$10, -124(%rbp)
	movl	$0, -120(%rbp)
	movl	$0, -116(%rbp)
	movl	$0, -112(%rbp)
	movl	$0, -108(%rbp)
	movl	$4, -104(%rbp)
	movl	$14, -100(%rbp)
	movl	$10, -96(%rbp)
	movl	$0, -92(%rbp)
	movl	$2, -88(%rbp)
	movl	$0, -84(%rbp)
	movl	$0, -80(%rbp)
	movl	$0, -76(%rbp)
	movl	$0, -72(%rbp)
	movl	$0, -68(%rbp)
	movl	$0, -64(%rbp)
	movl	$2, -60(%rbp)
	movl	$0, -56(%rbp)
	movl	$1, -52(%rbp)
	movl	$8, -48(%rbp)
	movl	$11, -44(%rbp)
	movl	$0, -40(%rbp)
	movl	$0, -36(%rbp)
	movl	$0, -32(%rbp)
	movl	$0, -28(%rbp)
	movl	$1, -24(%rbp)
	movl	$0, -20(%rbp)
	leaq	.LC3(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	-274(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rdi
	movl	$0, %eax
	call	__isoc99_scanf@PLT
	leaq	.LC5(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	-273(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rdi
	movl	$0, %eax
	call	__isoc99_scanf@PLT
	movzbl	-273(%rbp), %eax
	movsbl	%al, %eax
	leal	-65(%rax), %edx
	movzbl	-274(%rbp), %eax
	movsbl	%al, %eax
	leal	-65(%rax), %ecx
	leaq	-272(%rbp), %rax
	movl	%ecx, %esi
	movq	%rax, %rdi
	call	dijkstra
	movl	$0, %eax
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L22
	call	__stack_chk_fail@PLT
.L22:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.2) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
