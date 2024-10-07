.data
hello:   .asciiz "Hello\n"   
hh:   .asciiz "\n"
good:   .asciiz "Good:"
total:   .asciiz "Total:"
godie:   .asciiz "Thank you Bye" 
.text
main:
    la $a0,hello
    li $v0,4
    syscall
    li  $v0, 40           #seed
    addi $a0, $0, 10  
    syscall
    move $s1,$0 
    move $s0,$0 # for i=0
mainloop:
    beq $s0,100,end # i<100
    addi $s0,$s0,1 # i++
    jal getrandom # a0放第一个浮点数
    move $a1,$a0 # a1放第二个浮点数
    mov.s $f1,$f0
    jal getrandom
    jal getsub # #####################  四选一： getadd  getsub  getmul getdiv ##############################
    move $a3,$t0  # 计算正确答案保存在$t0
    jal mysub # 浮点数放在$a0,$a1中，请将计算结果放入$a2中，临时寄存器可以随意修改，其他寄存器改了请恢复
    bne $a2,$a3,mainloop
    addi $s1,$s1,1
    j mainloop


mysub:
# 将$a1的符号位变号即可
andi $t7,$a1,0x80000000 # a1 符号位 掩膜
nor $t7,$t7,$0  # $1= ~($2 | S3)= ~$2 & ~$s3
andi $t7,$t7,0x80000000 # 取掩膜
or $a1,$a1,$t7 # 组合符号位
j myadd

myadd:
# #####################
# 查看打印结果
# li $v0,1
# syscall
# la $a0,hh
# li $v0,4
# syscall
# #####################
# 浮点数放在$a0,$a1中，请将计算结果放入$a2中
# 临时寄存器可以随意修改，其他寄存器改了请恢复

# 0.开空间 1 Word = 4 Byte
addi $sp,$sp,-28
sw $ra,24($sp)
sw $s5,20($sp)  
sw $s4,16($sp)  
sw $s3,12($sp)  
sw $s2,8($sp) 
sw $s1,4($sp)
sw $s0,0($sp)

# 1.取指数尾数（32bit浮点数）
andi $s0,$a0,0x80000000 # a0 符号位  掩膜
andi $s1,$a0,0x7f800000 # a0指数   掩膜
srl $s1,$s1,23  # 归右
andi $s2,$a0,0x7fffff # a0尾数   掩膜
addi $s2,$s2,0x00800000 # 恢复前导1

andi $s3,$a1,0x80000000 # a1 符号位
andi $s4,$a1,0x7f800000 # a1指数
srl $s4,$s4,23  # 归右
andi $s5,$a1,0x7fffff # a1尾数
addi $s5,$s5,0x00800000 # 恢复前导1

# 2.指数对齐
move $t1,$s1 # t1 初始化
beq $s4,$s1,sum_branch
blt $s1,$s4,align_a0 # $s1<$s4，处理a0
blt $s4,$s1,align_a1 # $s4<$s1，处理a1

# a0指数对齐
align_a0: 
sub $t7,$s4,$s1
srlv $s2,$s2,$t7 # a0尾数右移
move $t1,$s4 # a1 对齐的指数
j sum_branch

# a1指数对齐
align_a1: 
sub $t7,$s1,$s4
srlv $s5,$s5,$t7 # a1尾数右移
move $t1,$s1  # a0 对齐的指数
j sum_branch

# 3.有效数相加
sum_branch:
xor $t7,$s0,$s3  # 符号位判断
beq $t7,$0,sum_same  # 符号相同，直接加减
j sum_differ

# 异号相加，即作加法
sum_same:
add $t2,$s2,$s5 # 符号相同，绝对值直接相加 s2+s5
move $t0,$s0
j judge_overflow

# 异号相加，即作减法
sum_differ:
beq $s2,$s5,result_zero
blt $s2,$s5,little_add_big
sub $t2,$s2,$s5  # s2>=$s5
move $t0,$s0  # a0的符号位
j judge_underflow
little_add_big:
sub $t2,$s5,$s2  # s2 < $s5
move $t0,$s3 # a1的符号
j judge_underflow

# 尾数计算结果判断上溢
judge_overflow:
blt $t2,0x01000000,result  # 保证第25位以上为0
srl $t2,$t2,1   # t2 计算的结果
addi $t1,$t1,1  # t1 对齐的指数
j judge_overflow

# 尾数计算结果判断下溢
judge_underflow:
bge $t2,0x00800000,result # 保证第24位=1
sll $t2,$t2,1   # t2 计算的结果
subi $t1,$t1,1  # t1 对齐的指数
j judge_underflow

# 最终计算结果组合（非0）
result:
sll $t1,$t1,23  # 指数归左
# andi $t1,$t1,0x7f800000 # 掩膜，对应位置取数
andi $t2,$t2,0x7fffff # 掩膜，对应位置取数，23位，直接忽略前导1
or $t2,$t2,$t1 # 组合指数
or $t2,$t2,$t0 # 组合符号位
move $a2,$t2
j myadd_return

# 最终计算结果为0
result_zero:
addi $a2,$0,0x00000000
j myadd_return

# 6.收回空间
myadd_return:
lw $s0,0($sp)
lw $s1,4($sp)
lw $s2,8($sp) 
lw $s3,12($sp)
lw $s4,16($sp)
lw $s5,20($sp)
lw $ra,24($sp)
addi $sp,$sp,28
jr $ra


getrandom:
li  $v0, 43           #getrandom
addi $a0, $0, 10  # 
syscall
sub $sp,$sp,4
s.s $f0,($sp)
lw $a0,($sp)
addi $a0,$a0,0x2000000
andi $a0,$a0,0xfffff000
sw $a0,($sp)
l.s $f0,($sp)
addi $sp,$sp,4
jr $ra

getadd:
add.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp) # 把单精度浮点数从寄存器存储到存储器中
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getsub:
sub.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getmul:
mul.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra
getdiv:
div.s $f0,$f0,$f1
sub $sp,$sp,4
s.s $f0,($sp)
lw $t0,($sp)
addi $sp,$sp,4
jr $ra

end:
la    	$a0,	good			
li    	$v0,	4
syscall
move $a0,$s1		
li    	$v0,	1
syscall
la    	$a0,	hh			
li    	$v0,	4
syscall
la    	$a0,	total			
li    	$v0,	4
syscall
move $a0,$s0		
li    	$v0,	1
syscall
la    	$a0,	hh			
li    	$v0,	4
syscall
la    	$a0,	godie			
li    	$v0,	4
syscall
