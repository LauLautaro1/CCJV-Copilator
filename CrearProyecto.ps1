param(
    [string]$NombreProyecto
)

$srcPath = "$NombreProyecto\src"
$binPath = "$NombreProyecto\bin"

# Crear directorios
New-Item -Path $srcPath -ItemType Directory -Force | Out-Null
New-Item -Path $binPath -ItemType Directory -Force | Out-Null

# Crear archivo Main.java
$mainContent = @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto");
    }
}
"@
$mainContent | Set-Content -Path "$srcPath\Main.java"

Write-Host "Proyecto '$NombreProyecto' creado correctamente."

