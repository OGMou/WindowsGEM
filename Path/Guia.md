### Añadir una ruta al PATH del sistema directamente en NTLite si usar archivos externos.
  - Post-Setup
    - Before Logon
      - ADD Command
        - SET Command
          ```
          setx
          ```
        - SET Parameters
          ```
          /M PATH "%PATH%;C:\PATH\TO\ADD"
          ```
###### Cambiando `C:\PATH\TO\ADD` por la ruta que quieres que se añada
---
### Explicacion del de la tarea
  - `setx`
    - Nombre del programa ejecutable (setx.exe). Establece variables de forma permanente en el entorno del usuario o del sistema. A diferencia del comando `set` que solo afecta a la sesión actual del `símbolo del sistema`, los cambios hechos con setx persisten después de reiniciar.
    - Contexto: Guarda los valores en el Registro de Windows.
  - `/M`
    - Modificador que indica que, la variable de entorno debe establecerse en el ámbito del Sistema (Machine/Máquina).
    - Alternativa omitiendolo, establecerá la variable en el ámbito del Usuario actual.
  - `PATH`
    - Nombre de la variable que se va a modificar.
  - `"..."`
    - Valor que se asignará a la variable `PATH`. Importante las `"` ya que envuelven todo el valor para asegurar que se interprete como una única cadena de texto.
  - `%PATH%`
    - Expande el valor actual de la variable `PATH` en el momento en que se ejecuta el comando. CRICIAL para añadir una ruta sin borrar las existentes.
  - `;`
    - Separador estándar utilizado en la variable PATH de Windows para distinguir entre diferentes directorios en la lista
  - `C:\PATH\TO\ADD`
    - Ruta que quieres añadir al `PATH`
---
###### Actualizado a 02/05/2025
