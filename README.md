# Chia
Kleine Hilfsprogramme für Chia Farmer

Chia Plotmover

Dieses Skript kopiert die erstellten Plots von einem Quellpfad zu einem oder mehreren Zielpfad. 
Über '$maxParallelCopy' kann festgelegt werden wie viele Kopiervorgänge parallel starten dürfen (default = 10). 
Pro Ziellaufwerk wird immer nur 1 Kopiervorgang gestartet. 

Vor Kopiervorgang wird geprüft, ob im Zielpfad genügend Speicherplatz vorhanden ist. 
Sollte nicht genügend Speicherplatz vorhanden sein, wird der nächste Zielpaf geprüft.
