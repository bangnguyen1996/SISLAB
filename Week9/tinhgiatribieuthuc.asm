.data
	xValue: .asciiz "Enter the value of x: "
	yValue: .asciiz "Enter the value of y: "
	zValue: .asciiz "Enter the value of z: "
	result: .asciiz "((5x+3y+z)/2)*3= "

	a:     .float 5.0
	b:     .float 3.0
	c:     .float 1.0
	d:     .float 2.0
	e:     .float 3.0
	
.text 
.globl main 
main:

	#Get the value of x 
	la $a0,xValue
	add $v0,$0,4
	syscall

	add $v0,$0,6
	syscall
	mov.s $f1,$f0

	#Calculate the value of 5x then copy to $f1
	lwc1 $f2, a
	mul.s $f1, $f1, $f2

	#Get the value of y
	la $a0, yValue
	add $v0, $0, 4
	syscall

	add $v0,$0,6
	syscall
	mov.s $f2, $f0

	#Calculate the value of 3y then copy to $f2
	lwc1 $f3, b
	mul.s $f2, $f2, $f3

	#calculate the value of 5x + 3y then copy to $f1
	add.s $f1, $f1, $f2

	#Get the value of z
	la $a0,zValue
	add $v0,$0,4
	syscall

	add $v0,$0,6
	syscall
	add $t2,$0,$v0
	mov.s $f2,$f0

	#Calculate the value of 5x+3y+z then copy to $f1
	add.s $f1, $f1, $f2

	#Calculate the value of (5x+3y+z)/2 then copy to $f1
	lwc1 $f2, d
	div.s $f1, $f1, $f2

	#Calculate the value of ((5x+3y+z)/2)*3 then copy to $f1
	lwc1 $f2, e
	mul.s $f1, $f1, $f2

	#Print result
	li $v0, 2
	add.s  $f12, $f12, $f1
	syscall


