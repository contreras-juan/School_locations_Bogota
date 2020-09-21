use "D:\Bases de datos\EDUC\EDUC 2019\Módulos\Carátula única sede educativa.dta", clear

keep if NOVEDAD_NOMBRE == "Rinde" | NOVEDAD_NOMBRE == "Imputada"
keep SEDE_CODIGO SEDE_DIRECCION CODIGOINTERNODEPTO CODIGOINTERNOMUNI MUNI DEPTO

export excel using "D:\Icfes\SAyD\Referentes\direcciones_sedes.xlsx", firstrow(variables) replace


/*
	Limpieza de direcciones de Bogotá
*/

ssc install georoute,replace
ssc install insheetjson, replace
ssc install libjson, replace

keep if CODIGOINTERNOMUNI=="11001"

gen direccion = SEDE_DIRECCION

**Normalización direcciones
replace direccion=subinstr(direccion,"."," ",.)
replace direccion=subinstr(direccion,"-"," ",.)
replace direccion=subinstr(direccion,"#"," ",.)
replace direccion=subinstr(direccion,";"," ",.)
replace direccion=subinstr(direccion,":"," ",.)
replace direccion=subinstr(direccion,","," ",.)
replace direccion=subinstr(direccion,"_"," ",.)
replace direccion=subinstr(direccion,"="," ",.)
replace direccion=subinstr(direccion,""," ",.)
replace direccion=subinstr(direccion,"NO"," ",.)
replace direccion=subinstr(direccion,"NUMERO"," ",.)
replace direccion=subinstr(direccion,"NúMERO"," ",.)
replace direccion=subinstr(direccion,"NúMERO", " ",.)
replace direccion=subinstr(direccion,"NUM", " ",.)
replace direccion=subinstr(direccion,"NúM", " ",.)
replace direccion=subinstr(direccion,"N°", " ",.)
replace direccion=subinstr(direccion,"Nª", " ",.)
replace direccion=subinstr(direccion,"ª", "",.)

split direccion, parse(" ")

tab direccion1

*Avenida calle
replace direccion1 = subinstr(direccion1, "AC", "Avenida Calle", .) 

* Avenida carrera
replace direccion1 = subinstr(direccion1, "AK", "Avenida Carrera", .)

* Autopista
replace direccion1 = subinstr(direccion1, "AU", "Autopista", .)

* Avenida
replace direccion1 = subinstr(direccion1, "AV", "Avenida", .)

* Calle
replace direccion1 = subinstr(direccion1, "C", "Calle", .) if direccion1 == "C"
replace direccion1 = subinstr(direccion1, "CL", "Calle", .) if direccion1 == "CL"

* Circular
replace direccion1 = subinstr(direccion1, "CQ", "Circular", .)

* Carretera
replace direccion1 = subinstr(direccion1, "CT", "Carretera", .)

* Carrera
replace direccion1 = subinstr(direccion1, "KR", "Carrera", .)

* Diagonal
replace direccion1 = subinstr(direccion1, "DG", "Diagonal", .)

* Peatonal
replace direccion1 = subinstr(direccion1, "PT", "Peatonal", .)

* Transversal
replace direccion1 = subinstr(direccion1, "TV", "Transversal", .)

* Vereda
replace direccion1 = subinstr(direccion1, "VDA", "Vereda", .)

tab direccion1

/*
	Eliminar barrio y caracteres subsiguientes
*/
forvalues i=1(1)17{

	dis "ronda `i'"
	local f = `i' + 1
	
	forvalues j = `f'(1)18{
		replace direccion`j'="" if direccion`i'=="BARRIO"
	}
	
	replace direccion`i'="" if direccion`i'=="BARRIO"
}


forvalues i=1(1)17{

	dis "ronda `i'"
	local f = `i' + 1
	
	forvalues j = `f'(1)18{
		replace direccion`j'="" if direccion`i'=="BR"
	}
	
	replace direccion`i'="" if direccion`i'=="BR"
}


gen direccion_comp = direccion1 + " " + direccion2 + " " + direccion3 + " " + direccion4 + " " + direccion5 + " " + direccion6 + " " + direccion7 + " " + direccion8 + " " + direccion9 + " " + direccion10 + " " + direccion11 + " " + direccion12 + " " + direccion13 + " " + direccion14 + " " + direccion15 + " " + direccion16 + " " + direccion17 + " " +direccion18

replace direccion_comp = trim(direccion_comp)

*Una direccion incial que necesita el comando, se uso la misma del codigo base.

gen dir="Carrera 6 80 A 33"
gen city="Bogota"
gen country="Colombia"

set seed 1234
*Si la muestra es muy grande es preferible dividir en más grupos. 
gen u=runiformint(1,10)

ren CODIGOINTERNOMUNI siti_id
gen id = _n
keep direccion_comp dir city country siti_id u id

*Separar aleatoriamente base por partes para que el algoritmo sea más eficiente 

cd "D:\Icfes\SAyD\Referentes\georeferencia"

local j=1
forvalues a=1(1)10{
	dis "`j'"
	preserve
	keep if u==`a'

	/*
		El codigo para georefenciar se llama georoute. Este codigo utiliza el API Here Maps. Para empezar a correr este codigo primero debes crear una cuenta
		gratuita en la siguiente pagina web https://developer.here.com/. Una vez la crees puedes obtener un APP ID y un APP CODE, los culaes debes colocar en la linea de
		codigo 107. Adicionalmente se debe instalar el comando, para esto usar las lineas de codigo siguiente
	*/

	*Adicionalmente se separa en grupos mas pequeños. 
	egen setsecman=group(siti_id)
	sum setsecman

	forvalue i=1/`r(max)' {
	
		dis "`i'/`r(max)'"

		georoute if setsecman==`i' ,replace herekey(G1HvbPpVVpwVnI7SEUPD3G-hWeDH52La7v4I0a58aME) ///
		 startaddress(dir city country) endaddress(direccion_comp city country) coordinates(init_`i' end_`i') ///
		 distance(dis) time(time) diagnostic(diag) timer

 
		rename end_`i'_x end_x_`i'
		 
		rename end_`i'_y end_y_`i'
		 
		rename end_`i'_match end_match_`i'
		 
		drop init* diag dis time
 
 }


	 *En las variables cond_end_x y cond_end_y quedan las coordenas latlong de cada direccion
	egen cond_end_x=rowmax(end_x*)
	egen cond_end_y=rowmax(end_y*)
	/*En la variable cond_end_match queda condensada que tan buena fue la georeferenciacion de cada direccion:

	1 = exact

	2 = ambiguos

	3 = upHierarchy

	4 = ambiguousUpHierarchy

	Esta es una escala, donde 4 es la peor calidad de georeferenciacion
	*/

	egen cond_end_match=rowmax(end_match*)
	 
	drop end_x* end_y* end_match*
	 
	keep  direccion_comp u id cond_end_x cond_end_y cond_end_match
	 
	save "sedes_referencia_`j'", replace
	restore

	local j=`j'+1
}

use sedes_referencia_1, clear
forvalues j=2(1)10{
	append using sedes_referencia_`j'
}