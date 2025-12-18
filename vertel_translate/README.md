



# Installera screen om det saknas
sudo apt install screen

# Starta en ny screen-session
screen -S vertel_translate

# Kör ditt skript INOM screen
sudo ./vertel_translate

# Tryck Ctrl+A, sedan D för att "detach" (lämna sessionen)

# Tips från coachen
Screen är bäst för dig eftersom du får se realtids-output (Processing...) och kan kontrollera framstegen när du loggar in igen. Kör DRY_RUN = False och testa!
