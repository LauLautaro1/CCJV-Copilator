param(
  [string]$srcDir = "src",
  [string]$binDir = "bin",
  [string]$libDir = "libs",
  [string]$ejecutar = ""
)

#--------- Comprobando que existan las carpetas ----------

if (-not (Test-Path $binDir)){#Si la carpeta no existe la creamos.
  New-Item -ItemType Directory -Path $binDir | Out-Null
  Write-Host "La carpeta $binDir ah sido Creada."
}

#--------- Construir el classpath(Incluyendo los .jar de /libs) ----------

#Aca buscamos todos los jars que puedan haber en libs
$libJars = Get-ChildItem "$libDir\*.jar" -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
$classpath = $binDir

if ($libJars.Count -gt 0){
  $classpath += ";" + ($libJars -join ";")
}

#--------- Buscamos Todos los archivos de .java dentro del src ----------

#Buscamos todos los .java que estan dentro de 
$javaArchivos = Get-ChildItem "$srcDir" -Recurse -Filter *.java | ForEach-Object { $_.FullName }
Write-Host "Archivos java's encontrados $($javaArchivos -join ",")"

#SI no hay archivos javas:
if($javaArchivos.Count -eq 0){
  Write-Host "Error : no hay Archivos .java en $srcDir."
  exit 1
}

#--------- Buscando cual archivo tiene el metodo main ----------

#Usaremos una funcion.
function Get-MainClass {
  param ([string[]]$files)#Este es el parametro de la funcion.

  foreach($file in $files){
    $contenido = Get-Content $file #Esto es para agarrar el contenido que hay dentro del file.
    
    Write-Host "File : $file"

    #Ahora vemos si el contenido coinside con lo que estamos buscando.

    if($contenido -match "public\s+static\s+void\s+main\s*\(\s*String\s*\[\s*\]\s*\w+\s*\)") {
            
            $packageLine = $contenido | Where-Object { $_ -match "^package\s+([a-zA-Z0-9_.]+)\s*;" }
            if ($packageLine) {
                $package = ($packageLine -replace "^package\s+([a-zA-Z0-9_.]+)\s*;", '$1').Trim()
            } else {
                $package = ""
            }

            $classLine = $contenido | Where-Object { $_ -match "class\s+([a-zA-Z0-9_]+)" }
            if ($classLine) {
                $className = ($classLine -replace ".*class\s+([a-zA-Z0-9_]+).*", '$1').Trim()
            } else {
                $className = ""
            }

            if ($package -ne "") {
                return "$package.$className"
            } else {
                return $className
            }
        }
    }
    return $null
  }

#--------- Ahora ejecutamos la funcion Get-MainClass que creamos recien ----------

if($ejecutar -ne ""){  
  $claseMain = $ejecutar
  
  $expectativaPath = $ejecutar.Replace('.' , '\') + ".java"
  $found = $false
  
  foreach ($archivo in $javaArchivos){
    if($archivo.EndsWith($expectativaPath)){
      $found = $true
      break
    }
  }

}else{
  #Ejecutando la funcion.
  $claseMain = Get-MainClass -files $javaArchivos
}

#en el caso que no se haya encontrado:
if(-not $claseMain){
  write-host "no se ha encontrado ninguna clase con el metodo main, crea una y vuelve a copilar."
  exit 1
}

#En el caso de haberlo encontrado se ejecuta con javac.
Write-Host "Clase con el metodo main detectada : $claseMain"
javac -d $binDir -cp $classpath $javaArchivos

#En el caso que la copilacion sea existosa o no.
if ($LASTEXITCODE -eq 0){

Write-Host "Compilacion Exitosa."
Write-Host "Ejecutando...."
java -cp $classpath $javaArchivos

}else {
  Write-Host "Hubo un ERROR en plena copilacion."
}
