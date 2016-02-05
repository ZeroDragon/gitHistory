Git History  
====================  

Despliega un listado con todos los autores de un repositorio de git junto con la cantidad de commits que hicieron, cuando fue su último commit, en que repo lo hicieron (si se busca más de uno) y cuales fuero sus últimas palabras.

## Opciones  

**-r, --repo (REQUERIDO)**  
	El directorio donde está el repo a inspeccionar, si es especifica un directorio con muchos repositorios dentro, buscará en todos.  
	También se pueden especificar varios directorios.  

**-o, --orderby (OPCIONAL)**  
	El orden para mostrar los resultados, se puede ordenar por numero de commits (commits) o por el más nuevo al más antiguo (recent). Default: commits  

## Ejemplos de uso

**Ayuda**

	./gitHistory.coffee -h

**Directorio simple**  

	./gitHistory.coffee -r "direccion/a/mi/repo"


**Varios directorios**

	./gitHistory.coffee -r "direccion/a/mi/repo, direccion/a/otro/repo"


**Cambiando el ordenamiento**

	./gitHistory.coffee -r "direccion/a/mi/repo" -o recent

