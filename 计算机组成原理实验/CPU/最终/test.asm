# 汇编程序示例，涵盖所有22条指令

# 初始化寄存器
addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20
addi x3, x0, 30      # x3 = 30
addi x4, x0, 40      # x4 = 40

# 算术和逻辑指令
add x5, x1, x2       # x5 = x1 + x2 = 30
sub x6, x3, x1       # x6 = x3 - x1 = 20
and x7, x1, x2       # x7 = x1 & x2 = 0
or x8, x1, x2        # x8 = x1 | x2 = 30
xor x9, x1, x2       # x9 = x1 ^ x2 = 30
sll x10, x1, x2      # x10 = x1 << x2[4:0] = 10 << 20 = 10485760
srl x11, x3, x1      # x11 = x3 >> x1[4:0] = 30 >> 10 = 0
sra x12, x3, x1      # x12 = x3 >>> x1[4:0] = 30 >>> 10 = 0

# 立即数指令
andi x13, x1, 15     # x13 = x1 & 15 = 10 & 15 = 10
ori x14, x1, 15      # x14 = x1 | 15 = 10 | 15 = 15
xori x15, x1, 15     # x15 = x1 ^ 15 = 10 ^ 15 = 5
slli x16, x1, 2      # x16 = x1 << 2 = 10 << 2 = 40
srli x17, x1, 2      # x17 = x1 >> 2 = 10 >> 2 = 2
srai x18, x1, 2      # x18 = x1 >>> 2 = 10 >>> 2 = 2

# 加载和存储指令
sw x1, 0(x0)         # 存储 x1 到内存地址 0
lw x19, 0(x0)        # 从内存地址 0 加载到 x19

# 高位加载指令
lui x20, 0x12345     # x20 = 0x12345000

# 分支指令
beq x1, x2, label1   # 如果 x1 == x2，跳转到 label1
blt x1, x2, label2   # 如果 x1 < x2，跳转到 label2
bltu x1, x2, label3  # 如果 x1 < x2 (无符号)，跳转到 label3

# 跳转指令
jal x21, label4      # 跳转到 label4，并将返回地址存储到 x21

label1:
addi x22, x0, 1      # x22 = 1
label2:
addi x23, x0, 2      # x23 = 2
label3:
addi x24, x0, 3      # x24 = 3
label4:
addi x25, x0, 4      # x25 = 4