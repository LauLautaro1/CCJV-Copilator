param(
    [string]$NombreProyecto
)

# Crear carpeta principal del proyecto
New-Item -Path $NombreProyecto -ItemType Directory -Force | Out-Null

# Estructura básica del proyecto
$srcPath = "$NombreProyecto\src"
$binPath = "$NombreProyecto\bin"
$libPath = "$NombreProyecto\lib"
$docPath = "$NombreProyecto\docs"

# Crear directorios principales
New-Item -Path $srcPath -ItemType Directory -Force | Out-Null
New-Item -Path $binPath -ItemType Directory -Force | Out-Null
New-Item -Path $libPath -ItemType Directory -Force | Out-Null
New-Item -Path $docPath -ItemType Directory -Force | Out-Null

# Crear archivo Main.java
$mainContent = @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto");
    }
}
"@
$mainContent | Set-Content -Path "$srcPath\Main.java"

# Crear archivo .project para Eclipse
$projectContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<projectDescription>
    <name>$NombreProyecto</name>
    <comment></comment>
    <projects></projects>
    <buildSpec>
        <buildCommand>
            <name>org.eclipse.jdt.core.javabuilder</name>
            <arguments></arguments>
        </buildCommand>
    </buildSpec>
    <natures>
        <nature>org.eclipse.jdt.core.javanature</nature>
    </natures>
</projectDescription>
"@
$projectContent | Out-File -FilePath "$NombreProyecto\.project" -Encoding UTF8

# Crear archivo .classpath para Eclipse
$classpathContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<classpath>
    <classpathentry kind="src" path="src"/>
    <classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER"/>
    <classpathentry kind="output" path="bin"/>
</classpath>
"@
$classpathContent | Out-File -FilePath "$NombreProyecto\.classpath" -Encoding UTF8

# Crear scripts de utilidad dentro del proyecto
$crearProyectoScript = @"
param(
    [string]`$NombreProyecto
)

Write-Host "Este script está diseñado para usarse desde el directorio raíz, no dentro de un proyecto existente."
"@

$compilarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path
)

`$src = "`$Proyecto\src"
`$bin = "`$Proyecto\bin"

# Obtener todos los archivos .java recursivamente
`$javaFiles = Get-ChildItem -Path `$src -Filter "*.java" -Recurse -File

if (`$javaFiles.Count -eq 0) {
    Write-Host "No se encontraron archivos .java en `$src"
    exit 1
}

# Crear estructura de paquetes en bin si no existe
foreach (`$file in `$javaFiles) {
    `$relativePath = `$file.FullName.Substring(`$src.Length)
    `$targetDir = Join-Path `$bin `$relativePath | Split-Path -Parent
    if (-Not (Test-Path `$targetDir)) {
        New-Item -ItemType Directory -Path `$targetDir -Force | Out-Null
    }
}

# Compilar todos los archivos encontrados
javac -d `$bin -sourcepath `$src (`$javaFiles.FullName -join " ")

if (`$?) {
    Write-Host "Compilación exitosa. Se compilaron `$(`$javaFiles.Count) archivos."
} else {
    Write-Host "Error durante la compilación."
    exit 1
}
"@

$ejecutarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path,
    [string]`$ClasePrincipal = "Main"
)

`$bin = "`$Proyecto\bin"

# Verificar si existe la carpeta bin
if (-Not (Test-Path `$bin)) {
    Write-Host "No se encontró la carpeta bin en `$Proyecto. Compila el proyecto primero."
    exit 1
}

# Buscar la clase principal recursivamente
`$classFile = Get-ChildItem -Path `$bin -Filter "`$ClasePrincipal.class" -Recurse -File | Select-Object -First 1

if (-Not `$classFile) {
    Write-Host "No se encontró la clase `$ClasePrincipal.class en `$bin"
    exit 1
}

# Obtener el nombre completo de la clase (incluyendo paquete)
`$relativePath = `$classFile.FullName.Substring(`$bin.Length + 1)
`$className = `$relativePath -replace '\.class$', '' -replace '\\', '.'

Write-Host "Ejecutando: `$className"

# Ejecutar la clase
java -cp `$bin `$className
"@

# Guardar los scripts en el proyecto
Set-Content -Path "$NombreProyecto\Compilar.ps1" -Value $compilarScript
Set-Content -Path "$NombreProyecto\Ejecutar.ps1" -Value $ejecutarScript
Set-Content -Path "$NombreProyecto\CrearProyecto.ps1" -Value $crearProyectoScript

# Crear README básico
$readmeContent = @"
# $NombreProyecto

Proyecto Java generado automáticamente.

## Estructura del proyecto
- `/src` - Código fuente Java
- `/bin` - Archivos compilados .class
- `/lib` - Bibliotecas externas
- `/docs` - Documentación

## Uso
1. Compilar: `.\Compilar.ps1`
2. Ejecutar: `.\Ejecutar.ps1`

## Personalización
Puedes especificar una clase principal diferente:
`.\Ejecutar.ps1 -ClasePrincipal "com.paquete.MiClase"`
"@
Set-Content -Path "$NombreProyecto\README.md" -Value $readmeContent

Write-Host @"
✅ Proyecto '$NombreProyecto' creado correctamente con estructura completa.

Estructura creada:
$NombreProyecto/
├── src/
│   └── Main.java
├── bin/
├── lib/
├── docs/
├── .project
├── .classpath
├── Compilar.ps1
├── Ejecutar.ps1
└── README.md

Puedes comenzar a trabajar con:
1. cd $NombreProyecto
2. .\Compilar.ps1
3. .\Ejecutar.ps1
"@
