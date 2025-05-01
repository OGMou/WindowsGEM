## Guia para crear un `DLL` de SOLO recursos con iconos
  - **DESCARGAR [Build Tools para Visual Studio](https://visualstudio.microsoft.com/es/downloads/)**.
    ###### Este enlace te lleva directamente a las descargas de VS pero el que necesitas esta mas abajo, en la seccion:
    - ##### Todas las descargas
      - ##### Herramientas para Visual Studio
        - ##### Build Tools para Visual Studio
  - **SELECCIONA `Desarrollo de escritorio con C++` / (`Desktop development with C++`) como workload**.
    ###### Esto en el momento de instalar el archivo descargado anteriormente
  - **CREAR una carpeta para contener todos los iconos**.
    ###### Dentro de esta carpeta, ademas de tener `TODOS` los iconos a usar, crea un [`ARCHIVO.rc`](https://github.com/OGMou/WindowsGEM/blob/main/icons/generate/ARCHIVO.rc)
  - **ABRIR `Developer Command Prompt for VS`**.
    ###### Este se encuentra en el menu de inicio, en la carpeta `Visual Studio`
  - **EJECUTAR los siguientes comandos:**
    ###### Este comando ubica la terminal o consola en la ruta de trabajo. `Ejemplo:` cd "C:\Users\User\Desktop\ICONS"
    ```
    cd "C:\Ruta\Completa\A\Tu\CarpetaDeIconos"
    ```
  	###### Este comando lee el (ARCHIVO.rc), extrae los datos de los iconos y los empaqueta junto con sus IDs en un archivo binario intermedio, creando asi un (ARCHIVO.res). `Ejemplo:` rc /nologo icons_define.rc
    ```
    rc /nologo ARCHIVO.rc
    ```
	  ###### Este comando toma el archivo de recursos compilados (ARCHIVO.res) y construye la estructura final del archivo DLL. `Ejemplo:` link /DLL /NOENTRY /NOLOGO /MACHINE:X64 /OUT:icons_VS.dll icons_define.res
    ```
    link /DLL /NOENTRY /NOLOGO /MACHINE:X64 /OUT:ARCHIVO.dll ARCHIVO.res
    ```
- **Reemplaza ARCHIVO.rc por el nombre que le pusiste a tu archivo .rc**
- **Reemplaza ARCHIVO.dll por el nombre que quieras para tu dll. Ejemplo: MisIconosVS_x64.dll.**
- **Reemplaza ARCHIVO.res por el nombre del archivo .res que se creo durante el segundo comando.**
