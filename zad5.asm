#	ZADANIE 5 - KÓŁKO I KRZYŻYK
#
#	Rejestry zapisane:
#	$s0 - wskaźnik aktualnej pozycji na planszy
#	$s1 - pomocniczy wskaźnik pozycji na planszy
#	$s2 - wartość ruchu gracza
#	$s3 - wskaźnik kolejki
#	$s4 - licznik ruchów
#	$s5 - wskaźnik przesunięcia (kolumny/rzędu) / (wartość pomocnicza przy przechodzeniu planszy podczas sprawdzania wygranej)
#	$s6 - id rozgrywającego ostatnią rundę
#	$s7 - licznik rund (odwrócony)
#
#	Rejestry tymczasowe:
#	$t0 - ostatnia wartość rejestru powrotu
#	$t6 - licznik wygranych gracza
#	$t7 - licznik wygranych komputera
#	$t8 - licznik remisów
#	$t9 - licznik rund

.data

welcomeMsg: .asciiz "\n========= KOLKO I KRZYZYK ========="
exitMsg: .asciiz "\nWychodzenie z gry..."
playerWinMsg: .asciiz "\nGracz wygral!\n"
cpuWinMsg: .asciiz "\nKomputer wygral!\n"
drawMsg: .asciiz "\nRemis!\n"
resultMsg: .asciiz "\nWynik gry: "
askForInputMsg: .asciiz "\nWprowadz ruch (1-9): "
roundNumMsg: .asciiz "\nNumer rundy: "
askForRoundsMsg: .asciiz "\nIlosc rund do rozegrania (1-5): "
invalidInputMsg: .asciiz "\nWprowadzono nieprawidlowa ilosc rund.\n"
invalidMoveMsg: .asciiz "\nBrak dostepnego miejsca na planszy.\n"
playerSymbolMsg: .asciiz "\nSymbol gracza: O"
cpuSymbolMsg: .asciiz "\nSymbol komputera: X"
boardMsg: .asciiz "\nPlansza wraz z indeksami pól:\n"
roundMsg: .asciiz "\nRunda: "
turnMsg: .asciiz "\n\nKolej: "
player: .asciiz "Gracz\n"
cpu: .asciiz "Komputer\n"
draws: .asciiz "\nRemisy: "
playerWins: .asciiz "\nGracz: "
cpuWins: .asciiz "\nKomputer: "
sumUp: .asciiz "\n\nPodsumowujac: "

newline: .asciiz "\n"
space: .asciiz " "

row1: .asciiz "1|2|3"
row2: .asciiz "4|5|6"
row3: .asciiz "7|8|9"

board: .space 9

.text

# -- Procedury startowe --------------------------------------------------------------------------------------------------------------------------------------------

main:
	li $v0, 4		# Wyświetlenie wiadomości powitalnej
	la $a0, welcomeMsg
	syscall
	
	addi $t9, $t9, 1	# Ustawienie wartości licznika rund na 1
	
	jal askForRounds	# Zapytanie o ilość rund
	
continueGame:			# Punkt kontynuowania rozgrywki w przypadku wystąpienia więcej niż jednej rundy
	jal roundNumberInfo	# Wyświetlenie informacji o aktualnej rundzie

	li $v0, 4		# Informacja o wyświetlaniu planszy
	la $a0, boardMsg
	syscall
	
	jal printBoardIds	# Wyświetlenie planszy z indeksami
	
	li $v0, 4		# Wyświetlanie informacji o symbolu gracza
	la $a0, playerSymbolMsg
	syscall
	
	li $v0, 4		# Wyświetlanie informacji o symbolu komputera
	la $a0, cpuSymbolMsg
	syscall
	
	jal printNewline	
	j manageTurn		# Przejście do kolejnej rundy
	
# -- Procedury do zarządzania rundami ------------------------------------------------------------------------------------------------------------------------------	
	
manageTurn:
	beq $s4, 9, draw	# Jeśli po 9 wykonanych ruchach nie ma wygranej -> jest remis
	
	li $v0, 4		# Wyświetlenie wiadomości o tym, czyja teraaz jest kolej
	la $a0, turnMsg
	syscall
	
	beq $s3, 1, playerTurn	# Sprawdzenie, czy jest kolej gracza
	beq $s3, 2, cpuTurn	# Sprawdzenie, czy jest kolej komputera
	
playerTurn:			# Obsługa kolejki gracza
	li $v0, 4
	la $a0, player
	syscall

	j playRound 
	
cpuTurn:			# Obsługa kolejki komputera
	li $v0, 4
	la $a0, cpu
	syscall
	
	jal cpuMove
	j saveInput
	
playRound:			# Główne zarządzanie rozgrywką
	jal askForInput		# Prośba o wprowadzenie ruchu
	jal checkInput		# Weryfikacja poprawności ruchu
	j saveInput		# Zapisanie wartości ruchu
	
# -- Procedury do wyświetlania planszy gry -------------------------------------------------------------------------------------------------------------------------	
	
displayBoardStart:		# Rozpocznij wyświetlanie planszy
	li $s0, 0		# Ustawienie wskaźnika aktualnej pozycji na początek planszy
	li $s1, 0		# Ustawienie pomocniczego wskaźnika na początek planszy
	
	j displayLine		# Przejście do wyświetlania nowej linii
	
displayLine:			# Wyświetlanie aktualnego rzędu planszy
	addi $s1, $s1, 3	# Inkrementacja pomocniczego wskaźnika, w celu wyznaczenia końca rzędu
	
	jal printNewline
	
	j displayBoard		# Przejście do właściwego wyświetlania planszy
	
displayBoard:			# Właściwe wyświetlanie planszy
	beq $s0, 9, lookForWin	# Sprawdź, czy nastąpiła wygrana po wyświetleniu wszyskich miejsc w planszy
	beq $s0, $s1, displayLine	# Sprawdź, czy przejść do następnej linii
	
	move $t2, $s0		# Ustawienie wskaźnika miejsca na planszy
	la $t1, board		# Wczytanie aktualnego adresu planszy
	add $t1, $t1, $t2	# Przesunięcie aktualnego adresu planszy do wartości wskaźnika miejsca 
	lb $t3, 0($t1)		# Wczytanie aktualnego znaku z planszy do rejestru $t3, który zostanie poddany analizie
	
	beq $t3, 0, displayEmptySlot 	# Sprawdzenie, jaki znak należy wyświetlić na planszy
	beq $t3, 1, displayO
	beq $t3, 2, displayX
	
displayEmptySlot:		# Wyświetlanie symbolu pustego miejsca na planszy
	li $v0, 11
	li $a0, 45 		# Kod ASCII dla '-'
	syscall
	
	j addBorder
	
displayO:			# Wyświetlanie znaku 'O' na planszy
	li $v0, 11		
	li $a0, 79 		# Kod ASCII dla 'O'
	syscall
	
	j addBorder
	
displayX:			# Wyświetlanie znaku 'X' na planszy
	li $v0, 11
	li $a0, 88 		# Kod ASCII dla 'X'
	syscall
	
	j addBorder	
	
# -- Procedury do obsługi ruchu komputera --------------------------------------------------------------------------------------------------------------------------			
	
cpuMove:			# Obsługa ruchu komputera - wyszukuje on pierwsze wolne miejsce na planszy i zapełnia je (pola posortowane rosnąco wg. indeksów)
	li $t0, 0		# Ustawienie wskaźnika miejsca na planszy na sam jej początek
	
findEmptySlot:			# Wyszukiwanie wolnego miejsca
	la $t1, board		# Wczytanie aktualnego adresu planszy
	add $t1, $t1, $t0	# Inkrementacja/inicjalizacja wskaźnika akutalnego miejsca na planszy
	lb $t2, 0($t1)		# Wczytanie do rejestru $t2 wartości aktualnego miejsca na planszy
	
	beqz $t2, foundEmptySlot	# Sprawdzenie, czy znaleziono puste miejsce
	
	addi $t0, $t0, 1	# Inkrementacja wskaźnika miejsca na planszy
		
	blt $t0, 9, findEmptySlot	# Jeśli wskaźnik miejsca na planszy nie doszedł do jej końca (nie przekroczył maksymalnej wartości 9)
	
	jr $ra
	
foundEmptySlot:			# Obsługa znalezionego wolnego miejsca
	move $s2, $t0		# Zapisanie wartości znalezionego miejsca na planszy do rejestru $s2 (ustawienie jako wartości ruchu komputera)
	
	jr $ra	
	
# -- Procedury do zapisywania wartości ruchu w planszy -------------------------------------------------------------------------------------------------------------
saveInput:
	addi $s4, $s4, 1	# Inkrementacja licznika ruchów
	
	beq $s3, 1, saveO	# Sprawdzenie, czy jest kolej gracza, czy komputera
	beq $s3, 2, saveX	
	
saveO:
	la $t1, board		# Wczytanie aktualnego adresu planszy
	add $t1, $t1, $s2	# Przesunięcie adresu planszy na ten wskazany przez wprowadzony ruch
	li $t2, 1		# Ustawienie wskaźnika wartości miejsca na 1 (id gracza)
	sb $t2, 0($t1)		# Zapisanie wartości rejestru $t2 (id gracza) na odpowiednim miejscu planszy
	li $s3, 2		# Zmiana na kolej komputera
	
	j displayBoardStart	# Wyświetlenie planszy
	
saveX:
	la $t1, board		# Wczytanie aktualnego adresu planszy
	add $t1, $t1, $s2	# Przesunięcie adresu planszy na ten wskazany przez wprowadzony ruch
	li $t2, 2		# Ustawienie wskaźnika wartości miejsca na 2 (id komputera)
	sb $t2, 0($t1)		# Zapisanie wartości rejestru $t2 (id komputera) na odpowiednim miejscu planszy
	li $s3, 1		# Zmiana na kolej gracza
	
	j displayBoardStart	# Wyświetlenie planszy
	
# -- Procedury do obsługi wygranej ---------------------------------------------------------------------------------------------------------------------------------	
			
lookForWin:			# Rozpoczęcie wyszukiwania wygranej
	bge $s4, 5, condition1	# Jeśli licznik ruchów >= 5 -> przejdź do sprawdzania warunków
	
	j manageTurn		# W przeciwnym wypadku -> przejdź do kolejnej rundy bez sprawdzania 	
	
condition1:			# Sprawdzenie przekątnej 1-5-9
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 0		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (pierwsze miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 4	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 4	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition2	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 2
	bne $t3, $t4, condition2	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 2
	beqz $t2, condition2	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 2
	
	j manageWin 		# Przejście do zarządzania wygraną
	
condition2:			# Sprawdzenie przekątnej 3-5-7
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 2		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (trzecie miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 2	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 2	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition3	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 3
	bne $t3, $t4, condition3	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 3
	beqz $t2, condition3	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 3
	
	j manageWin		# Przejście do zarządzania wygraną
	
condition3:			# Sprawdzanie pierwszej kolumny
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 0		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (pierwsze miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition4	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 4
	bne $t3, $t4, condition4	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 4
	beqz $t2, condition4	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 4
	
	j manageWin 		# Przejście do zarządzania wygraną
	
condition4:			# Sprawdzenie drugiej kolumny
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 1		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (drugie miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition5	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 5
	bne $t3, $t4, condition5	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 5
	beqz $t2, condition5	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 5
	
	j manageWin 		# Przejście do zarządzania wygraną
	
condition5:			# Sprawdzenie trzeciej kolumny
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 2		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (trzecie miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 3	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition6	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 6
	bne $t3, $t4, condition6	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 6
	beqz $t2, condition6	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 6
	
	j manageWin		# Przejście do zarządzania wygraną
	
condition6:			# Sprawdzanie pierwszego rzędu
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 0		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy 
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (pierwsze miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition7	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 7
	bne $t3, $t4, condition7	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 7
	beqz $t2, condition7	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 7
	
	j manageWin 		# Przejście do zarządzania wygraną
	
condition7:			# Sprawdzenie drugiego rzędu
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 3		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (czwarte miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, condition8	# Jeśli wartość (1) nie jest równa wartości (2) -> sprawdź warunek 8
	bne $t3, $t4, condition8	# Jeśli wartość (2) nie jest równa wartości (3) -> sprawdź warunek 8
	beqz $t2, condition8	# Jeśli wartość (1) jest równa zero (miejsce puste) -> sprawdź warunek 8
	
	j manageWin 		# Przejście do zarządzania wygraną
		
condition8:			# Sprawdzenie trzeciego rzędu
	li $s6, 0		# Ustawienie wartości id rozgrywającego ostatnią rundę na neutralną (0)
	li $s5, 6		# Ustawienie wskaźnika przesunięcia (kolumny/rzędu)
	la $t1, board		# Wczytanie aktualnego adresu planszy
	
	add $t1, $t1, $s5	# Przesunięcie wskaźnika miejsca na planszy na odpowiednią wartość startową (siódme miejsce)
	lb $t2, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (1)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t3, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (2)
	
	addi $t1, $t1, 1	# Inkrementacja wskaźnika
	lb $t4, 0($t1)		# Wczytanie aktualnej wartości miejsca na planszy wskazanej przez wskaźnik (3)
	
	add $s6, $s6, $t2	# Aktualizacja id gracza
	
	bne $t2, $t3, manageTurn	# Jeśli wartość (1) nie jest równa wartości (2) -> przejdź do zarządzania rundą
	bne $t3, $t4, manageTurn	# Jeśli wartość (2) nie jest równa wartości (3) -> przejdź do zarządzania rundą
	beqz $t2, manageTurn	# Jeśli wartość (1) jest równa zero (miejsce puste) -> przejdź do zarządzania rundą
	
	j manageWin		# Przejście do zarządzania wygraną
																																					
# -- Procedury do wyświetlania stałych elementów -------------------------------------------------------------------------------------------------------------------	
	
printBoardIds:			# Wyświetlanie planszy
	move $t0, $ra		# Zapisanie rejestru powrotu 

	li $v0, 4		# Wyświetlenie pierwszego rzędu
	la $a0, row1
	syscall
	
	jal printNewline
	
	li $v0, 4		# Wyświetlenie drugiego rzędu
	la $a0, row2
	syscall
	
	jal printNewline
	
	li $v0, 4		# Wyświetlenie trzeciego rzędu
	la $a0, row3
	syscall
	
	jal printNewline
	
	jr $t0	
	
printNewline:			# Wyświetlanie znaku nowej linii
	li $v0, 4
	la $a0, newline
	syscall
	
	jr $ra	
	
addBar:			# Wyświetlanie kreski na planszy
	li $v0, 11
	li $a0, 124		# Kod ASCII dla '|'
	syscall	
	
	jr $ra 
	
addBorder:			# Dodawanie wewnętrznej krawędzi planszy
	addi $s0, $s0, 1	# Inkrementacja wskaźnika miejsca na planszy
	bne $s0, $s1, addBar	# Wyświetlenie kreski ('|')
	j displayBoard		# Przejście do właściwego wyświetlania planszy		
	
# -- Procedury do określania wygranej ------------------------------------------------------------------------------------------------------------------------------	
	
manageWin:			# Obsługa wygranej
	beq $s6, 1, playerWin	# Sprawdzenie, czy wygrał gracz, czy komputer
	beq $s6, 2, cpuWin	
	
playerWin:			# Obsługa wyświetlania wygranej gracza
	li $v0, 4
	la $a0, playerWinMsg
	syscall
	
	addi $t6, $t6, 1	# Inkrementacja licznika wygranych gracza
	
	jal playerWinSound
	
	j checkRemainingRounds	# Sprawdzenie ilości pozostałych rund
	
cpuWin:			# Obsługa wyświetlania wygranej komputera
	li $v0, 4
	la $a0, cpuWinMsg
	syscall
	
	addi $t7, $t7, 1	# Inkrementacja licznika wygranych komputera	
	
	jal cpuWinSound
	
	j checkRemainingRounds	# Sprawdzenie ilości pozostałych rund
	
draw:			# Obsługa wyświetlania remisu
	li $v0, 4
	la $a0, drawMsg
	syscall	
	
	addi $t8, $t8, 1	# Inkrementacja licznika remisów
	
	jal drawSound
	
	j checkRemainingRounds	# Sprawdzenie ilości pozostałych rund	
	
displayResults:			# Wyświetlanie wyników rozgrywki
	li $v0, 4
	la $a0, resultMsg
	syscall
	
	li $v0, 4		# Wyświetlanie liczby wygranych gracza
	la $a0, playerWins
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	li $v0, 4		# Wyświetlanie liczby wygranych komputera
	la $a0, cpuWins
	syscall
	
	li $v0, 1
	move $a0, $t7
	syscall
	
	li $v0, 4		# Wyświetlanie liczby remisów
	la $a0, draws
	syscall
	
	li $v0, 1
	move $a0, $t8
	syscall
	
	li $v0, 4		# Wyświetlenie końcowego wyniku rozgrywki
	la $a0, sumUp
	syscall
	
	blt $t7, $t6, ultimatePlayerWin	# Sprawdzenie, czy wygrał gracz
	blt $t6, $t7, ultimateCpuWin	# Sprawdzenie, czy wygrał komputer
	
	j ultimateDraw		# W przeciwnym razie -> remis
	
ultimatePlayerWin:		# Wyświetlenie informacji o wygraniu meczu przez gracza
	li $v0, 4
	la $a0, playerWinMsg
	syscall
	
	jal playerWinSound
	
	j exit		# Zakończenie programu
	
ultimateCpuWin:			# Wyświetlenie informacji o wygraniu meczu przez komputer
	li $v0, 4
	la $a0, cpuWinMsg
	syscall
	
	jal cpuWinSound
	
	j exit		# Zakończenie programu
	
ultimateDraw:			# Wyświetlenie informacji o remisie w meczu
	li $v0, 4
	la $a0, drawMsg
	syscall
	
	jal drawSound
	
	j exit		# Zakończenie programu			
	
# -- Procedury pomocnicze ------------------------------------------------------------------------------------------------------------------------------------------	
	
exit:
	li $v0, 4		# Wyświetlenie wiadomości pożegnalnej
	la $a0, exitMsg
	syscall
	
	li $v0, 10		# Zakończenie działania programu
	syscall	
	
# -- Procedury pomocnicze do obsługi rund --------------------------------------------------------------------------------------------------------------------------	
	
askForRounds:
	li $v0, 4		# Zapytanie o ilość rozgrywanych rund
	la $a0, askForRoundsMsg
	syscall

	li $v0, 5		# Pobranie liczby rund z klawiatury
	syscall
	
	blt $v0, 1, invalidRoundsAmount # Sprawdzenie, czy wprowadzony licznik rund mieści się w odpowiednim zakresie
	bgt $v0, 5, invalidRoundsAmount
	
	move $s7, $v0		# Zapisanie licznika rund
    
	jr $ra
	
checkRemainingRounds:		# Obsługa licznika rund
	addi $s7, $s7, -1	# Dekrementacja licznika rund
	
	bnez $s7, resetBoard	# Jeśli pozostały jeszcze jakieś rundy -> zresetuj planszę
	
	j displayResults	# W przeciwnym wypadku przejdź do wyjścia z gry	
	
invalidRoundsAmount:		# Wyświetlanie informacji o wprowadzeniu nieprawidłowych wartości
	li $v0, 4
	la $a0, invalidInputMsg
	syscall
	
	j main  	
	
roundNumberInfo:		# Wyświetlanie informacji dotyczyących numeru rundy
	li $v0, 4
	la $a0, roundMsg
	syscall	
	
	li $v0, 1		# Wyświetlenie numeru rundy
	move $a0, $t9
	syscall
	
	jr $ra
	
# -- Procedury pomocnicze do obsługi wprowadzanej wartości ruchu ---------------------------------------------------------------------------------------------------	
	
askForInput:			# Prośba o wproadzenie ruchu przez gracza
	li $v0, 4
	la $a0, askForInputMsg
	syscall
	
	li $v0, 5		# Wczytanie wartości z klawiatury
	syscall
	
	move $s2, $v0		# Zapisanie wartości ruchu gracza
	addi $s2, $s2, -1	# Dostosowanie wprowadzonej wartości ruchu (odpowiednie przesunięcie, jak indeksy w tablicy)
	
	jr $ra	
	
checkInput:
	la $t1, board		# Wczytanie aktualnego adresu planszy
	add $t1, $t1, $s2	# Przesunięcie aktualnego adresu planszy do wartości wskaźnika miejsca 
	lb $t2, 0($t1)		# Wczytanie świeżo zapisanej wartości do rejestru $t2, którego zawartość zostanie poddana analizie
	
	bnez $t2, invalidInputValue	# Sprawdzenie, czy wprowadzona wartość mieści się w odpowiednim zakresie
	bge $s2, 9, invalidInputValue
	blt $s2, 0, invalidInputValue
	
	jr $ra		# Jeśli tak -> przejście dalej
	
invalidInputValue:		# Wyświetlanie informacji o wprowadzeniu nieprawidłowej wartości ruchu
	li $v0, 4
	la $a0, invalidMoveMsg
	syscall
	
	j manageTurn	
	
# -- Procedury pomocnicze do czyszczenia planszy -------------------------------------------------------------------------------------------------------------------			

resetBoard:			# Resetowanie planszy do gry na początku każdej rundy
	la $t0, board		# Wczytanie aktualnego adresu planszy
	li $t1, 0		# Ustawienie rejestru $t1 na wartość początku planszy
	li $t2, 9		# Ustawienie licznika powtórzeń pętli
	
	addi $t9, $t9, 1	# Inkrementacja licznika rund

resetLoop:
	sb $t1, 0($t0)		# Zapisanie wartości 0 (pustego miejsca) na początku adresu tablicy
	addi $t0, $t0, 1	# Inkrementacja wskaźnika adresu planszy
	addi $t2, $t2, -1	# Dekrementacja licznika powtórzeń pętli
	bnez $t2, resetLoop	# Jeśli licznik powtórzeń pętli jest inny od zero -> powtórz pętlę

	li $s3, 1		# Zmiana kolejki na gracza
	li $s4, 0		# Resetowanie licznika ruchów

	j continueGame		# Kontynuowanie gry
	
# -- Procedury pomocnicze do wydawania dźwieków --------------------------------------------------------------------------------------------------------------------

playerWinSound:			# Dźwięk dla wygranej gracza
	li $v0, 33
	li $a0, 82
	li $a1, 150
	li $a2, 30
	li $a3, 100
	
	syscall
	
	li $v0, 33
	li $a0, 84
	li $a1, 400
	li $a2, 30
	li $a3, 100
	
	syscall
	
	jr $ra	
	
cpuWinSound:			# Dźwięk dla wygranej komputera
	li $v0, 33
	li $a0, 82
	li $a1, 150
	li $a2, 30
	li $a3, 100
	
	syscall
	
	li $v0, 33
	li $a0, 80
	li $a1, 400
	li $a2, 30
	li $a3, 100
	
	syscall
	
	jr $ra	
	
drawSound:			# Dźwięk dla remisu
	li $v0, 33
	li $a0, 82
	li $a1, 150
	li $a2, 30
	li $a3, 100
	
	syscall
	
	li $v0, 33
	li $a0, 82
	li $a1, 400
	li $a2, 30
	li $a3, 100
	
	syscall
	
	jr $ra					
	
				# KONIEC PROGRAMU
