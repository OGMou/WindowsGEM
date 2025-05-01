<#
.SYNOPSIS
  Busca en el registro HKEY_LOCAL_MACHINE\SOFTWARE\Classes para identificar todos los
  valores únicos de 'PerceivedType', lista las extensiones de archivo asociadas a cada tipo
  (una por línea), y guarda los resultados en un archivo de texto con el mismo nombre
  base que el archivo de script.
.DESCRIPTION
  El script itera sobre las claves de extensión (que empiezan por '.') en HKLM\Software\Classes,
  lee el valor 'PerceivedType' si existe, y agrupa las extensiones según su PerceivedType.
  Finalmente, genera un archivo .txt en la misma carpeta que el script. El nombre del
  archivo .txt será el mismo que el del archivo .ps1 (p.ej., si el script se llama
  'ListarTipos.ps1', el resultado será 'ListarTipos.txt').
.NOTES
  Autor: OGMou❤️
  Fecha: 01/05/2025
#>

# --- Inicio del Script ---
Write-Host "Buscando extensiones y sus 'PerceivedType' en HKEY_LOCAL_MACHINE\SOFTWARE\Classes..." -ForegroundColor Yellow

# --- Configuración de Archivo de Salida ---
# Obtener el directorio donde se está ejecutando el script
# $PSScriptRoot es una variable automática que contiene la ruta del directorio del script actual
if ($PSScriptRoot) {
    $scriptDir = $PSScriptRoot
} else {
    # Fallback por si se ejecuta de una forma donde $PSScriptRoot no está definido (ej. selección en ISE)
    $scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    Write-Warning "No se pudo determinar PSScriptRoot, usando ruta basada en MyInvocation: $scriptDir"
}

# *** CAMBIO: Obtener nombre base del script para el archivo de salida ***
# $MyInvocation.MyCommand.Name contiene el nombre del script (ej: MiScript.ps1)
$scriptFullName = $MyInvocation.MyCommand.Name
# Extraer el nombre sin la extensión .ps1
$scriptBaseName = [System.IO.Path]::GetFileNameWithoutExtension($scriptFullName)
# Crear el nombre del archivo de salida añadiendo .txt
$outputFileName = "$scriptBaseName.txt"
# ***********************************************************************

# Ruta completa al archivo de salida
$outputFilePath = Join-Path -Path $scriptDir -ChildPath $outputFileName

Write-Host "Los resultados se guardarán en: $outputFilePath" -ForegroundColor Cyan

# Ruta base en el registro
$registryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Classes"

# Hash table para almacenar los resultados: Clave = PerceivedType, Valor = Lista de extensiones
$extensionsByType = @{}

# Contador para extensiones sin PerceivedType o con errores
$extensionsWithoutType = 0
$errorCount = 0

# --- Búsqueda en Registro ---
try {
    $allKeys = Get-ChildItem -Path $registryPath -ErrorAction SilentlyContinue
    $extensionKeys = $allKeys | Where-Object { $_.PSChildName -like '.*' }

    Write-Host "Procesando $($extensionKeys.Count) claves de extensión encontradas..."

    foreach ($extKey in $extensionKeys) {
        $extName = $extKey.PSChildName

        try {
            $perceivedType = $extKey.GetValue("PerceivedType", $null)

            if ($perceivedType -ne $null -and $perceivedType -ne "") {
                $perceivedTypeString = $perceivedType.ToString()

                if (-not $extensionsByType.ContainsKey($perceivedTypeString)) {
                    $extensionsByType[$perceivedTypeString] = [System.Collections.Generic.List[string]]::new()
                }
                $extensionsByType[$perceivedTypeString].Add($extName)

            } else {
                $extensionsWithoutType++
            }
        } catch {
            Write-Warning "Error al procesar la extensión '$extName': $($_.Exception.Message)"
            $errorCount++
        }
    } # Fin del bucle foreach

} catch {
    Write-Error "Error general al buscar extensiones en el registro: $($_.Exception.Message)"
    exit 1
}

# --- Generar Contenido para el Archivo ---
$outputLines = [System.Collections.Generic.List[string]]::new()

$outputLines.Add("--- Resumen de PerceivedType Encontrados ---")
$outputLines.Add("==========================================")

$uniqueTypes = $extensionsByType.Keys | Sort-Object
if ($uniqueTypes.Count -gt 0) {
    $outputLines.Add("Se encontraron los siguientes tipos percibidos:")
    $uniqueTypes | ForEach-Object { $outputLines.Add("- $_") }
} else {
    $outputLines.Add("No se encontraron extensiones con un 'PerceivedType' definido.")
}

$outputLines.Add("")
$outputLines.Add("--- Lista de Extensiones por PerceivedType ---")
$outputLines.Add("============================================")

if ($uniqueTypes.Count -gt 0) {
    foreach ($type in $uniqueTypes) {
        $outputLines.Add("")
        $outputLines.Add("[$type]")
        $sortedExtensions = $extensionsByType[$type] | Sort-Object
        foreach ($ext in $sortedExtensions) {
            $outputLines.Add($ext)
        }
    }
}

$outputLines.Add("")
$outputLines.Add("--- Información Adicional ---")
$outputLines.Add("===========================")
$outputLines.Add("Extensiones procesadas sin 'PerceivedType' definido: $extensionsWithoutType")
if ($errorCount -gt 0) {
    $outputLines.Add("Errores encontrados al procesar extensiones individuales: $errorCount")
}

# --- Escribir Resultados al Archivo ---
try {
    Set-Content -Path $outputFilePath -Value $outputLines -Encoding UTF8
    Write-Host "`nResultados guardados correctamente en '$outputFilePath'" -ForegroundColor Green
} catch {
    Write-Error "No se pudo escribir en el archivo '$outputFilePath'. Error: $($_.Exception.Message)"
}

Write-Host "Script finalizado." -ForegroundColor Green
