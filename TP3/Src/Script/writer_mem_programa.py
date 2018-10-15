# TP 3. BIP I.
# Arquitectura de Computadoras. FCEFyN. UNC.
# Anio 2018.
# Autores: Lopez Gaston, Kleiner Matias.

print 'Inicio del programa'

#Funcion para escribir el archivo con los coeficientes.
def FileHandler(cadenaGlobal, nombreDeArchivo):
		try:
			file=open(nombreDeArchivo,'w')
			file.write(cadenaGlobal)
			file.close()
		except:
			print 'Error en el manejo del archivo.'
			print 'Fin.'
			exit(1)
		
def FraccToBin(Fracc):
		for ptr2 in range(NBT):
			binarioStr+=str(bit[ptr2])
		return binarioStr



#Escritura de archivo.

cadena = ""
contadorCoef=0

TXfilterPF[::-1]

for indice3 in range(len(TXfilterPF)):
	contadorCoef+=1
	binario= FraccToBin(TXfilterPF[indice3])
	cadena+=binario + '\n'

for indice in range(72-contadorCoef): #Agregado de ceros al final para completar las 72 filas para poder armar la tabla.
	cadena+="00000000" + '\n'
nombreDeArchivo='.\coeficientesBinarios.txt'

FileHandler(cadena, nombreDeArchivo)

cadena=""
for indice4 in range(len(TXfilterPF)):
	cadena+=str(TXfilterPF[indice4]) + '\n'

nombreDeArchivo='.\CoeficientesFiltro.txt'

FileHandler(cadena,  nombreDeArchivo)



print 'Se escribio el archivo con %d coeficientes.' %contadorCoef


print 'Fin'
