# TP 4. MIPS.
# Script que traduce a instrucciones binarias el assembler del archivo "assembler_MIPS.txt".
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
def getOPCODE (clasificacion):
    return {
		'I1-0': '100000',
		'I1-1': '100001',
		'I1-3': '100011',
		'I1-7': '100111',
		'I1-4': '100100',
		'I1-5': '100101',
		'I1-8': '101000',
		'I1-9': '101001',
		'I1-11': '101011',
		'I0-8': '001000',
		'I0-12': '001100',
		'I0-13': '001101',
		'I0-14': '001110',
		'I0-15': '001111',
		'I0-10': '001010',
		'I0-4': '000100',
		'I0-5': '000101',
		'I0-2': '000010',
		'I0-3': '000011',
    }.get (clasificacion, '000000')  #000000 es el por defecto

def getClasificacion (instr):
	return {
        'SLL': 'R00',
		'SRL': 'R00',
		'SRA': 'R00',
		'SLLV': 'R01',
		'SRLV': 'R01',
		'SRAV': 'R01',
		'ADDU': 'R10',
		'SUBU': 'R10',
		'AND': 'R10',
		'OR': 'R10',
		'XOR': 'R10',
		'NOR': 'R10',
		'SLT': 'R10',
		'JR': 'J',
		'JALR': 'J',
		'LB': 'I1-0',
		'LH': 'I1-1',
		'LW': 'I1-3',
		'LWU': 'I1-7',
		'LBU': 'I1-4',
		'LHU': 'I1-5',
		'SB': 'I1-8',
		'SH': 'I1-9',
		'SW': 'I1-11',
		'ADDI': 'I0-8',
		'ANDI': 'I0-12',
		'ORI': 'I0-13',
		'XORI': 'I0-14',
		'LUI': 'I0-15',
		'SLTI': 'I0-10',
		'BEQ': 'I0-4',
		'BNE': 'I0-5',
		'J': 'I0-2',
		'JAL': 'I0-3',
    }.get (instr, 'X')  #000000 es el por defecto

def getNumeroRegistro(R):
	registro = bin(int(R[1:]))[2:]
	registro = registro [len(registro) - 6 : len(registro)]
	for i in range(0, CANT_BITS_OPERANDO - len(registro)): #Me borra los ceros a la izq
		registro = '0' + registro
	return registro

def getLSBR (instr):
	return {
        'SLL': '000000',
		'SRL': '000010',
		'SRA': '000011',
		'SLLV': '000100',
		'SRLV': '000110',
		'SRAV': '000111',
		'ADDU': '100001',
		'SUBU': '100011',
		'AND': '100100',
		'OR': '100101',
		'XOR': '100110',
		'NOR': '100111',
		'SLT': '101010',
    }.get (instr, '000000')  #000000 es el por defecto









#Constantes 
WIDTH_MEM = 32
CANT_BITS_OPERANDO = 5
CANT_BITS_CEROS_R_TYPE = 5
CANT_BITS_SIN_OPCODE = 26 #32 - OPCODE 
DEPTH_MEM = 2048


#Lectura de archivo.
cadena_linea = ""
nombreDeArchivo =  'assembler_MIPS.txt'


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
		if (instruccion != 'HLT'):
			clasificacion_instruccion = getClasificacion (instruccion)
			if (clasificacion_instruccion == 'X'):
				print 'Instruccion invalida. Fin.'
				exit(1)
			cadena_binaria = getOPCODE (clasificacion_instruccion)
			if (len (cadena_binaria) != 6):
				print 'OPCODE distinto de 6. Fin.\n'
				print cadena_binaria
				print len(cadena_binaria)
				exit (1)
			
			argumento = comando_parsed [1]
			argumento = argumento.split(",")
			
			if (clasificacion_instruccion == 'R00'):
				if (argumento[2] in constantes_letras):	#Reemplazo las constantes
					argumento[2] = constantes_numeros [ constantes_letras.index (argumento[2])]
				number_bin = bin(int(argumento[2]))[2:]
				for i in range(0, CANT_BITS_OPERANDO - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				#print len(number_bin)
				cadena_binaria = cadena_binaria + '0' * CANT_BITS_CEROS_R_TYPE + getNumeroRegistro (argumento[1]) +\
				getNumeroRegistro (argumento[0]) + number_bin + getLSBR (instruccion)
			
			elif (clasificacion_instruccion == 'R01'):
				#print len(number_bin)
			    #print getNumeroRegistro (argumento[2])
				cadena_binaria = cadena_binaria +  getNumeroRegistro (argumento[2]) +\
				getNumeroRegistro (argumento[1]) +   getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_R_TYPE +\
				getLSBR (instruccion)
			
			elif (clasificacion_instruccion == 'R10'):
				#print len(number_bin)
				#print getNumeroRegistro (argumento[2])
				cadena_binaria = cadena_binaria +  getNumeroRegistro (argumento[1]) +\
				getNumeroRegistro (argumento[2]) +   getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_R_TYPE +\
				getLSBR (instruccion)
				
		else: #Instruccion HALT
			cadena_binaria = '0' * WIDTH_MEM
		arreglo_binario.append (cadena_binaria)
		#print cadena_binaria

print "\nArreglo binario: "
print arreglo_binario
print "\n"

#Creacion de binario a guardar en mem.
cadena_global = ""
for i in range (len (arreglo_binario)):
	cadena_global = cadena_global + arreglo_binario [i] + "\n"

FileHandler (cadena_global, "init_ram_file.txt")

print "Escritura de archivo correcta."
print "Se escribieron %d lineas con instrucciones.\n" % len(arreglo_binario)

print 'Fin'
