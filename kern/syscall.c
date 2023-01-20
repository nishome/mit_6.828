/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
// 将字符串打印到系统控制台。
// 字符串长度正好为“len”个字符。
// 内存错误时破坏环境。

static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, (void *)s, len, PTE_P | PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
// 从系统控制台读取字符而不阻塞。
// 返回字符，如果没有输入等待，则返回0。

static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
// 销毁给定环境（可能是当前运行的环境）。
// 成功时返回0，错误时返回<0。如果envid环境当前不存在，或调用者无权更改envid，则错误为：-E_BAD_ENV。
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
// 分派到正确的内核函数，传递参数。
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// 调用与“syscallno”参数对应的函数。返回任何适当的返回值。
	// LAB 3: Your code here.
	int32_t temp;
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char*)a1, (size_t)a2);
		temp = 0;
		break;
	case SYS_cgetc:
		temp = sys_cgetc();
		break;
	case SYS_getenvid:
		temp = sys_getenvid();
		break;
	case SYS_env_destroy:
		temp = sys_env_destroy((envid_t)a1);
		break;
	default:
		return -E_INVAL;
	}
	return temp;
}

