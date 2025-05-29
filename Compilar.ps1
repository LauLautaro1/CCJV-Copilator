param(
    [string]$Proyecto
)

$src = "$Proyecto\src"
$bin = "$Proyecto\bin"

$javaFiles = Get-ChildItem "$src\*.java"
if ($javaFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .java en $src"
    exit
}

javac -d $bin "$src\*.java"

if ($?) {
    Write-Host "Compilación exitosa."
} else {
    Write-Host "Error durante la compilación."
}
