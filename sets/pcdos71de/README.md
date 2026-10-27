# PC-DOS 7.1 Deutsch

Dieser Satz kombiniert die deutschen Programme von PC-DOS 2000 mit
IBMBIO.COM und IBMDOS.COM aus IBMs ServerGuide Scripting Toolkit DOS
Edition 1.3.07. Es werden keine IBM-Binärdateien im Git-Repository abgelegt.
Die Download-Adressen und SHA-256-Prüfsummen stehen in `downloads.txt`.

```powershell
./mkdosset.ps1 -Set pcdos71de -Download -Out ./out/pcdos71de
./mkdosset.ps1 -Set pcdos71de -Source ./meine-medien -Out ./out/pcdos71de
./mkdosset.ps1 -Set pcdos71de -Download -Out ./out/pcdos71de -Iso -Extra AHCIASPI.IMG
./mkdosset.ps1 -Set pcdos71de -List
```

Zusätzlich zu PowerShell und 7-Zip werden NASM und zum Entpacken der
IBM-FTCOMP-Archive DOSBox benötigt (`nasm` und `dosbox` auf PATH).
Bereits mit UNPACK2 entpackte Programme können ebenfalls als Quelle dienen;
dann ist DOSBox nicht nötig. Die entpackten Dateien bleiben im Cache.
Die Bootdiskette der Originalmedien liefert auch `BOOTSECT.BIN`; bei einer
Quelle aus einzelnen Dateien muss dieser 512-Byte-Bootsektor daneben liegen.

Als Originalmedien werden die sieben deutschen PC-DOS-2000-Disketten
(WinWorld-Archiv, 8.236.565 Bytes) und
`ibm_sw_sgtk_1_3_07_anyos_anycpu.zip` (13.548.460 Bytes) verwendet.
Das Toolkit-ZIP darf unverändert in `-Source` liegen. Es sind keine
Windows-CDs und keine Microsoft-DOS-Dateien nötig.

## Installation

`INSTALL.INI` folgt dem Ablauf des MS-DOS-Satzes: FDISK bei fehlendem C:,
Neustart, FORMAT bei unformatiertem C:, Systemübertragung, Dateien und
Startkonfiguration. Die Partitionierung wird nicht unbeaufsichtigt ausgeführt.

| Programm | Aufgabe |
|---|---|
| `FDISK.COM` | Deutsche Menüoberfläche für IBM FDISK32, freie Eingabe der Größe in MB, Statusanzeige und Auswahl der Festplatte. Änderungen führt IBM FDISK32 aus. |
| `FDISK32.COM` | IBM-Partitionswerkzeug aus dem Toolkit; selbst ohne Vollbildmenü. |
| `FDISK16.COM` | Originales deutsches PC-DOS-2000-FDISK mit seiner Oberfläche; ohne FAT32-Unterstützung. |
| `FORMAT.COM` | Wählt für C: nach Partitionstyp FORMAT16 oder FORMAT32; A:/B: verwenden FORMAT16. |
| `FORMAT16.COM` | Originales deutsches PC-DOS-2000-FORMAT. Der Aufruf über FORMAT.COM passt unter 7.1 die alten absoluten Sektorzugriffe an. |
| `FORMAT32.COM` | FAT32-Formatierer aus dem Toolkit; `/Q` ist bei dieser IBM-Version erforderlich. |
| `SYS.COM` | Deutsches IBM-SYS mit angepassten Versionsprüfungen, für FAT12/FAT16. |
| `SYS32.COM` | Systemübertragung ohne Formatierung; FAT32 direkt, FAT16 über SYS mit angepassten Sektorzugriffen. |

Der automatisierte Setup-Ablauf und die FORMAT/SYS-Helfer unterstützen C:
auf der ersten primären DOS-Partition der ersten BIOS-Festplatte. Die
FAT32-Helfer benötigen einen 386 und BIOS-LBA-Unterstützung. Vor dem
Systemtransfer wird die Zuordnung anhand der DOS-Datenträgernummer geprüft.
Das FDISK-Menü kann weitere BIOS-Festplatten bearbeiten; deren Installation
ist vom Setup-Helfer nicht abgedeckt. Es ist eine BIOS/CSM-Installation.

FORMAT16 funktioniert mit dem unveränderten Toolkit-Kern nicht direkt:
seine alten INT-25/26-Zugriffe schlagen fehl. FORMAT.COM installiert für
den FAT16-Aufruf vorübergehend einen Adapter für C:, der diese Zugriffe
auf BIOS-LBA abbildet; anschließend werden die Vektoren wiederhergestellt.
SYS32 benutzt denselben Adapter beim FAT16-Transfer mit dem IBM-SYS.
FAT32 wird dabei nicht neu formatiert; vorhandene Dateien bleiben erhalten.

Für die CD ist SHSUCDX aus dem AHCIASPI-Zusatzpaket erforderlich. Das alte
IBM-MSCDEX hängt in den Tests beim tatsächlichen Laden unter 7.1, obwohl
seine Hilfe funktioniert. Deshalb wird es nicht in diesen Satz aufgenommen.
`mkdosiso.ps1` bevorzugt SHSUCDX aus `-Extra`; MS-DOS-Sätze können weiterhin
MSCDEX verwenden. Die CD-Treiber kommen wie beim MS-DOS-Satz aus AHCIASPI
und OpenASPI oder aus `-CdDriver`.

## Deutsche Programme und Patches

COMMAND.COM, Tastatur, Ländereinstellungen, Editor E, Hilfe, DOSSHELL,
REXX und die Dienstprogramme stammen aus der deutschen Ausgabe. HIMEM,
EMM386 und der IBM-Maustreiber bleiben die deutschen Originale.
Der Maustreiber wurde mit PS/2-Erkennung und tatsächlicher Bewegung unter
SeaBIOS geprüft; er verwendet bereits 3-Byte-Pakete und braucht keinen
PS/2-Patch. `SET MOUSE=A:\NOINI` verhindert Schreibversuche seiner
Konfigurationsdatei auf der schreibgeschützten Boot-CD.

Die Versionssperren von COMMAND, APPEND und SYS werden für den
7.1-Kern angepasst. SYS wird vorher aus PKLITE entpackt; der Decoder
prüft die exakte Quelldatei und Ausgabegröße. APPENDs Patch verändert
zwei Literalbytes im gepackten Programm; die entpackte Ausgabe wurde
auf genau diese beiden Änderungen geprüft.

Die englischen Meldungen von IBMBIO, IBMDOS, FDISK32 und FORMAT32 werden
mit `messages-de.tsv` übersetzt, anhand der deutschen IBM-Terminologie.
Wo der Textplatz kürzer ist, sind die Formulierungen gekürzt. Die
Meldungslängen, Abschlusszeichen und Adressen bleiben erhalten. Ein
abweichender Patchfund bricht den Build ab. In den Boot-Einzelschrittfragen
bleibt die Taste Y für Ja erhalten; die Texte weisen darauf hin.

DEFRAG, SMARTDRV, UNFORMAT, UNDELETE, DATAMON und das alte CHKDSK werden
wegen ihrer nicht nachgewiesenen FAT32-Verträglichkeit nicht installiert.
Die Dateilisten stehen in `set.psd1` und erscheinen mit `-List`.
Tests und ihre Grenzen sind in [TESTED.md](TESTED.md) dokumentiert.

SHARE aus PC-DOS 2000 wurde ebenfalls geprüft. Nach Anpassung seiner
Versionssperre lädt es, hängt aber bei nachfolgenden Dateizugriffen, auch
mit `/NOHMA`. Es ist deshalb nicht im Satz enthalten; Dateisperren und
Anwendungen, die ein externes SHARE verlangen, sind damit nicht zugesichert.
