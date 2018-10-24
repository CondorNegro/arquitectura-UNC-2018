# TP 3. BIP I.
# Script que traduce a instrucciones binarias el assembler del archivo "assembler_BIP_I.txt".
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


# Funcion de traduccion del nombre de la operacion a su opcode correspondiente.
def getOPCODE (x):
    return {
        'STO': '00001',
		'LD': '00010',
        'LDI': '00011',
		'ADD': '00100',
		'ADDI': '00101',
		'SUB': '00110',
		'SUBI': '00111',
		'HLT': '00000',
    }.get (x, '11111')  #11111 es el por defecto


#Constantes 
WIDTH_MEM = 16
CANT_BITS_OPERANDO = 11
DEPTH_MEM = 2048


#Lectura de archivo.
cadena_linea = ""
nombreDeArchivo =  'assembler_BIP_I.txt'


try:
	file = open (nombreDeArchivo, 'r')
	cadena_linea = file.read()
	file.close()
except:
	print 'Error en el manejo del archivo.'
	print 'Fin.'
	exit(1)

print '\nContenido del archivo: '
print cadena_linea


#Parseo del archivo.
print '\nParseo del archivo: '
arreglo_parseo = cadena_linea.split ('\n')
print arreglo_parseo

#Asignacion de constantes
Patron = "#"
constantes_letras = []
constantes_numeros = []
for slot in arreglo_parseo:
	if (slot != ""):
		if (Patron in slot):
			constantes_letras.append (slot [1])
			constantes_numeros.append (slot.split (" ")[1])

print "\nConstantes: "
print constantes_letras
print constantes_numeros


#Traduccion de instrucciones a binario.
Patron_comment = "/"   #Es un comentario
arreglo_binario = []
cadena_binaria = ""
instruccion = ""
argumento = ""
for comando in arreglo_parseo:
	if ((comando != "") and (comando != " ") and (Patron_comment not in comando) and (Patron not in comando)):
		comando_parsed = comando.split (" ")
		instruccion = comando_parsed [0]
		cadena_binaria = getOPCODE (instruccion)
		if (instruccion != 'HLT'):
			argumento = comando_parsed [1] 
			if (argumento in constantes_letras):	#Reemplazo las constantes
				argumento = constantes_numeros [ constantes_letras.index (argumento)]
			number_bin = bin(int(argumento))[2:]
			#print len(number_bin)
			for i in range(0, CANT_BITS_OPERANDO - len(number_bin)): #Me borra los ceros a la izq
				number_bin = '0' + number_bin
			cadena_binaria = cadena_binaria + number_bin
		else: #Instruccion HALT
			cadena_binaria = cadena_binaria + '0' * CANT_BITS_OPERANDO
		arreglo_binario.append (cadena_binaria)
		#print cadena_binaria

print "\nArreglo binario: "
print arreglo_binario
print "\n"

#Creacion de binario a guardar en mem.
cadena_global = ""
for i in range (len (arreglo_binario)):
	cadena_global = cadena_global + arreglo_binario [i] + "\n"
for i in range (DEPTH_MEM - len (arreglo_binario)):
	if (i < (DEPTH_MEM - 1 - len (arreglo_binario))):
		cadena_global = cadena_global + '0' * WIDTH_MEM + "\n"
	else:
		cadena_global = cadena_global + '0' * WIDTH_MEM

FileHandler (cadena_global, "init_ram_file.txt")

print "Escritura de archivo correcta."
print "Se escribieron %d lineas con instrucciones.\n" % len(arreglo_binario)

print 'Fin'
