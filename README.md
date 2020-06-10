# Turingmaschine auf 8051

Dies ist ein Projekt im Rahmen des Moduls `Systemnahe Programmierung` des Studiengangs Informatik an der DHBW Karlsruhe.

## Datenspezifikation

### Kodierung der Zeichen

- 00: 0
- 01: 1
- 10: 2
- 11: B(lank)

### Kodierung der Richtung

- 0: Links
- 1: Rechts

### Kodierung eines Tabelleneintrages

- 1 Byte pro Zelle
- Bit 1  : links oder rechts
- Bit 2-3: zu schreibendes Zeichen
- Bit 4-8: neuer Zustand

D.h.:

```
Bit      | 0        | 1  | 2  | 3 | 4 | 5 | 6 | 7 |
Funktion | Richtung | Zeichen |   Neuer Zustand   |
```

### Speichern der Turing Tabelle

```
         |            Zeichen                |
 Zustand |   00   |   01   |   10   |   11   |
---------+--------+--------+--------+--------|
  00000  |00000000|00000000|00000000|00000000|
  00001  | ... 
  00010  |
  00011  |
  00100  |
  .....  |
  11111  |
```

- 4 Zeichen (2 Bit) * 32 (5 Bit) Zustände = 128 Byte Speicherbedarf
- Ablegung im internen Speicher
- Adresse: `offset + Zustandsnummer * Anzahl Zeichen + Zeichennummer`

## Ablauf

1. Initialisieren
 	- Lesen der Turingtabelle
 	- (Löschen/Vorbereiten des Turingbands)
 	- Initialen Zustand und Zeiger auf dem Turingband setzen
2. Schritt
 	- Lesen der Eingabe vom Turingband
 	- Aktion aus der Tabelle lesen
 	- Zeichen schreiben
 	- Turingbandzeiger verschieben
 	- Zustandswechsel
 	- Wiederholen
3. Ausgabe
 	- Lesen der nächsten Zeichen vom Turingband
 	- Ausgabe der Zeichen im LCD Display

