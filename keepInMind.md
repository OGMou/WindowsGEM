## Lista de "Accion/Consecuencia" para tener en cuenta
- **Problema/Solucion**
###### A la hora de abrir un archivo con una app usando el registro de windows o regedit, este NO va a usar el path, por lo cual, el comando `@="\"Programa.exe\" \"%1\""` NO va a funcionar, si a esto le creaste un archivo "DefaultAssociations.xml" para asociar las apps de manera predeterminada durante la instalacion de windows usando el comando DISM, cuando trates de abrir un archivo, este entrara en bucle con la accion de "abrir con", para resolverlo TENDRAS QUE USAR LA `RUTA ABSOLUTA`, por ejemplo `@="\"C:\Ruta\Completa\Al\Programa.exe\" \"%1\""`.
- **Alternativa, uso del "PATH"**
###### La solucion, si verdaderamente quieres usar el PATH, es usar un intermediario como `cmd` o `powershell` para abrir el programa en concreto, entonces el comando seria `@="cmd.exe /c start \"\" \"NombrePrograma.exe\" \"%1\""` o respectivamente `@="\"powershell.exe\" -NoProfile -Command \"Start-Process 'NombrePrograma.exe' -ArgumentList \\\"%1\\\"\""` aunque usando `powershell` puedes tener problemas a la hora de crear un comando mas complejo por culpa del `escapado` de las `"` o las `\`.
---
Actualizado a 02/05/2025
