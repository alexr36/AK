#	Zadanie 2 - szyfr Cezara

#	Rejestry tymczasowe:
#	$t0 - wartość wyboru
#	$t1 - adres początkowy tekstu
#	$t2 - aktualny znak tekstu
#
#	Rejestry zapisane:
#	$s0 - wartość przesunięcia
#
#	Informacje dla użytkownika:
#	- korzystamy z alfabetu: ABCDEFGHIJKLMNOPQRSTUVWXYZ
#	- można używać małych oraz wielkich liter podczas wpisywania tekstu, lecz wynik jest konwertowany na wielkie
#	- przesunięcie może być ujemne
#	
#	Przykład wyniku:
#	- szyfrowanie dla przesunięcia 23: 'Alex Rogozinski' ---> 'XIBU OLDLWFKPHF'

.data

startMsg: .asciiz "\n\n================== SZYFR CEZARA =================="
endMsg: .asciiz "\nKonczenie pracy programu..."
choiceMsg: .asciiz "\nPodaj wybrana opcje: "
askShiftMsg: .asciiz "\nPodaj przesuniecie: "
toEncryptMsg: .asciiz "\nPodaj tekst (maks. 16 znakow): "
encryptionMsg: .asciiz "szyfrowanie"
decryptionMsg: .asciiz "odszyfrowanie"
shiftMsg: .asciiz "\nPrzesuniecie: "
choosenOpMsg: .asciiz "\nWybrana operacja: "
invalidOpMsg: .asciiz "\nBrak wybranej operacji."
operationChoice: .asciiz "\n0 - szyfrowanie \n1 - odszyfrowanie \n\nPodaj wybrana opcje: "
anotherOp: .asciiz "\n\n0 - NIE \n1 - TAK \nCzy chcesz wykonac kolejna operacje?: "
result: .asciiz "\nWynik: "

buffer: .space 17

.text

main:
	li $v0, 4		# Nagłówek programu
	la $a0, startMsg
	syscall
	
	li $v0, 4		# Pytanie o rodzaj operacji
	la $a0, operationChoice
	syscall
	
	li $v0, 5		
	syscall
	move $t0, $v0
	
	blt $t0, 0, invalidOp	# Sprawdzenie, czy podany numer operacji mieści się w dostępnym zakresie
	bgt $t0, 1, invalidOp
	
	li $v0, 4		# Pytanie o wartość przesunięcia
	la $a0, askShiftMsg
	syscall
	
	li $v0, 5		
	syscall
	move $s0, $v0
	
	li $v0, 4		# Zapytanie o tekst
	la $a0, toEncryptMsg
	syscall
	
	li $v0, 8
	la $a0, buffer
	li $a1, 17
	syscall
	
	li $v0, 4		# Prompt 'Wybrana operacja: '
	la $a0, choosenOpMsg
	syscall		
	
	beqz $t0, encrypt	# Przejście do odpowiej operacji
	beq $t0, 1, decrypt

printOutput:			# Wypisywanie wyniku szyfrowania/odszyfrowania
	li $v0, 4	
	la $a0, result
	syscall
	
	li $v0, 4
	la $a0, buffer
	syscall
	
	j askForAnother

encrypt:
	li $v0, 4		# Wypisanie informacji na temat rodzaju operacji
	la $a0, encryptionMsg
	syscall
	
	la $t1, buffer		# Wskaźnik na początek tekstu
	
	j processChar
	
decrypt:
	li $v0, 4		# Wypisanie informacji na temat rodzaju operacji
	la $a0, decryptionMsg
	syscall
	
	la $t1, buffer		# Wskaźnik na początek tekstu
	
	negu $s0, $s0		# Negacja przesunięcia
	
	j processChar
	
processChar:            		# Obsługa znaku
    	lb $t2, 0($t1)        	# Wczytanie obecnego znaku
    	beqz $t2, printOutput
    
    	beq $t2, ' ', nextCharacter    	# Spacja - zapisz i przejdź do następnego
    
    	blt $t2, 'A', checkLowerCase    # Sprawdzanie, czy obecny znak mieści się w zakresie 65 <= x <= 90, jeśli nie - sprawdzenie czy jest to mała litera
    	bgt $t2, 'Z', checkLowerCase    	
    
    	j convertCharacter	# Jeśli się mieści, przejście do konwertowania znaku

checkLowerCase:
    	blt $t2, 'a', nextCharacter   	# Sprawdzenie, czy wprowadzony znak mieści się w zakresie 97 <= x <= 122, jeśli nie - przejście do następnego znaku
    	bgt $t2, 'z', nextCharacter    	
    
    	subi $t2, $t2, 32    	# Jeśli się mieści, konwertowanie małej litery na wielką
    
convertCharacter:
    	add $t2, $t2, $s0    	# Przesunięcie znaku
    
   	blt $t2, 'A', adjustIfLow    	# Sprawdzenie, czy obecny znak mieści się w przedziale 65 <= x <= 90, jeśli nie - dostosowanie znaku
    	bgt $t2, 'Z', adjustIfHigh    	
    
    	j nextCharacter		# Jeśli się mieści, przejście do nas†epnego znaku

nextCharacter:			# Zapisanie znaku i przejście do następnego
	sb $t2, 0($t1)
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	
	j processChar
	
adjustIfLow:			# Dostosowanie, jeśli wartość kodu ASCII przekracza docelowy zakres od dołu
	addi $t2, $t2, 26
	
	j nextCharacter	
	
adjustIfHigh:			# Dostosowanie, jeśli wartość kodu ASCII przekracza docelowy zakres od góry
	subi $t2, $t2, 26
	
	j nextCharacter	
	
invalidOp:			# Niewłaściwa operacja
	li $v0, 4
	la $a0, invalidOpMsg
	syscall
	
	j askForAnother
	
askForAnother:			# Pytanie o następną operację
	li $v0, 4
	la $a0, anotherOp
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0
	
	beqz $t0, exit		# Jeśli 0 - koniec programu
	beq $t0, 1, main	# Jeśli 1 - powrót do main
	
	blt $t0, 0, invalidOp	# Sprawdzenie, czy podany numer operacji mieści się w dostępnym zakresie
	bgt $t0, 1, invalidOp
	
	j askForAnother
	
exit:			# Wyjście z programu
	li $v0, 4
	la $a0, endMsg
	syscall
	
	li $v0, 10
	syscall
	
			# KONIEC PROGRAMU
