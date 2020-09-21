use "D:\Bases de datos\EDUC\EDUC 2019\Módulos\Carátula única sede educativa.dta", clear

keep if NOVEDAD_NOMBRE == "Rinde" | NOVEDAD_NOMBRE == "Imputada"
keep SEDE_CODIGO SEDE_DIRECCION CODIGOINTERNODEPTO CODIGOINTERNOMUNI MUNI DEPTO

export excel using "D:\Icfes\SAyD\Referentes\direcciones_sedes.xlsx", firstrow(variables) replace


/*
	Limpieza de direcciones de Bogotá
*/

keep if CODIGOINTERNOMUNI=="11001"

gen direccion = SEDE_DIRECCION

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