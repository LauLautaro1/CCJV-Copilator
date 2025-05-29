Write-Host "Generando scripts para tus proyectos Java..."

# CrearProyecto.ps1
if (-not (Test-Path ".\CrearProyecto.ps1")) {
    @'
param(
    [string]$NombreProyecto
)

$srcPath = "$NombreProyecto\src"
$binPath = "$NombreProyecto\bin"

New-Item -Path $srcPath -ItemType Directory -Force | Out-Null
New-Item -Path $binPath -ItemType Directory -Force | Out-Null

$mainContent = @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto");
    }
}
"@
$mainContent | Set-Content -Path "$srcPath\Main.java"

Write-Host "Proyecto '$NombreProyecto' creado correctamente."
'@ | Set-Content -Path .\CrearProyecto.ps1
    Write-Host "✔ CrearProyecto.ps1 creado."
} else {
    Write-Host "✔ CrearProyecto.ps1 ya existe."
}

# Compilar.ps1
if (-not (Test-Path ".\Compilar.ps1")) {
    @'
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
'@ | Set-Content -Path .\Compilar.ps1
    Write-Host "✔ Compilar.ps1 creado."
} else {
    Write-Host "✔ Compilar.ps1 ya existe."
}

# Ejecutar.ps1
if (-not (Test-Path ".\Ejecutar.ps1")) {
    @'
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
'@ | Set-Content -Path .\Ejecutar.ps1
    Write-Host "✔ Ejecutar.ps1 creado."
} else {
    Write-Host "✔ Ejecutar.ps1 ya existe."
}

Write-Host "`n✅ Scripts listos para usar. Ahora podés crear y compilar tus proyectos así:"
Write-Host "1. .\CrearProyecto.ps1 -NombreProyecto MiProyecto"
Write-Host "2. .\Compilar.ps1 -Proyecto MiProyecto"
Write-Host "3. .\Ejecutar.ps1 -Proyecto MiProyecto"

