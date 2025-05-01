<#
.SYNOPSIS
Añade rutas específicas de forma permanente a la variable de entorno PATH del sistema.

.DESCRIPTION
Este script lee la variable de entorno PATH actual del sistema, comprueba si las rutas
especificadas en la variable `$rutasParaAnadir` ya existen en ella y si no existen,
las añade. La modificación es persistente (permanece tras reiniciar).
Está diseñado para ejecutarse de forma silenciosa, por ejemplo, durante una instalación
desatendida de Windows o integrado en una imagen ISO con NTLite.
Las rutas se añaden incluso si los directorios no existen físicamente en el momento
de la ejecución del script.

.NOTES
Author: OGMou❤️
Fecha: 2025-04-27
#>

# ==============================================================================
# Sección: Requisitos
# ==============================================================================
# - Ejecutar este script con privilegios de Administrador.
# - PowerShell 5.1 o superior (incluido por defecto en Windows 10 y 11).

# ==============================================================================
# Sección: Variables
# ==============================================================================

# Define aquí las rutas completas que deseas añadir al PATH del sistema.
# Cada ruta debe ser una cadena de texto separada en el array.
# IMPORTANTE: Estas rutas se añadirán aunque no existan en el sistema.
$rutasParaAnadir = @(
    "C:\Program Files\MiAplicacionX",
    "C:\Herramientas\Utils",
    "%SystemDrive%\PortableApps\Common" # Ejemplo usando una variable de entorno
    # Añade aquí tantas rutas como necesites
)

# --- Inicio: Configuración Opcional de Logging ---
# Define la ruta para el archivo de log. Descomenta si activas el logging.
# $logFile = "C:\Windows\Temp\add2path_error.log"
# --- Fin: Configuración Opcional de Logging ---

# ==============================================================================
# Sección: Funciones
# ==============================================================================

# --- Inicio: Función Opcional de Logging ---
# Descomenta esta función si decides habilitar el registro de errores.
# function Write-Log {
#     param(
#         [string]$Message
#     )
#     # Asegura que la variable $logFile esté definida si se llama a esta función
#     if (-not (Get-Variable -Name 'logFile' -ErrorAction SilentlyContinue)) {
#         Write-Warning "La variable `$logFile` no está definida. No se puede registrar el mensaje."
#         return
#     }
#
#     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     $logEntry = "[$timestamp] ERROR: $Message"
#     try {
#         # Crea el directorio si no existe (útil si Temp no existe o C:\Windows no es accesible temporalmente)
#         $logDir = Split-Path -Path $logFile -Parent
#         if (-not (Test-Path -Path $logDir -PathType Container)) {
#             New-Item -Path $logDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
#         }
#         # Añade la entrada al archivo de log
#         Add-Content -Path $logFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
#     } catch {
#         # Si falla la escritura del log, muestra una advertencia en la consola (aunque se espera ejecución silenciosa)
#         Write-Warning "No se pudo escribir en el archivo de log '$logFile': $($_.Exception.Message)"
#     }
# }
# --- Fin: Función Opcional de Logging ---

# ==============================================================================
# Sección: Lógica Principal de Ejecución (Main Execution Logic)
# ==============================================================================

# Descomentar la siguiente línea puede ser útil para depuración, pero debe eliminarse
# o comentarse para la ejecución silenciosa final.
# Write-Host "Iniciando script add2path.ps1..."

try {
    # Obtener el valor actual de la variable PATH del sistema (Machine scope)
    # Se usa 'Machine' para que el cambio sea a nivel de sistema y permanente.
    $currentSystemPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')

    # Dividir el PATH actual en un array de rutas individuales.
    # Se eliminan entradas vacías que podrían resultar de punto y comas dobles (;;) o al final.
    $pathEntries = $currentSystemPath -split ';' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim() }

    # Variable para saber si se realizó algún cambio
    $pathModified = $false
    # Array para construir el nuevo PATH
    $newPathEntries = @($pathEntries) # Copiamos las rutas existentes

    # Procesar cada ruta que queremos añadir
    foreach ($rutaToAddRaw in $rutasParaAnadir) {
        # Expandir variables de entorno en la ruta (ej. %SystemDrive%)
        $rutaToAdd = [Environment]::ExpandEnvironmentVariables($rutaToAddRaw)

        # Comprobar si la ruta (ya expandida) existe en el array actual de rutas.
        # La comparación es insensible a mayúsculas/minúsculas por defecto con -contains.
        if ($pathEntries -notcontains $rutaToAdd) {
            # La ruta no está en el PATH actual, la añadimos a nuestra nueva lista
            $newPathEntries += $rutaToAdd
            $pathModified = $true
            # Descomentar para depuración:
            # Write-Host "Añadiendo ruta: '$rutaToAdd'"
        } else {
            # Descomentar para depuración:
            # Write-Host "La ruta '$rutaToAdd' (de '$rutaToAddRaw') ya existe en el PATH."
        }
    }

    # Si se añadieron rutas nuevas, actualizar la variable de entorno del sistema
    if ($pathModified) {
        # Unir todas las entradas (las originales + las nuevas) con ';' como separador
        $newSystemPath = $newPathEntries -join ';'

        # Establecer la nueva variable de entorno PATH a nivel de sistema
        [Environment]::SetEnvironmentVariable('Path', $newSystemPath, 'Machine')

        # Descomentar para depuración:
        # Write-Host "Variable PATH del sistema actualizada correctamente."

        # NOTA: Los cambios en las variables de entorno del sistema normalmente requieren
        # reiniciar el sistema o al menos reiniciar el explorador de Windows (explorer.exe)
        # para que sean efectivos en nuevas aplicaciones o consolas.
        # En el contexto de NTLite y la instalación de Windows, un reinicio es
        # parte normal del proceso, por lo que no se necesita forzar la actualización aquí.

    } else {
        # Descomentar para depuración:
        # Write-Host "No se añadieron nuevas rutas. El PATH del sistema no fue modificado."
    }

    # Descomentar para depuración:
    # Write-Host "Script add2path.ps1 finalizado con éxito."

} catch {
    # Captura cualquier error que ocurra durante la ejecución del bloque try
    $errorMessage = "Error ejecutando add2path.ps1: $($_.Exception.Message)"
    # Muestra el error en la consola de errores (puede no ser visible en ejecución silenciosa)
    Write-Error $errorMessage

    # --- Inicio: Llamada Opcional a Logging ---
    # Descomenta la siguiente línea si habilitaste la función Write-Log y la variable $logFile
    # Write-Log -Message $errorMessage
    # Si necesitas más detalle en el log, puedes añadir el StackTrace:
    # if ($_.Exception.StackTrace) {
    #     Write-Log -Message "StackTrace: $($_.Exception.StackTrace)"
    # }
    # --- Fin: Llamada Opcional a Logging ---

    # Considera salir con un código de error si este script forma parte de una cadena mayor
    # exit 1
}

# Fin del script
