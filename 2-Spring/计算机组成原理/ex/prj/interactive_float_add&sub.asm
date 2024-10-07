.data        
    choose_op:  .asciiz "\nPlease choose a function.(0:exit,1:add,2:sub)\n" 
    input_num1: .asciiz "Please input float number1 = "
    input_num2: .asciiz "Please input float number2 = "
    print_dec:  .asciiz "\nResult of decimal = "
    print_bin:  .asciiz "\nResult of binary = "
    print_hex:  .asciiz "\nResult of hexadecimal = "
    print_end:  .asciiz "=============== End ==============="
    print_error:.asciiz "Error op choose!\n"
    print_overflow: .asciiz "Exponential overflow!\n"
    print_underflow: .asciiz "Exponential underflow!\n"
.text 
main:
    # 请输入op
    la $a0,choose_op            
    li $v0,4
    syscall                    
    li $v0,5            # 输入信息
    syscall
    move $t0,$v0
    beq $v0,$0,exit # 退出程序 | 否则继续
    # 输入num1和num2
    jal function_inputNum
    
    li    $t7,1
    bne    $t7,$t0,next_one # 加法 | 否则下一个
    jal function_myadd
    move $s0,$a2
    j output_number
    
    next_one:
    li    $t7,2
    bne    $t7,$t0,error # 减法 | 否则错误
    jal function_mysub
    move $s0,$a2
    j output_number
    
    output_number:
    jal function_outDec
    jal function_outBinary
    jal function_outHex
    j main

    error:                                 # 处理非法输入情况
    la $a0,print_error
    li $v0,4
    syscall
    j main

    exit: # 程序退出 
    la  $a0, print_end                
    li  $v0, 4 # print string
    syscall             
    li $v0,10  # exit syscall
    syscall

# 处理输入
function_inputNum:
    la $a0,input_num1                 
    li $v0,4
    syscall
    # 输入num1
    li $v0,6
    syscall
    mfc1 $t5,$f0  # 直接以IEEE754格式存储到$a0

    la $a0,input_num2                 
    li $v0,4
    syscall
    # 输入num2
    li $v0,6
    syscall                     
    mfc1 $t6,$f0
    move $a0,$t5
    move $a1,$t6
    jr $ra

function_mysub:
    # 将$a1的符号位变号即可
    andi $t7,$a1,0x80000000 # a1 符号位 掩膜
    nor $t7,$t7,$0  # $1= ~($2 | S3)= ~$2 & ~$s3
    andi $t7,$t7,0x80000000 # 取掩膜
    or $a1,$a1,$t7 # 组合符号位
    j function_myadd

function_myadd:
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
    andi $s0,$a0,0x80000000    # a0 符号位  掩膜
    andi $s1,$a0,0x7f800000    # a0指数   掩膜
    srl  $s1,$s1,23            # 归右
    andi $s2,$a0,0x7fffff      # a0尾数   掩膜
    addi $s2,$s2,0x00800000    # 恢复前导1

    andi $s3,$a1,0x80000000    # a1 符号位
    andi $s4,$a1,0x7f800000    # a1指数
    srl  $s4,$s4,23            # 归右
    andi $s5,$a1,0x7fffff      # a1尾数
    addi $s5,$s5,0x00800000    # 恢复前导1

    # 2.指数对齐
    move $t1,$s1                # t1 初始化
    beq  $s4,$s1,sum_branch
    blt  $s1,$s4,align_a0       # $s1<$s4，处理a0
    blt  $s4,$s1,align_a1       # $s4<$s1，处理a1

    # a0指数对齐
    align_a0: 
    sub  $t7,$s4,$s1
    srlv $s2,$s2,$t7            # a0 尾数右移
    move $t1,$s4                # a1 对齐的指数
    j    sum_branch

    # a1指数对齐
    align_a1: 
    sub  $t7,$s1,$s4
    srlv $s5,$s5,$t7            # a1尾数右移
    move $t1,$s1                # a0 对齐的指数
    j    sum_branch

    # 3.有效数相加
    sum_branch:
    xor  $t7,$s0,$s3            # 符号位判断，异或
    beq  $t7,$0,sum_same        # 符号相同，直接加减
    j    sum_differ

    # 异号相加，即作加法
    sum_same:
    add  $t2,$s2,$s5             # 符号相同，绝对值直接相加 s2+s5
    move $t0,$s0
    j    judge_overflow

    # 异号相加，即作减法
    sum_differ:
    beq  $s2,$s5,result_zero
    blt  $s2,$s5,little_add_big
    sub  $t2,$s2,$s5             # s2>=$s5
    move $t0,$s0                 # a0的符号位
    j    judge_underflow
    little_add_big:
    sub  $t2,$s5,$s2             # s2<$s5
    move $t0,$s3                 # a1的符号
    j    judge_underflow

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
    blt  $t1,1,error_underflow    # 指数结果判断溢出
    bgt  $t1,255,error_overflow  
    sll  $t1,$t1,23               # 指数归左
    andi $t1,$t1,0x7f800000       # 掩膜，对应位置取数
    andi $t2,$t2,0x7fffff         # 掩膜，对应位置取数，23位，直接忽略前导1
    or   $t2,$t2,$t1              # 组合指数
    or   $t2,$t2,$t0              # 组合符号位
    move $a2,$t2
    j return_myadd

    # 最终计算结果为0
    result_zero:
    addi $a2,$0,0x00000000
    j return_myadd

    # 指数上溢处理
    error_overflow:
    la $a0,print_overflow
    li $v0,4
    syscall
    j result_zero

    # 指数下溢处理
    error_underflow:
    la $a0,print_underflow
    li $v0,4
    syscall
    j result_zero

    # 6.收回空间
    return_myadd:
    lw $s0,0($sp)
    lw $s1,4($sp)
    lw $s2,8($sp) 
    lw $s3,12($sp)
    lw $s4,16($sp)
    lw $s5,20($sp)
    lw $ra,24($sp)
    addi $sp,$sp,28
    jr $ra


# 十进制输出
function_outDec: 
    move $t0,$s0
    la $a0,print_dec
    li $v0,4
    syscall

    mtc1 $t0,$f12   # 使用了浮点指令 
    li $v0,2
    syscall 
    jr $ra

# 二进制输出
function_outBinary:
    addi $sp,$sp,-4 
    sw $ra,0($sp)
    
    move $t0,$s0
    la $a0,print_bin
    li $v0,4
    syscall

    addi $t7,$0,0           # $t7 掩膜结果数
    addi $t1,$0,32          # $t1 移位
    addi $t2,$0,0x80000000  # 1000_0000_... $t2做掩膜
    
    # 逐1位输出
    binaryLoop: 
    and  $t7,$t0,$t2        # 掩膜结果
    srl  $t2,$t2,1          # 掩膜右移
    addi $t1,$t1,-1         # 移位数
    srlv $t7,$t7,$t1        # 结果位右移
    add  $a0,$t7,$zero      # 传参
    li   $v0,1              # 输出int
    syscall
    beq  $t1,$0,return_outBinary
    j    binaryLoop
    
    return_outBinary: 
    lw   $ra,0($sp)
    addi $sp,$sp,4
    jr   $ra

# 十六进制  
function_outHex: 
    addi $sp,$sp,-4 
    sw $ra,0($sp)

    move $t0,$s0
    la $a0,print_hex
    li $v0,4
    syscall

    li $t7,0 # $t7 掩膜结果数
    addi $t1,$0,32 # $t1 移位
    addi $t2,$0,0xf0000000  # 1111_0000_... $t2做掩膜
    
    # 逐4位输出
    hexLoop: 
    beq $t1,$0,return_outHex
    and  $t7,$t0,$t2 # 掩膜结果
    srl  $t2,$t2,4   # 掩膜右移
    addi $t1,$t1,-4  # 移位数
    srlv  $t7,$t7,$t1     # 结果位右移
    bgt $t7,9,outChar # 超过9需要输出char
    add  $a0,$t7,$zero    # 传参
    li $v0,1             # 输出int
    syscall
    j hexLoop

    # 输出字符串
    outChar:    
    add $a0,$t7,55           #  ASCZII码表示字母 = 数字+55
    li $v0,11
    syscall
    j    hexLoop

    return_outHex:                # 输出结束
    lw    $ra,0($sp)
    addi $sp,$sp,4
    jr $ra
