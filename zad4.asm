#	ZADANIE 4 - WYŚWIETLANIE CIĄGÓW ZNAKÓW Z WYKORZYSTANIEM STOSU
#
#	Rejestry tymczasowe:
#	$t0 - liczba ciągów do wprowadzenia
#	$t1 - wskaźnik na bufor
#	$t2 - aktualna wartość rejestru $sp (stackpointer)
#	$t3 - aktualny znak ciągu
#
#	Rejestry zapisane:
#	$s0 - początkowa wartość rejestru $sp (stackpointer)

.data

startMsg: .asciiz "\n\n=========== PROGRAM WYSWIETLAJACY PODANE CIAGI ==========="
endMsg: .asciiz "\nKonczenie pracy programu..."
askSequencesAmount: .asciiz "\nPodaj ilosc ciagow (1-10): "
maxSequencesAmountMsg: .asciiz "\nMaksymalna liczba ciagow to 10!"
minSequencesAmountMsg: .asciiz "\nMinimalna liczba ciagow to 1!"
askForSequence: .asciiz "\nPodaj ciag: "
outputMsg: .asciiz "\n\nPodane ciagi:\n"
newline: .asciiz "\n"
space: .asciiz " "

buffer: .space 100

.text

main:	
	li $v0, 4		# Wyświetlenie wiadomości powitalnej
	la $a0, startMsg
	syscall
	
	li $v0, 4		# Zapytanie o liczbę ciągów do wprowadzenia
	la $a0, askSequencesAmount
	syscall
	
	li $v0, 5		# Odczytanie i zapisanie liczby ciągów do wprowadzenia
	syscall
	move $t0, $v0
	
	blt $t0, 1, outOfBoundsLower	# Sprawdzenie, czy podana liczba ciągów mieści się w docelowym przedziale
	bgt $t0, 10, outOfBoundsHigher
	
	move $s0, $sp		# Zapisanie oryginalnego wskaźnika stosu
	
input:	
	beqz $t0, printOutput	# Jeśli licznik ciągów = 0 -> wyświetl ciągi
	
	li $v0, 4		# Zapytaj o ciąg
	la $a0, askForSequence
	syscall	
	
	li $v0, 8		# Wczytywanie ciągu
	la $a0, buffer
	li $a1, 100		# Maksymalna długość ciągu (100)
	syscall
	
	la $t1, buffer     	# Wskaźnik na bufor
	
	jal pushString
	
	subi $t0, $t0, 1	# Dekrementacja licznika ciągów
	
	j input

pushString:
	addi $sp, $sp, -100	# Obniżenie wskaźnika stosu
	move $t2, $sp		# Ustawienie $t2 jako aktualna wartość wskaźnika stosu

	copyLoop:
		lb $t3, 0($t1)		# Załadowanie aktualnego znaku
		
		beqz $t3, endCopy	# Jeśli znaleziono null terminator -> koniec kopiowania
		beq $t3, 32, newWord	# Jeśli aktualny znak to spacja (ASCII 32) -> nowy wyraz
		beq $t3, 10, skipNewline	# Jeśli aktualny znak to newline (ASCII 10) -> pomiń
		
		sb $t3, 0($t2)		# Zapisanie znaku do aktualnego poziomu stosu
		addi $t1, $t1, 1	# Inkrementacja wskaźnika bufora
		addi $t2, $t2, 1	# Inkrementacja wskaźnika stosu
		
		j copyLoop
		
	skipNewline:
       		addi $t1, $t1, 1   	# Pomijanie znaku nowej linii
        		j copyLoop	
		
	newWord:
		sb $zero, 0($t2)	# Dodanie null terminatora na koniec wyrazu
		addi $sp, $sp, -100	# Obniżenie wskaźnika stosu
		move $t2, $sp		# Ustawienie $t2 jako aktualną wartość wskaźnika stosu
		addi $t1, $t1, 1	# Pominięcie znaku spacji
		
		j copyLoop
    
	endCopy:
		sb $zero, 0($t2)	# Dodanie null terminatora na koniec ostatniego wyrazu
		
		jr $ra		# Powrót z pętli

startPrint:
	beq $sp, $s0, exit	# Jeśli wskaźnik stosu równy jest oryginalnej swojej wartości -> koniec
	
	move $t2, $sp		# Ustawienie $t2 jako tymczasowej zawartości danego poziomu stosu
	
	findNull:			# Znajdowanie końca łańcucha
		lb $t3, 0($t2)		# Załadowanie aktualnego znaku
		beqz $t3, popString	# Jeśli znaleziono null terminator -> koniec procedury
	
		addi $t2, $t2, 1	# Inkrementacja wskaźnika stosu
	
		j findNull

popString:			# Wyświetlanie aktualnego wyrazu
	li $v0, 4
	move $a0, $sp
	syscall
	
	li $v0, 4
	la $a0, space
	syscall
	
	addi $sp, $sp, 100	# Zwiększenie wskaźnika stosu o 100 bajtów (maksymalna długość ciągu)
	
	j startPrint									
	
outOfBoundsLower:		# Obsługa przypadku, gdy podana liczba ciągów jest mniejsza niż najniższa wartość z doeclowego zakresu
	li $v0, 4
	la $a0, minSequencesAmountMsg
	syscall
	
	j main
	
outOfBoundsHigher:		# Obsługa przypadku, gdy podana liczba ciągów jest większa niż najwyższa wartość z doeclowego zakresu
	li $v0, 4
	la $a0, maxSequencesAmountMsg
	syscall
	
	j main
	
printOutput:
	li $v0, 4		# Wyświetlenie wiadomości o podanych ciągach
	la $a0, outputMsg
	syscall
		
	j startPrint																														
			
exit:
	li $v0, 4		# Wyświetlenie wiadomości końcowej
	la $a0, endMsg
	syscall
	
	li $v0, 10		# Wyjście z programu
	syscall

			
				# KONIEC PROGRAMU
