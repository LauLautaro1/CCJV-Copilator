param(
    [string]$Proyecto = (Get-Location).Path,
    [string]$ClasePrincipal = "Main"
)

# Determinar el tipo de proyecto
$isMaven = Test-Path "$Proyecto\pom.xml"
$isGradle = Test-Path "$Proyecto\build.gradle"

function Get-MavenCommand {
    if (Get-Command mvn -ErrorAction SilentlyContinue) { return "mvn" }
    if ($env:MAVEN_HOME -and (Test-Path "$env:MAVEN_HOME\bin\mvn.cmd")) {
        return "$env:MAVEN_HOME\bin\mvn.cmd"
    }
    return $null
}

function Get-GradleCommand {
    if (Get-Command gradle -ErrorAction SilentlyContinue) { return "gradle" }
    if ($env:GRADLE_HOME -and (Test-Path "$env:GRADLE_HOME\bin\gradle.bat")) {
        return "$env:GRADLE_HOME\bin\gradle.bat"
    }
    return $null
}

if ($isMaven) {
    Write-Host "🔍 Detectado proyecto Maven"
    
    $mvn = Get-MavenCommand
    if (-not $mvn) {
        Write-Host @"
❌ ERROR: Maven no está disponible
Solución:
1. Asegúrate de tener Maven instalado
2. Configura MAVEN_HOME o agrega mvn al PATH
"@
        exit 1
    }

    Write-Host "🚀 Ejecutando con Maven..."
    & $mvn -f "$Proyecto\pom.xml" exec:java -Dexec.mainClass="$ClasePrincipal"
}
elseif ($isGradle) {
    Write-Host "🔍 Detectado proyecto Gradle"
    
    $gradle = Get-GradleCommand
    if (-not $gradle) {
        Write-Host @"
❌ ERROR: Gradle no está disponible
Solución:
1. Asegúrate de tener Gradle instalado
2. Configura GRADLE_HOME o agrega gradle al PATH
"@
        exit 1
    }

    Write-Host "🚀 Ejecutando con Gradle..."
    & $gradle -p "$Proyecto" run -PmainClass="$ClasePrincipal"
}
else {
    Write-Host "🔍 Detectado proyecto Java estándar"
    
    $bin = "$Proyecto\bin"
    if (-Not (Test-Path $bin)) {
        Write-Host "No se encontró la carpeta bin en $Proyecto. Compila el proyecto primero."
        exit 1
    }

    $classFile = Get-ChildItem -Path $bin -Filter "$ClasePrincipal.class" -Recurse -File | Select-Object -First 1
    if (-Not $classFile) {
        Write-Host "No se encontró la clase $ClasePrincipal.class en $bin"
        exit 1
    }

    $relativePath = $classFile.FullName.Substring($bin.Length + 1)
    $className = $relativePath -replace '\.class$', '' -replace '\\', '.'

    Write-Host "🚀 Ejecutando $className desde $Proyecto"
    java -cp $bin $className
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error durante la ejecución (Código: $LASTEXITCODE)"
    exit $LASTEXITCODE
}
