#	Zadanie 1 - prosty kalkulator

.data

firstElem: .asciiz "\nPodaj pierwszy skladnik: "
secondElem: .asciiz "Podaj drugi skladnik: "
operation: .asciiz "\nKody operacji: \n0 - dodawanie \n1 - odejmowanie \n2 - dzielenie \n3 - mnozenie \n\nPodaj wybrana operacje na wprowadzonych skladnikach: "
result: .asciiz "\nWynik wybranej operacji: "
anotherOp: .asciiz "\n0 - NIE \n1 - TAK \nCzy chcesz wykonac kolejna operacje?: "
divByZeroMsg: .asciiz "\nNie mozna dzielic przez zero."
invalidOpMsg: .asciiz "\nWybrana opcja jest niedostepna."
remainder: .asciiz "\nReszta z dzielenia: "
chosenOpMsg: .asciiz "\nWybrana operacja: "
addMsg: .asciiz "dodawanie"
subMsg: .asciiz "odejmowanie"
divMsg: .asciiz "dzielenie"
mulMsg: .asciiz "mnozenie"
firstElemMsg: .asciiz "\nPierwszy skladnik: "
secondElemMsg: .asciiz "\nDrugi skladnik: "
startMsg: .asciiz "\n\n==================PROSTY KALKULATOR=================="
endMsg: .asciiz "\nKonczenie pracy programu..."



.text

main:
	li $v0, 4		# Nagłówek programu
	la $a0, startMsg
	syscall

	li $v0, 4		# Zapytanie o pierwszy składnik
	la $a0, firstElem
	syscall
	
	li $v0, 5		# Wczytanie pierwszego składnika z klawiatury
	syscall
	move $t1, $v0
	
	li $v0, 4		# Zapytanie o drugi składnik
	la $a0, secondElem
	syscall
	
	li $v0, 5		# Wczytanie drugiego składnika z klawiatury
	syscall
	move $t2, $v0
	
	li $v0, 4		# Zapytanie o rodzaj operacji
	la $a0, operation
	syscall
	
	li $v0, 5		# Wczytanie rodzaju operacji z klawiatury
	syscall
	move $t0, $v0	
	
	blt $t0, 0, invalidOp
	bgt $t0, 3, invalidOp
	
	li $v0, 4		# Informacja na temat wybranej operacji
	la $a0, firstElemMsg	# Pierwszy składnik
	syscall
	
	move $a0, $t1
	li $v0, 1
	syscall
	
	li $v0, 4		# Drugi składnik
	la $a0, secondElemMsg
	syscall
	
	move $a0, $t2
	li $v0, 1
	syscall
			# Rodzaj operacji
	li $v0, 4		
	la $a0, chosenOpMsg
	syscall
	
	
	beq $t0, 0, addition	# Wybór rozgałęzienia na podstawie wartości kodu operacji
	beq $t0, 1, subtraction
	beq $t0, 2, division
	beq $t0, 3, multiplication
	
	
addition:	
	li $v0, 4
	la $a0, addMsg
	syscall

	add $t3, $t1, $t2
	j printOutput
	
subtraction:	
	li $v0, 4
	la $a0, subMsg
	syscall
	
	sub $t3, $t1, $t2
	j printOutput
	
division:	
	li $v0, 4
	la $a0, divMsg
	syscall

	beq $t2, $zero, divByZero
	div $t1, $t2
	mflo $t3		# Wynik dzielenia jest przechowywany w rejestrze LO
	j printOutput   	# Reszta z dzielenia zaś w rejestrze HI
	
multiplication:	
	li $v0, 4
	la $a0, mulMsg
	syscall
	
	mul $t3, $t1, $t2
	j printOutput	
	
printOutput:
	li $v0, 4
	la $a0, result
	syscall
	
	move $a0, $t3
	li $v0, 1
	syscall 
	
	beq $t0, 2, printRemainder	# Jeśli kod operacji zgadza się z kodem przypisanym dzieleniu - 
			# - wyświetlanie reszty z dzielenia
	
	j askForAnother
	
askForAnother:			# Zapytanie o wykonanie kolejnej operacji
	li $v0, 4
	la $a0, anotherOp
	syscall
	
	li $v0, 5
	syscall
	
	beq $v0, 0, exit	# Jeśli 0 - koniec programu
	beq $v0, 1, main	# Jeśli 1 - powrót do main
	
	li $v0, 4		# Jeśli wybrana zostaje inna opcja
	la $a0, invalidOpMsg
	syscall
	
	j askForAnother
	
divByZero:			# Obsługa dzielenia przez zero
	li $v0, 4
	la $a0, divByZeroMsg
	syscall
	j askForAnother
	
printRemainder:			# Wyświetlanie reszty z dzielenia
	li $v0, 4
	la $a0, remainder
	syscall
	
	mfhi $a0		# Właściwe wyświetlanie na podstawie zawartości rejestru HI
	li $v0, 1
	syscall
	
	j askForAnother
	
invalidOp:			# Wyświetlenie informacji o niedostępności wybranej opcji
	li $v0, 4
	la $a0, invalidOpMsg
	syscall
	
	j askForAnother					

exit:			# Wyjście z programu
	li $v0, 4
	la $a0, endMsg
	syscall

	li $v0, 10
	syscall
	
			# KONIEC PROGRAMU
