
CpuReset V1.3, Copyright (c) 1994, 1998 Dmitry Stefankov
CpuReset: 486+ processor or compatible found.
CpuReset: Do a CPU shutdown, * => new value (general/segment/state).
CpuReset: Emulation method -> jump to F000:FFF0.
CpuReset: 32/16-bit General/Index/Stack Registers.
  EAX = 00000040*  EBX = 55550001*  ECX = 5555AAAA   EDX = 5555AAAA 
  ESI = 5555AAAA   EDI = 5555AAAA   EBP = 5555AAAA   ESP = 00000400*
CpuReset: 16-bit Segment Registers.
  CS = 08DF   DS = 0040*  ES = 0040*  SS = 0000*  FS = AAAA   GS = AAAA 
CpuReset: Processor State.
  EFLAGS = 00007002*
CpuReset: 32-bit Control Registers.
  CR0 = 00000010  CR2 = 00A8B000  CR3 = 00000000
CpuReset: 32-bit Debug Registers.
  DR0 = 00000000  DR1 = 00000000  DR2 = 00000000  DR3 = 00000000
  DR6 = FFFF0FF0  DR7 = 00000000
CpuReset: Done.
