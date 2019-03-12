    .globl main
    .data
creditos:  .asciiz    "\t\t\t\t  --- CALCULADORA ---\n\n\t\t\t\t · Rodrigo Casamayor ·"
opciones:  .asciiz    "\n\n\nEscoja una opcion:\n    (1) - Sumar\n    (2) - Restar\n    (3) - Multiplicar\n    (4) - Dividir\n    (5) - Fibonacci\n    (6) - Convertir a IEEE754\n    (7) - Salir\n\n"
input:     .asciiz    "$ "
entero:    .asciiz    "\nIntroduzca el primer numero (entero):    "
flotante:  .asciiz    "Introduzca el segundo numero (flotante): "
posicion:  .asciiz    "\nEl numero de la secuencia de Fibonacci en la posicion: "
resultado: .asciiz    "--\nResultado: "
seguir:    .asciiz    "\n\nPresione cualquier tecla para continuar..."

    .text
main:
    # BIENVENIDA
    la $a0, creditos
    li $v0, 4
    syscall

    # MENU
    menu:
    # muestra las opciones
    la $a0, opciones
    li $v0, 4
    syscall

    opcion:
    # lee la opcion escogida
    la $a0, input
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    bgt	$t0, 7, opcion
    blt	$t0, 1, opcion

    # llama a las funciones
    beq $t0, 1, sumar
    beq $t0, 2, restar
    beq $t0, 3, multiplicar
    beq	$t0, 4, dividir
    beq $t0, 5, fibonacci
    beq $t0, 6, ieee

    # termina el programa
    li $v0, 10
    syscall

sumar:
    jal pedir_entero
    jal pedir_flotante

    # convierte entero a float
    mtc1    $t0,  $f12
    cvt.s.w $f12, $f12

    add.s $f14, $f12, $f13
    mov.s $f12, $f14

    jal mostrar_resultado

    j continuar

restar:
    jal pedir_entero
    jal pedir_flotante

    # convierte entero a float
    mtc1    $t0,  $f12
    cvt.s.w $f12, $f12

    sub.s $f14, $f12, $f13
    mov.s $f12, $f14

    jal mostrar_resultado

    j continuar

multiplicar:
    jal pedir_entero
    jal pedir_flotante

    # convierte entero a float
    mtc1    $t0,  $f12
    cvt.s.w $f12, $f12

    mul.s $f14, $f12, $f13
    mov.s $f12, $f14

    jal mostrar_resultado

    j continuar

dividir:
    jal pedir_entero
    jal pedir_flotante

    # convierte entero a float
    mtc1    $t0,  $f12
    cvt.s.w $f12, $f12

    div.s $f14, $f12, $f13
    mov.s $f12, $f14

    jal mostrar_resultado

    j continuar

fibonacci:
    jal pedir_posicion

    jal fibonacci_r

    # muestra el resultado
    la $a0, resultado
    li $v0, 4
    syscall
    move $a0, $t2
    li   $v0, 1
    syscall

    j continuar

fibonacci_r:
    addi $sp, $sp, -24
    sw   $ra, 0($sp)
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)

    add $s0, $a0, 0

    li $t0, 0
    li $t1, 1

    beq  $s0, $t0, is0
    beq  $s0, $t1, is1 # si es 0 o 1, devolvera 0 o 1 y saldra de este ciclo

    add $a0, $s0, -1

    jal fibonacci_r    # $t2 = fibonacci(a0-2)

    move $s1, $t2      # $s1 = fibonacci(a0-1)

    add $a0, $s0, -2

    jal fibonacci_r    # $t2 = fibonacci(a0-2)

    add $t2, $t2, $s1  # $t2 = fibonacci(a0-2) + fibonacci(a0-1)

    end_fibonacci_r:
        lw   $ra, 0($sp)
        lw   $s0, 4($sp)
        lw   $s1, 8($sp)
        addi $sp, $sp, 24
        jr $ra

    is1:
        li $t2,1
        b end_fibonacci_r

    is0:
        li $t2,0
        b end_fibonacci_r

ieee:
    jal pedir_flotante

    mfc1 $t0, $f13 # valor flotante en la entrada entera

    li $t1, 0  # indice minimo
    li $t2, 31 # indice maximo

    while_ieee:
    ble $t2 $t1 continuar # conteo decreciente
        srl $t4 $t0 $t2   # desplazar los bytes tantos bytes como el indice
        and $t4 0x1 	  # aplicar mascara para obtener el ultimo valor

        move $a0 $t4	  # imprime el valor
        li $v0, 1
        syscall

        sub $t2 1
    b while_ieee

pedir_entero:
    la $a0, entero
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    jr $ra

pedir_flotante:
    la $a0, flotante
    li $v0, 4
    syscall
    li $v0, 6
    syscall
    mov.s $f13, $f0

    jr $ra

pedir_posicion:
    la $a0, posicion
    li $v0, 4
    syscall
    li $v0, 5
    syscall
    add $a0, $v0, 1 # nos movemos a a0 y sumamos uno para contemplar el 0

    jr $ra

mostrar_resultado:
    la $a0, resultado
    li $v0, 4
    syscall
    li $v0, 2
    syscall

    jr $ra

continuar:
    # continuar?
    la $a0, seguir
    li $v0, 4
    syscall
    li $v0, 12
    syscall

    b menu

    # espera un momento
    #li $t6, 1000000
    #delay:
    #subu $t6, $t6, 1
    #bnez $t6, delay

    # limpia la consola
    #la $a0, clear_console
    #li $v0, 4
    #syscall
