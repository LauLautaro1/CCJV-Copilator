param(
    [string]$Proyecto = (Get-Location).Path,
    [ValidateSet("Maven", "Gradle")]
    [string]$BuildTool,
    [string]$GroupId = "com.example",
    [string]$ArtifactId = ($Proyecto.Split('\')[-1])
)

function Add-Maven {
    param(
        [string]$ProjectPath,
        [string]$GroupId,
        [string]$ArtifactId
    )

    # Crear estructura Maven
    $mavenSrc = "$ProjectPath\src\main\java"
    $mavenResources = "$ProjectPath\src\main\resources"
    $mavenTest = "$ProjectPath\src\test\java"
    $mavenTestResources = "$ProjectPath\src\test\resources"

    New-Item -Path $mavenSrc -ItemType Directory -Force | Out-Null
    New-Item -Path $mavenResources -ItemType Directory -Force | Out-Null
    New-Item -Path $mavenTest -ItemType Directory -Force | Out-Null
    New-Item -Path $mavenTestResources -ItemType Directory -Force | Out-Null

    # Mover archivos existentes a la nueva estructura
    $existingFiles = Get-ChildItem -Path "$ProjectPath\src" -Filter "*.java" -File
    if ($existingFiles.Count -gt 0) {
        Move-Item -Path "$ProjectPath\src\*.java" -Destination $mavenSrc -Force
    }

    # Crear pom.xml
    $pomContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>$GroupId</groupId>
    <artifactId>$ArtifactId</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <maven.compiler.source>11</maven.compiler.source>
        <maven.compiler.target>11</maven.compiler.target>
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
    $pomContent | Out-File -FilePath "$ProjectPath\pom.xml" -Encoding UTF8

    # Actualizar scripts existentes
    $compilerScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path
)

Write-Host "Este proyecto usa Maven. Ejecuta: mvn compile"
"@
    Set-Content -Path "$ProjectPath\Compilar.ps1" -Value $compilerScript

    $executorScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path,
    [string]`$ClasePrincipal = "$GroupId.$ArtifactId.App"
)

Write-Host "Este proyecto usa Maven. Ejecuta: mvn exec:java -Dexec.mainClass=`$ClasePrincipal"
"@
    Set-Content -Path "$ProjectPath\Ejecutar.ps1" -Value $executorScript
}

function Add-Gradle {
    param(
        [string]$ProjectPath,
        [string]$GroupId,
        [string]$ArtifactId
    )

    # Crear estructura Gradle
    $gradleSrc = "$ProjectPath\src\main\java"
    $gradleResources = "$ProjectPath\src\main\resources"
    $gradleTest = "$ProjectPath\src\test\java"
    $gradleTestResources = "$ProjectPath\src\test\resources"

    New-Item -Path $gradleSrc -ItemType Directory -Force | Out-Null
    New-Item -Path $gradleResources -ItemType Directory -Force | Out-Null
    New-Item -Path $gradleTest -ItemType Directory -Force | Out-Null
    New-Item -Path $gradleTestResources -ItemType Directory -Force | Out-Null

    # Mover archivos existentes
    $existingFiles = Get-ChildItem -Path "$ProjectPath\src" -Filter "*.java" -File
    if ($existingFiles.Count -gt 0) {
        Move-Item -Path "$ProjectPath\src\*.java" -Destination $gradleSrc -Force
    }

    # Crear build.gradle
    $gradleContent = @"
plugins {
    id 'java'
    id 'application'
}

group = '$GroupId'
version = '1.0-SNAPSHOT'
sourceCompatibility = '11'

repositories {
    mavenCentral()
}

application {
    mainClassName = '$GroupId.$ArtifactId.App'
}

dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.8.1'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.8.1'
}

test {
    useJUnitPlatform()
}
"@
    $gradleContent | Out-File -FilePath "$ProjectPath\build.gradle" -Encoding UTF8

    # Crear settings.gradle
    $settingsContent = "rootProject.name = '$ArtifactId'"
    $settingsContent | Out-File -FilePath "$ProjectPath\settings.gradle" -Encoding UTF8

    # Actualizar scripts existentes
    $compilerScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path
)

Write-Host "Este proyecto usa Gradle. Ejecuta: gradle build"
"@
    Set-Content -Path "$ProjectPath\Compilar.ps1" -Value $compilerScript

    $executorScript = @"
param(
    [string]`$Proyecto = (Get-Location).Path
)

Write-Host "Este proyecto usa Gradle. Ejecuta: gradle run"
"@
    Set-Content -Path "$ProjectPath\Ejecutar.ps1" -Value $executorScript
}

# Verificar que el proyecto existe
if (-Not (Test-Path $Proyecto)) {
    Write-Host "El proyecto no existe en la ruta especificada."
    exit 1
}

# Verificar que tiene estructura src
if (-Not (Test-Path "$Proyecto\src")) {
    Write-Host "El proyecto no tiene estructura src. No es un proyecto Java válido."
    exit 1
}

# Aplicar el build tool seleccionado
switch ($BuildTool) {
    "Maven" { Add-Maven -ProjectPath $Proyecto -GroupId $GroupId -ArtifactId $ArtifactId }
    "Gradle" { Add-Gradle -ProjectPath $Proyecto -GroupId $GroupId -ArtifactId $ArtifactId }
}

Write-Host "`n✅ $BuildTool agregado correctamente al proyecto $ArtifactId"
Write-Host "Estructura actualizada:"
Get-ChildItem -Path $Proyecto -Recurse | Where-Object { $_.PSIsContainer } | Select-Object FullName

Write-Host "`nComandos útiles:"
switch ($BuildTool) {
    "Maven" {
        Write-Host "- Compilar: mvn compile"
        Write-Host "- Ejecutar: mvn exec:java -Dexec.mainClass=$GroupId.$ArtifactId.App"
        Write-Host "- Empaquetar: mvn package"
    }
    "Gradle" {
        Write-Host "- Compilar: gradle build"
        Write-Host "- Ejecutar: gradle run"
        Write-Host "- Tests: gradle test"
    }
}
