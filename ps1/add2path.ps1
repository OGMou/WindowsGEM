<#
.SYNOPSIS
    Añade directorios especificados a la variable de entorno PATH del sistema.
.DESCRIPTION
    Este script lee una lista predefinida de rutas y las añade a la variable PATH
    global del sistema si aún no están presentes. Requiere privilegios de administrador.
    Los cambios pueden requerir reiniciar la consola o el sistema para surtir efecto global.
.AUTHOR
    OGMou
#>

# --- REQUISITOS ---
# - Windows PowerShell 5.1 o superior.
# - Ejecutar este script como Administrador.

# --- VARIABLES ---

#   Añade cada ruta completa como un string dentro de los paréntesis @().
#   Asegúrate de que cada ruta esté entre comillas y separada por una coma.
#   Ejemplo:
#   $rutasParaAnadir = @(
#       "C:\Program Files\MiApp\bin",
#       "C:\Herramientas\Utils",
#       "D:\PortableApps\Python\Scripts"
#   )

$rutasParaAnadir = @(
    "C:\Ruta\Ejemplo\Numero1",
    "D:\OtraCarpeta\Importante",
    "C:\Utils\ScriptsPersonalizados"
)
# << Añade más rutas aquí si lo necesitas, una por línea con comillas y coma >>

# Variables internas del script
$regKeySystemPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$pathVariableName = "Path"
$Scope = "Machine" # 'Machine' para PATH del sistema, 'User' para PATH del usuario

# --- FUNCIONES ---

function Add-SinglePathToSystem {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PathToAdd
    )

    Write-Host ("-"*40)
    Write-Host "Processing path: '$PathToAdd'"

    # Validar que la ruta no sea nula o vacía
    if ([string]::IsNullOrWhiteSpace($PathToAdd)) {
        Write-Warning "The provided path is empty. Skipping."
        return
    }

    # (Opcional pero recomendado) Comprobar si el directorio existe
    if (-not (Test-Path -Path $PathToAdd -PathType Container)) {
        Write-Warning "The path '$PathToAdd' does not exist on the filesystem or is not a directory. It will be added anyway, but might be invalid."
    }

    try {
        # Obtener el valor actual del PATH del sistema desde el Registro
        $currentPathValue = (Get-ItemProperty -Path $regKeySystemPath -Name $pathVariableName -ErrorAction Stop).$pathVariableName
        $pathEntries = $currentPathValue -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } # Dividir y limpiar entradas vacías

        # Comprobar si la ruta ya existe en el PATH (ignorando mayúsculas/minúsculas y barras finales)
        $pathExists = $false
        $normalizedPathToAdd = $PathToAdd.TrimEnd('\')
        foreach ($entry in $pathEntries) {
            if ($entry.TrimEnd('\') -eq $normalizedPathToAdd) {
                $pathExists = $true
                break
            }
        }

        if ($pathExists) {
            Write-Host "The path '$PathToAdd' is already in the system PATH." -ForegroundColor Yellow
        } else {
            Write-Host "Adding '$PathToAdd' to the system PATH..."
            # Añadir la nueva ruta al array
            $newPathEntries = $pathEntries + $PathToAdd
            # Unir las rutas de nuevo con punto y coma
            $newPathValue = $newPathEntries -join ';'

            # Establecer el nuevo valor en el registro
            Set-ItemProperty -Path $regKeySystemPath -Name $pathVariableName -Value $newPathValue -ErrorAction Stop
            Write-Host "Path '$PathToAdd' successfully added to the system PATH." -ForegroundColor Green

            # Informar sobre la necesidad de reiniciar
            Write-Host "NOTE: You might need to restart your PowerShell console or even the system for this change to take effect in all applications." -ForegroundColor Cyan

            # Propagar el cambio al entorno del proceso actual de PowerShell (útil para la misma sesión)
            $env:Path = $newPathValue
            Write-Host "(The PATH for this PowerShell session has been updated)." -ForegroundColor DarkCyan

        }
    } catch {
        Write-Error "An error occurred while trying to modify the system PATH: $($_.Exception.Message)"
        Write-Error "Make sure you are running this script as Administrator."
    }
     Write-Host ("-"*40)
}

# --- MAIN EXECUTION LOGIC ---

# 1. Comprobar si el script se ejecuta con privilegios de Administrador
# --- MODIFICACIÓN AQUÍ: Se escribe el autor directamente (sin emoji) ---
Write-Host "Starting script '$($MyInvocation.MyCommand.Name)' by OGMou..."
# --- FIN DE LA MODIFICACIÓN ---
Write-Host "Checking for administrator privileges..."
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$currentUser
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Access denied! This script requires Administrator privileges to modify the system PATH."
    Write-Host "Please, right-click on the script or your PowerShell console and select 'Run as administrator'."
    # Pausa si se ejecuta directamente desde el explorador
    if ($Host.Name -eq 'ConsoleHost') { Read-Host "Press Enter to exit..." }
    Exit 1 # Termina el script con código de error
} else {
    Write-Host "Administrator privileges confirmed." -ForegroundColor Green
}

# 2. Procesar cada ruta definida en la variable $rutasParaAnadir
Write-Host "`nStarting the process of adding paths to the system PATH..."

if ($null -eq $rutasParaAnadir -or $rutasParaAnadir.Count -eq 0) {
     Write-Warning "No paths have been defined in the `$rutasParaAnadir variable. The script will do nothing."
} else {
    foreach ($rutaIndividual in $rutasParaAnadir) {
        # Llama a la función para añadir cada ruta
        Add-SinglePathToSystem -PathToAdd $rutaIndividual.Trim() # Trim() elimina espacios al inicio/final
    }
}

Write-Host "`nPATH update process finished."

# Pausa final si se ejecuta directamente desde el explorador
if ($Host.Name -eq 'ConsoleHost') {
    Write-Host "`nRemember that changes to the system PATH may require restarting applications or your session to be recognized."
    Read-Host "Press Enter to close this window..."
}
