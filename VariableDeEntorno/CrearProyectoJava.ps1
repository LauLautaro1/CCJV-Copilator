param(
    [string]$NombreProyecto,
    [ValidateSet("Ninguno", "Maven", "Gradle")]
    [string]$BuildTool = "Ninguno",
    [string]$GroupId = "com.example",
    [string]$JavaVersion = "11"
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

# Dentro del bloque Maven, cambia la creación del Main.java a:
$packagePath = "$mainJavaPath\$($GroupId -replace '\.','\')\$($NombreProyecto)"
New-Item -Path $packagePath -ItemType Directory -Force | Out-Null

$mainContent = @"
package $GroupId.$NombreProyecto;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto!");
    }
}
"@
$mainContent | Set-Content -Path "$packagePath\Main.java"

# Configuración específica para build tools
switch ($BuildTool) {
    "Maven" {
        # Estructura Maven (sin crear src/bin iniciales)
        $mainJavaPath = "$NombreProyecto\src\main\java"
        $mainResourcesPath = "$NombreProyecto\src\main\resources"
        $testJavaPath = "$NombreProyecto\src\test\java"
        $testResourcesPath = "$NombreProyecto\src\test\resources"
        
        New-Item -Path $mainJavaPath -ItemType Directory -Force | Out-Null
        New-Item -Path $mainResourcesPath -ItemType Directory -Force | Out-Null
        New-Item -Path $testJavaPath -ItemType Directory -Force | Out-Null
        New-Item -Path $testResourcesPath -ItemType Directory -Force | Out-Null
        
        # Crear Main.java directamente en la estructura Maven
        $mainContent = @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto");
    }
}
"@
        $mainContent | Set-Content -Path "$mainJavaPath\Main.java"
        
        # Crear pom.xml
        $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>$GroupId</groupId>
    <artifactId>$NombreProyecto</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>$JavaVersion</maven.compiler.source>
        <maven.compiler.target>$JavaVersion</maven.compiler.target>
    </properties>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
            </plugin>
        </plugins>
    </build>
</project>
"@
        $pomContent | Out-File -FilePath "$NombreProyecto\pom.xml" -Encoding UTF8
        
        # Eliminar carpetas src y bin originales
        #Remove-Item -Path $srcPath -Recurse -Force
        #Remove-Item -Path $binPath -Recurse -Force
    }
    
    "Gradle" {
        # Estructura Gradle (sin crear src/bin iniciales)
        $mainJavaPath = "$NombreProyecto\src\main\java"
        $mainResourcesPath = "$NombreProyecto\src\main\resources"
        $testJavaPath = "$NombreProyecto\src\test\java"
        $testResourcesPath = "$NombreProyecto\src\test\resources"
        
        New-Item -Path $mainJavaPath -ItemType Directory -Force | Out-Null
        New-Item -Path $mainResourcesPath -ItemType Directory -Force | Out-Null
        New-Item -Path $testJavaPath -ItemType Directory -Force | Out-Null
        New-Item -Path $testResourcesPath -ItemType Directory -Force | Out-Null
        
        # Crear Main.java directamente en la estructura Gradle
        $mainContent = @"
public class Main {
    public static void main(String[] args) {
        System.out.println("Hola desde $NombreProyecto");
    }
}
"@
        $mainContent | Set-Content -Path "$mainJavaPath\Main.java"
        
        # Crear build.gradle
        $gradleContent = @"
plugins {
    id 'java'
    id 'application'
}

group = '$GroupId'
version = '1.0-SNAPSHOT'
sourceCompatibility = '$JavaVersion'

repositories {
    mavenCentral()
}

application {
    mainClassName = '$GroupId.$NombreProyecto.Main'
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.8.1'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.8.1'
}

test {
    useJUnitPlatform()
}
"@
        $gradleContent | Out-File -FilePath "$NombreProyecto\build.gradle" -Encoding UTF8
        
        # Crear settings.gradle
        $settingsContent = "rootProject.name = '$NombreProyecto'"
        $settingsContent | Out-File -FilePath "$NombreProyecto\settings.gradle" -Encoding UTF8
        
        # Eliminar carpetas src y bin originales
        #Remove-Item -Path $srcPath -Recurse -Force
        #Remove-Item -Path $binPath -Recurse -Force
    }
}

# Crear archivos de configuración para IDE (si no es un proyecto Maven/Gradle)
if ($BuildTool -eq "Ninguno") {
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
}

# Script de compilación adaptado al build tool
switch ($BuildTool) {
    "Maven" {
        $compilarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path  # Usa el directorio actual por defecto
)

Write-Host "🔍 Detectado proyecto Maven"

# Verificar si Maven está instalado
try {
    `$mavenVersion = mvn --version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Maven no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Maven y asegúrate de que esté en tu PATH"
    exit 1
}

# Ejecutar compilación Maven
Write-Host "🚀 Compilando con Maven..."
mvn -f "`$Proyecto\pom.xml" compile

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación Maven completada exitosamente"
} else {
    Write-Host "❌ Error durante la compilación Maven"
    exit 1
}
"@

        $ejecutarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path,
    [string]`$ClasePrincipal = "$GroupId.$NombreProyecto.Main"
)

Write-Host "🔍 Detectado proyecto Maven"

# Verificar si Maven está instalado
try {
    `$mavenVersion = mvn --version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Maven no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Maven y asegúrate de que esté en tu PATH"
    exit 1
}

Write-Host "🚀 Ejecutando con Maven..."
mvn -f "`$Proyecto\pom.xml" exec:java -Dexec.mainClass=`$ClasePrincipal

if (`$LASTEXITCODE -ne 0) {
    Write-Host "❌ Error durante la ejecución (Código: `$LASTEXITCODE)"
    exit `$LASTEXITCODE
}
"@
    }
    
    "Gradle" {
        $compilarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path
)

Write-Host "🔍 Detectado proyecto Gradle"

# Verificar si Gradle está instalado
try {
    `$gradleVersion = gradle --version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Gradle no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Gradle y asegúrate de que esté en tu PATH"
    exit 1
}

Write-Host "🚀 Compilando con Gradle..."
gradle -p "`$Proyecto" build

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación Gradle completada exitosamente"
} else {
    Write-Host "❌ Error durante la compilación Gradle"
    exit 1
}
"@

        $ejecutarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path,
    [string]`$ClasePrincipal = "$GroupId.$NombreProyecto.Main"
)

Write-Host "🔍 Detectado proyecto Gradle"

# Verificar si Gradle está instalado
try {
    `$gradleVersion = gradle --version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Gradle no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Gradle y asegúrate de que esté en tu PATH"
    exit 1
}

Write-Host "🚀 Ejecutando con Gradle..."
gradle -p "`$Proyecto" run -PmainClass=`$ClasePrincipal

if (`$LASTEXITCODE -ne 0) {
    Write-Host "❌ Error durante la ejecución (Código: `$LASTEXITCODE)"
    exit `$LASTEXITCODE
}
"@
    }
    
    default {
        $compilarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path  # Usa el directorio actual por defecto
)

Write-Host "🔍 Detectado proyecto Java estándar"

`$src = "`$Proyecto\src"
`$bin = "`$Proyecto\bin"

# Verificar si existe la carpeta src
if (-Not (Test-Path `$src)) {
    Write-Host "❌ No se encontró la carpeta src en `$Proyecto"
    exit 1
}

# Obtener todos los archivos .java recursivamente
`$javaFiles = Get-ChildItem -Path `$src -Filter "*.java" -Recurse -File

if (`$javaFiles.Count -eq 0) {
    Write-Host "❌ No se encontraron archivos .java en `$src o sus subcarpetas"
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

# Verificar si Java está instalado
try {
    `$javaVersion = javac -version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Java JDK no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Java JDK y asegúrate de que esté en tu PATH"
    exit 1
}

# Compilar todos los archivos encontrados
Write-Host "🚀 Compilando `$(`$javaFiles.Count) archivos Java..."
javac -d `$bin -sourcepath `$src (`$javaFiles.FullName -join " ")

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilación exitosa. Se compilaron `$(`$javaFiles.Count) archivos en `$Proyecto"
} else {
    Write-Host "❌ Error durante la compilación"
    exit 1
}
"@

        $ejecutarScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path,
    [string]`$ClasePrincipal = "Main"
)

Write-Host "🔍 Detectado proyecto Java estándar"

`$bin = "`$Proyecto\bin"

# Verificar si existe la carpeta bin
if (-Not (Test-Path `$bin)) {
    Write-Host "❌ No se encontró la carpeta bin en `$Proyecto. Compila el proyecto primero."
    exit 1
}

# Buscar la clase principal recursivamente
`$classFile = Get-ChildItem -Path `$bin -Filter "`$ClasePrincipal.class" -Recurse -File | Select-Object -First 1

if (-Not `$classFile) {
    Write-Host "❌ No se encontró la clase `$ClasePrincipal.class en `$bin"
    exit 1
}

# Obtener el nombre completo de la clase (incluyendo paquete)
`$relativePath = `$classFile.FullName.Substring(`$bin.Length + 1)
`$className = `$relativePath -replace '\.class$', '' -replace '\\', '.'

# Verificar si Java está instalado
try {
    `$javaVersion = java -version 2>&1
    if (`$LASTEXITCODE -ne 0) {
        throw "Java JRE no está instalado o no está en el PATH"
    }
} catch {
    Write-Host "❌ Error: `$_"
    Write-Host "💡 Solución: Instala Java JRE y asegúrate de que esté en tu PATH"
    exit 1
}

Write-Host "🚀 Ejecutando `$className desde `$Proyecto"
java -cp `$bin `$className

if (`$LASTEXITCODE -ne 0) {
    Write-Host "❌ Error durante la ejecución (Código: `$LASTEXITCODE)"
    exit `$LASTEXITCODE
}
"@
    }
}

# Guardar los scripts en el proyecto con codificación UTF-8
$compilarScript | Out-File -FilePath "$NombreProyecto\Compilar.ps1" -Encoding UTF8
$ejecutarScript | Out-File -FilePath "$NombreProyecto\Ejecutar.ps1" -Encoding UTF8



# ... (todo el código anterior permanece igual hasta la sección de mensaje final) ...

# Mensaje de resumen MEJORADO
$structureMessage = "✅ Proyecto '$NombreProyecto' creado correctamente con estructura completa.`n"
$structureMessage += "Tipo: $(if ($BuildTool -eq "Ninguno") { "Java estándar" } else { $BuildTool })`n`n"

# Verificar y mostrar estructura REAL creada
$structureMessage += "Estructura creada:`n"
$items = Get-ChildItem -Path $NombreProyecto -Recurse | Where-Object { $_.PSIsContainer } | Select-Object FullName
$rootLength = $NombreProyecto.Length + 1

foreach ($item in $items) {
    $relativePath = $item.FullName.Substring($rootLength)
    $indent = "  " * ($relativePath.Split('\').Length - 1)
    $structureMessage += "$indent- $($relativePath.Split('\')[-1])/`n"
}

# Agregar archivos principales
$structureMessage += "`nArchivos principales creados:`n"
Get-ChildItem -Path $NombreProyecto -File -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Substring($rootLength)
    $indent = "  " * ($relativePath.Split('\').Length - 1)
    $structureMessage += "$indent- $($_.Name)`n"
}

$structureMessage += "`nPara comenzar a trabajar:`n"
$structureMessage += "1. cd $NombreProyecto`n"

switch ($BuildTool) {
    "Maven" {
        $structureMessage += @"
2. mvn compile
3. mvn exec:java -Dexec.mainClass=$GroupId.$NombreProyecto.Main
"@
    }
    "Gradle" {
        $structureMessage += @"
2. gradle build
3. gradle run
"@
    }
    default {
        $structureMessage += @"
2. .\Compilar.ps1
3. .\Ejecutar.ps1
"@
    }
}

Write-Host $structureMessage
