# Chia
Kleine Hilfsprogramme für Chia Farmer

Chia Plotmover

Dieses Skript kopiert die erstellten Plots von einem Quellpfad zu einem oder mehreren Zielpfad. 
Über '$maxProcessesPerDest' kann festgelegt werden wie viele Kopiervorgänge parallel pro Zielpfad starten dürfen (default = 1). 
Pro Ziellaufwerk wird immer nur 1 Kopiervorgang gestartet.

Vor Kopiervorgang wird geprüft, ob im Zielpfad genügend Speicherplatz vorhanden ist. 
Sollte nicht genügend Speicherplatz vorhanden sein, wird der nächste Zielpaf geprüft.

Das Script nutzt die 'move' Funktion von 'robocoy'. Für jeden Move-Prozess wird ein eigenes Fenster geöffnet. 
