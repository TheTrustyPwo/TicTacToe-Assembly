.global _start
.section .text

_start:
	bl init_board
	mov r9, #0x1

	mov r7, #0x4
	mov r0, #0x1
	ldr r1, =welcome
	mov r2, #40
	swi 0

	bl game_loop

init_board:
	ldr r0, =board
	mov r1, #0x9
	mov r2, #0x0
	reset_board_loop:
		strb r2, [r0], #0x1
		subs r1, #0x1
		bne reset_board_loop
	bx lr

 game_loop:
	bl display_board
	bl get_input
	bl check_win
	bl check_all_filled
	bl switch_player
	bl game_loop

 display_board:
	mov r7, #0x4
	mov r0, #0x1
	mov r2, #0x1
	ldr r1, =newline
	swi 0

	ldr r4, =board
	mov r5, #0x3

	display_loop:
		mov r6, #0x3
		display_inner_loop:
			ldrb r8, [r4], #0x1
			cmp r8, #0x0
			ldreq r1, =empty
			cmp r8, #0x1
			ldreq r1, =X
			cmp r8, #0x2
			ldreq r1, =O
			swi 0
			subs r6, #0x1
			bne display_inner_loop
		ldr r1, =newline
		swi 0
		subs r5, #0x1
		bne display_loop

	ldr r1, =newline
	swi 0

	bx lr

get_input:
	mov r7, #0x4
	mov r0, #0x1
	mov r2, #0x8
	cmp r9, #0x1
	ldreq r1, =Xturn
	ldrne r1, =Oturn
	swi 0

	mov r7, #0x3
	mov r0, #0x0
	ldr r1, =input
	mov r2, #0x2
	swi 0

	ldrb r1, [r1]
	cmp r1, #'0'
	ble get_input
	cmp r1, #'9'
	bgt get_input
	sub r1, #'1'

	ldr r0, =board
	ldrb r2, [r0, r1]!
	cmp r2, #0x0
	bne get_input
	strb r9, [r0]
	bx lr

switch_player:
	cmp r9, #0x1
	moveq r9, #0x2
	movne r9, #0x1
	bx lr

check_all_filled:
	ldr r0, =board
	mov r1, #0x8
	mov r2, #0x0
	loop:
		ldrb r3, [r0, r1]
		cmp r3, #0x0
		moveq r2, #0x1
		subs r1, #0x1
		bge loop
	cmp r2, #0x0
	beq tie
	bx lr

check_win:
	ldr r0, =board

	mov r1, #0x2
	mov r6, #0x3
	row_loop:
		mov r2, #0x2
		mov r3, r9
		row_inner_loop:
			mul r4, r1, r6
			add r4, r2
			ldr r5, [r0, r4]
			and r3, r5
			subs r2, #0x1
			bge row_inner_loop
		cmp r3, r9
		beq win
		subs r1, #0x1
		bge row_loop

	mov r1, #0x2
	column_loop:
		mov r2, #0x2
		mov r3, r9
		column_inner_loop:
			mul r4, r2, r6
			add r4, r1
			ldr r5, [r0, r4]
			and r3, r5
			subs r2, #0x1
			bge column_inner_loop
		cmp r3, r9
		beq win
		subs r1, #0x1
		bge column_loop

	mov r3, r9
	ldr r4, [r0]
	and r3, r4
	ldr r4, [r0, #0x4]
	and r3, r4
	ldr r4, [r0, #0x8]
	and r3, r4
	cmp r3, r9
	beq win

	mov r3, r9
	ldr r4, [r0, #0x2]
	and r3, r4
	ldr r4, [r0, #0x4]
	and r3, r4
	ldr r4, [r0, #0x6]
	and r3, r4
	cmp r3, r9
	beq win

	bx lr
		
win:
	bl display_board
	mov r7, #0x4
	mov r0, #0x1
	mov r2, #0x7
	cmp r9, #0x1
	ldreq r1, =Xwin
	ldrne r1, =Owin
	swi 0
	b exit

tie:
	bl display_board
	mov r7, #0x4
	mov r0, #0x1
	mov r2, #0x5
	ldr r1, =tied
	swi 0
	b exit

exit:
	mov r7, #0x1
	mov r0, #69
	swi 0

.section .data
	welcome: .ascii "Welcome to Tic Tac Toe in ARM Assembly!\n"
	board: .byte 0, 0, 0, 1, 0, 2, 2, 0, 0
	empty: .ascii "-"
	X: .ascii "X"
	O: .ascii "O"
	Xturn: .ascii "X turn: "
	Oturn: .ascii "O turn: "
	Xwin: .ascii "X won!\n"
	Owin: .ascii "O won!\n"
	tied: .ascii "Tie!\n"
	input: .space 16
	newline: .ascii "\n"
