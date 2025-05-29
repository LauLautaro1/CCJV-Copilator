param(
    [string]$Proyecto = (Get-Location).Path,  # Usa el directorio actual por defecto
    [string]$ClasePrincipal = "Main"          # Parámetro opcional para especificar la clase principal
)

$bin = "$Proyecto\bin"

# Verificar si existe la carpeta bin
if (-Not (Test-Path $bin)) {
    Write-Host "No se encontró la carpeta bin en $Proyecto. Compila el proyecto primero."
    exit 1
}

# Buscar la clase principal recursivamente
$classFile = Get-ChildItem -Path $bin -Filter "$ClasePrincipal.class" -Recurse -File | Select-Object -First 1

if (-Not $classFile) {
    Write-Host "No se encontró la clase $ClasePrincipal.class en $bin"
    exit 1
}

# Obtener el nombre completo de la clase (incluyendo paquete)
$relativePath = $classFile.FullName.Substring($bin.Length + 1)
$className = $relativePath -replace '\.class$', '' -replace '\\', '.'

Write-Host "Ejecutando $className desde $Proyecto"

# Ejecutar la clase
java -cp $bin $className
