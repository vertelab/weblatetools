# Vertel Translation
1. Loopa igenom alla projekt >> alla moduler.
2. Skapa .po fil
3. Kontrollera och jämför, kasta de som är okej och inte behöver åtgärd eller uppmärksamhet.
4. Logga med tid för respektive installation.
5. installera Screen för att köra över natten, utan att loopen tröttnar när Terminalen tröttnar. 


# Installera screen om det saknas
```
sudo apt install screen
```

# Starta en ny screen-session
```
screen -S vertel_translate
```
# Kör ditt skript INOM screen
```
jakob@odooutv18:/usr/share/vertel-translate$ sudo chmod +x vertel_translate
jakob@odooutv18:/usr/share/vertel-translate$ sudo ./vertel_translate
```

# Tryck Ctrl+A, sedan D för att "detach" (lämna sessionen)

# Tips från coachen
Screen är bäst för dig eftersom du får se realtids-output (Processing...) och kan kontrollera framstegen när du loggar in igen. Kör DRY_RUN = False och testa!
