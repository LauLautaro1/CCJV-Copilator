#Setteando Proyecto Java normal.

param(
  [string]$NombreProyecto = "SinNombre"
)

#---------- Creacion De las carpetas ----------

#Ahora Creamos la estructura de carpetas.

# 1 - Creamos la carpeta Principal del proyecto.

New-Item -Path $NombreProyecto -ItemType Directory -Force | Out-Null

# 2 - Creamos La carpeta "src" la cual sera donde ira el codigo y los paquetes java..

#aca tenemos variables que nos indican las rutas de las carpetas.
$srcPath = "$NombreProyecto\src"
$binPath = "$NombreProyecto\bin"
$libPath = "$NombreProyecto\lib"
$docPath = "$NombreProyecto\docs"

#Aca tenemos la ruta del packete principal por defecto.
$packagePath = "$srcPath\main"

#Creando un array para crear todas las carpetas necesarias.
$arrayDePaths =@($srcPath , $binPath , $libPath , $docPath , $packagePath)

for($i = 0;$i -lt $arrayDePaths.Count;$i++){
  New-Item -Path $arrayDePaths[$i] -ItemType Directory -Force | Out-Null
  Write-Host "Se ha creado la carpeta : $arrayDePaths[$i]"
}

#---------- Creacion Del Main.Java ----------

#Ahora creamos el archivo .java (Main.java).

$MainContenido = @"
package main;

public class Main {
    public static void main(String[] args) {
        //Automaticamente Generado con JavaChad.
        System.out.println("Hola desde $NombreProyecto!");
    }
}
"@

$MainContenido | Set-Content -Path "$packagePath\Main.java"

#---------- Creacion Del .project ----------

#Llamamos el script de la creacion del .project

./CrearArchivoProject.ps1 -NombreProyecto $NombreProyecto

#---------- Creacion Del Copilador ----------

#Para esto copiamos el codigo del ps1 copilador que es otro script que cree.
$origen = "CrearCopiladorJavaBasico.ps1"
$destino = "$NombreProyecto\Copilador.ps1"

if(Test-Path $origen){
  Get-Content $origen | Set-Content $destino
  Write-Host "Copilador Creado!."
}else{
  Write-Host "Hubo un error al crear el copilador. No se a encontrado $origen"
}

Write-Host "Finish."
