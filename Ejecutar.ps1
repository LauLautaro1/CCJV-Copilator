
param(
    [string]$Proyecto
)

$bin = "$Proyecto\bin"
$classFile = "$bin\Main.class"

if (-Not (Test-Path $classFile)) {
    Write-Host "El archivo Main.class no existe. Compila el proyecto primero."
    exit
}

java -cp $bin Main
