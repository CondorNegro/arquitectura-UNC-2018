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
		FraccAux=(Fracc*1.0)*(2**NBF)
		binarioStr=""
		bit=[0]*NBT
		ResultadoAuxiliar=0
		if(Fracc >= 0):
			bit[0]=0
		else:
			bit[0]=1
			FraccAux-=(-2)**7
		for ptr in range(NBT-2,-1,-1):
			ResultadoAuxiliar=FraccAux-2**ptr
			if(ResultadoAuxiliar>=0):
				bit[NBT-1-ptr]=1
				FraccAux=ResultadoAuxiliar
			else:
				bit[NBT-1-ptr]=0
				
		
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
