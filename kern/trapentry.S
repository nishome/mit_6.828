/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

 	TRAPHANDLER_NOEC(th0, T_DIVIDE)	 # 0 DE 除 0 异常 
	TRAPHANDLER_NOEC(th1, T_DEBUG)	# 1 DB 调试异常 
	TRAPHANDLER_NOEC(th2, T_NMI)	# 2 NMI
	TRAPHANDLER_NOEC(th3, T_BRKPT)	# 3 BP 断点异常
	TRAPHANDLER_NOEC(th4, T_OFLOW)	# 4 OF 溢出
	TRAPHANDLER_NOEC(th5, T_BOUND)	# 5 BR 对数组的引用超出边界
	TRAPHANDLER_NOEC(th6, T_ILLOP)	# 6 UD 无效或未定义的操作码 
	TRAPHANDLER_NOEC(th7, T_DEVICE)	# 7 NM 设备不可用(无数学协处理器) 
	TRAPHANDLER(th8, T_DBLFLT)			# 8 DF 双重故障(有错误代码)
	TRAPHANDLER(th10, T_TSS)		 # 10 TS 无效TSS(有错误代码)	
	TRAPHANDLER(th11, T_SEGNP)		# 11 NP 段不存在(有错误代码) 
	TRAPHANDLER(th12, T_STACK)		# 12 SS 栈错误(有错误代码) 
	TRAPHANDLER(th13, T_GPFLT)		# 13 GP 常规保护(有错误代码)
	TRAPHANDLER(th14, T_PGFLT)		# 14 PF 页故障(有错误代码) 
	TRAPHANDLER_NOEC(th16, T_FPERR)	# 16 MF 浮点处理单元错误 
	TRAPHANDLER_NOEC(th17, T_ALIGN)	# 17 AC 对齐检查 
	TRAPHANDLER_NOEC(th18, T_MCHK)	# 18 MC 机器检查 
	TRAPHANDLER_NOEC(th19, T_SIMDERR)	# 19 XM SIMD(单指令多数据)浮点异常

	TRAPHANDLER_NOEC(th_syscall,T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */
	# cpu已经将tf_ss，tf_err，tf_esp，tf_trapno，tf_eflags，tf_cs，tf_eip，tf_err入栈，TRAPHANDLER_NOEC及TRAPHANDLER将tf_trapno入栈，因此压入tf_ds，tf_es，以及通用寄存器即可
	_alltraps:
	pushl %ds
	pushl %es  #pushl压入一个双字（4个字节）
	pushal
	pushl $GD_KD
	popl %ds
	pushl $GD_KD
	popl %es
	pushl %esp	#压入trap()的参数tf，%esp指向Trapframe结构的起始地址
	call trap
