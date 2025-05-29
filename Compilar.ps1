param(
    [string]$Proyecto = (Get-Location).Path  # Usa el directorio actual por defecto
)

$src = "$Proyecto\src"
$bin = "$Proyecto\bin"

# Verificar si existe la carpeta src
if (-Not (Test-Path $src)) {
    Write-Host "No se encontró la carpeta src en $Proyecto"
    exit 1
}

# Obtener todos los archivos .java recursivamente
$javaFiles = Get-ChildItem -Path $src -Filter "*.java" -Recurse -File

if ($javaFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .java en $src o sus subcarpetas"
    exit 1
}

# Crear estructura de paquetes en bin si no existe
foreach ($file in $javaFiles) {
    $relativePath = $file.FullName.Substring($src.Length)
    $targetDir = Join-Path $bin $relativePath | Split-Path -Parent
    if (-Not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
}

# Compilar todos los archivos encontrados
javac -d $bin -sourcepath $src ($javaFiles.FullName -join " ")

if ($?) {
    Write-Host "Compilación exitosa. Se compilaron $($javaFiles.Count) archivos en $Proyecto"
} else {
    Write-Host "Error durante la compilación."
    exit 1
}
