# 	ZADANIE 3 - GENERATOR LICZB LOSOWYCH

# 	Rejestry tymczasowe:
# 	$t0 - ilość ciągów do wygenerowania
# 	$t1 - ilość znaków w ciągu
#	$t2 - znak nowej linii
#
#	Rejestry zapisane:
#	$s0 - początek bufora
#
#	Informacje:
#	- generowane ciągi składają się tylko ze znaków alfanumerycznych, bez znaków diakretycznych

.data

header: .asciiz "\n======== GENERATOR CIAGOW ZNAKOW ALFANUMERYCZNYCH ========"
exitMsg: .asciiz "\nKonczenie pracy programu..."
info: .asciiz "\nDziesiec dziesieccioznakowych ciagow:"
newline: .asciiz "\n"

buffer: .space 110

.text

main:
	li $v0, 4		# Wypisanie wiadomości powitalnej
	la $a0, header
	syscall
	
	la $s0, buffer		# Wskaźnik na początek bufora
	
	li $t0, 10		# Ilość ciągów do wygenerowania
	
generateSequence:
	li $t1, 10		# Ilość znaków w ciągu	
	
generateChar:	
	li $v0, 42		# Generowanie losowej liczby
	li $a0, 1
	li $a1, 62		# Całkowity zakres znaków to 62, bo 10 (cyfr) + 26 * 2 (małe + wielkie litery) = 62
	syscall
	
	blt $a0, 10, isDigit	# Sprawdzenie, czy znak powinien być cyfrą
	
	subi $a0, $a0, 10
	blt $a0, 26, isUppercase	# Sprawdzenie, czy znak powinien być wielką literą
	
	subi $a0, $a0, 26
	addi $a0, $a0, 97	# Jeśli nie jest ani cyfrą, ani wielką literą, powinien być małą literą
	
	j saveChar

isDigit:			# Jeśli ma to być cyfra, konwertuj na znak ASCII
	addi $a0, $a0, 48
	
	j saveChar
			
isUppercase:			# Jeśli ma to być wielka litera, konwertuj na znak ASCII
	addi $a0, $a0, 65
	
	j saveChar							
			
saveChar:
	sb $a0, 0($s0)		# Zapisywanie znaku w buforze
	addi $s0, $s0, 1
	
	subi $t1, $t1, 1	# Dekrementacja licznika znaków
	
	bnez $t1, generateChar	# Jeśli licznik znaków != 0 -> generuj kolejny znak 
	
    	li $t2, '\n'       	# Dodanie nowej linii na koniec ciągu
	sb $t2, 0($s0)
    	
    	addi $s0, $s0, 1
	
	subi $t0, $t0, 1	# Dekrementacja licznika ciągów
	
	bnez $t0, generateSequence	# Jeśli licznik ciągów != 0 -> generuj kolejny ciąg	
	
printOutput:
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 4		# Właściwe wyświetlanie zawartości bufora
	la $a0, buffer
	syscall	
	
exit:			# Wyjście z programu
	li $v0, 4
	la $a0, exitMsg
	syscall
	
	li $v0, 10
	syscall	
			
			# KONIEC PROGRAMU
