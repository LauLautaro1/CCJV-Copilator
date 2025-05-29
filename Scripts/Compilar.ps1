param(
    [string]$Proyecto = (Get-Location).Path  # Usa el directorio actual por defecto
)

# Determinar el tipo de proyecto
$isMaven = Test-Path "$Proyecto\pom.xml"
$isGradle = Test-Path "$Proyecto\build.gradle"

if ($isMaven) {
    # Lógica para Maven
    Write-Host "Compilando proyecto Maven..."
    
    # Verificar si Maven está instalado
    try {
        $mavenVersion = mvn --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Maven no está instalado o no está en el PATH"
        }
    } catch {
        Write-Host "Error: $_"
        Write-Host "Instala Maven y asegúrate de que esté en tu PATH"
        exit 1
    }
    
    # Ejecutar compilación Maven
    mvn -f "$Proyecto\pom.xml" compile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilación Maven completada exitosamente"
    } else {
        Write-Host "❌ Error durante la compilación Maven"
        exit 1
    }
}
elseif ($isGradle) {
    # Lógica para Gradle
    Write-Host "Compilando proyecto Gradle..."
    
    # Verificar si Gradle está instalado
    try {
        $gradleVersion = gradle --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle no está instalado o no está en el PATH"
        }
    } catch {
        Write-Host "Error: $_"
        Write-Host "Instala Gradle y asegúrate de que esté en tu PATH"
        exit 1
    }
    
    # Ejecutar compilación Gradle
    gradle -p "$Proyecto" build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilación Gradle completada exitosamente"
    } else {
        Write-Host "❌ Error durante la compilación Gradle"
        exit 1
    }
}
else {
    # Lógica para proyecto estándar (sin build tool)
    Write-Host "Compilando proyecto Java estándar..."
    
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
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilación exitosa. Se compilaron $($javaFiles.Count) archivos en $Proyecto"
    } else {
        Write-Host "❌ Error durante la compilación"
        exit 1
    }
}
