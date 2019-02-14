# TP 4. MIPS.
# Script que traduce a instrucciones binarias el assembler del archivo "assembler_MIPS.txt".
# Arquitectura de Computadoras. FCEFyN. UNC.
# Anio 2019.
# Autores: Lopez Gaston, Kleiner Matias.


#Constantes 
WIDTH_MEM = 32
CANT_BITS_OPERANDO = 5
CANT_BITS_CEROS_R_TYPE = 5
CANT_BITS_CEROS_J1_TYPE = 15
CANT_BITS_CEROS_J2_TYPE = 5
CANT_BITS_OFFSET = 16
CANT_BITS_IMMEDIATE = 16
CANT_BITS_SIN_OPCODE = 26 #32 - OPCODE 
CANT_BITS_CEROS_I10_TYPE = 5
CANT_BITS_TARGET = 26
DEPTH_MEM = 2048
CANT_REGISTROS = 32
NOMBRE_DE_ARCHIVO =  'assembler_MIPS.txt'

#Funcion para escribir el archivo con las instrucciones binarias.
def FileHandler(cadena_global, nombre_de_archivo):
		try:
			file=open(nombre_de_archivo,'w')
			file.write(cadena_global)
			file.close()
		except:
 			print ('Error en el manejo del archivo. Fin.')
			exit(1)


# Funcion de traduccion del nombre de la instruccion a su opcode correspondiente (6 bits MSB).
def getOPCODE (instr):
    return {
		'LB': '100000',
		'LH': '100001',
		'LW': '100011',
		'LWU': '100111',
		'LBU': '100100',
		'LHU': '100101',
		'SB': '101000',
		'SH': '101001',
		'SW': '101011',
		'ADDI': '001000',
		'ANDI': '001100',
		'ORI':  '001101',
		'XORI': '001110',
		'LUI': '001111',
		'SLTI': '001010',
		'BEQ': '000100',
		'BNE': '000101',
		'J': '000010',
		'JAL': '000011',
    }.get (instr, '000000')  #000000 es el por defecto

# Funcion que clasifica a las instrucciones en base a su tipo y a su estructura interna.
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
		'JR': 'J0',
		'JALR': 'J1',
		'LB': 'I00',
		'LH': 'I00',
		'LW': 'I00',
		'LWU': 'I00',
		'LBU': 'I00',
		'LHU': 'I00',
		'SB': 'I00',
		'SH': 'I00',
		'SW': 'I00',
		'ADDI': 'I01',
		'ANDI': 'I01',
		'ORI': 'I01',
		'XORI': 'I01',
		'LUI': 'I10',
		'SLTI': 'I01',
		'BEQ': 'I11',
		'BNE': 'I11',
		'J': 'I100',
		'JAL': 'I100',
    }.get (instr, 'X')  #X es el por defecto


# Funcion que traduce a binario el nombre de un registro del tipo Rn. (Por ejemplo: R1 es 00001).
def getNumeroRegistro(reg):
	if (reg[0] != 'R'):
		print ('Notacion de registro erronea. Fin')
		exit (1)
	if (int(reg[1:]) > (CANT_REGISTROS - 1)):
		print ('No hay tantos registros. Fin')
		exit (1)
	registro = bin(int(reg[1:]))[2:]
	registro = registro [-5 : len(registro)]
	for i in range(0, CANT_BITS_OPERANDO - len(registro)): #Me agrega los ceros a la izq
		registro = '0' + registro
	return registro

# Funcion que devuelve para las instrucciones de Tipo R y de Tipo J los 6 bits LSB.
def getLSB (instr):
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
		'JR': '001000',
		'JALR': '001001',
    }.get (instr, '000000')  #000000 es el por defecto


#Funcion que efectua el control de que la cantidad de argumentos pasados en la instruccion sea la correcta. 
def controlCantArgumentos (argumentos, cantidad):
	if (len(argumentos) != cantidad):
		print ('Cantidad de argumentos invalida. Fin.')
		exit (1)

#Funcion que efectua el control de que dos registros no sean iguales. En caso de ser el mismo registro genera un error.
def controlIgualdadRegistros (registro1, registro2):
	print registro1
	print registro2
	if (registro1 == registro2):
		print ("Error. Los registros son iguales. Fin")
		exit (1)

#Inicio del programa.

print ('Inicio del programa')

#Lectura de archivo.
cadena_linea = ""

try:
	file = open (NOMBRE_DE_ARCHIVO, 'r')
	cadena_linea = file.read()
	file.close()
except:
	print ('Error en el manejo del archivo.')
	print ('Fin.')
	exit(1)

print ('\nContenido del archivo: ')
print cadena_linea


#Parseo del archivo.
print ('\nParseo del archivo: ')
arreglo_parseo = cadena_linea.split ('\n')
print arreglo_parseo

#Asignacion de constantes
patron = "#"
constantes_letras = []
constantes_numeros = []
for slot in arreglo_parseo:
	if (slot != ""):
		if (patron in slot):
			constantes_letras.append (slot [1])
			constantes_numeros.append (slot.split (" ")[1])

print ("\nConstantes: ")
print constantes_letras
print constantes_numeros


#Traduccion de instrucciones a binario.
patron_comment = "/"   #Es un comentario
arreglo_binario = []
cadena_binaria = ""
instruccion = ""
argumento = ""
for comando in arreglo_parseo:
	if ((comando != "") and (comando != " ") and (patron_comment not in comando) and (patron not in comando)):
		comando_parsed = comando.split (" ")
		instruccion = comando_parsed [0]
		if (instruccion != 'HLT'): # No es instruccion HALT.
			clasificacion_instruccion = getClasificacion (instruccion)
			if (clasificacion_instruccion == 'X'): #Instruccion desconocida.
				print ('Instruccion invalida. Fin.')
				exit(1)
			cadena_binaria = getOPCODE (instruccion) #Obtengo los 6 bits MSB de la instruccion.
			if (len (cadena_binaria) != 6):
				print ('OPCODE distinto de 6. Fin.\n')
				print (cadena_binaria)
				print (len(cadena_binaria))
				exit (1)
			
			#Split de parametros de la instruccion
			argumento = comando_parsed [1]
			argumento = argumento.split(",")
			
			# Tratamiento de instrucciones segun clasificacion
			if (clasificacion_instruccion == 'R00'):#Instrucciones SLL, SRL y SRA.
				controlCantArgumentos (argumento, 3)
				if (argumento[2] in constantes_letras):	#Reemplazo las constantes
					argumento[2] = constantes_numeros [ constantes_letras.index (argumento[2])]
				number_bin = bin(int(argumento[2]))[2:]
				for i in range(0, CANT_BITS_OPERANDO - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				cadena_binaria = cadena_binaria + '0' * CANT_BITS_CEROS_R_TYPE + getNumeroRegistro (argumento[1]) +\
				getNumeroRegistro (argumento[0]) + number_bin + getLSB (instruccion)
			
			elif (clasificacion_instruccion == 'R01'):#Instrucciones SLLV, SRLV y SRAV.
				controlCantArgumentos (argumento, 3)
				cadena_binaria = cadena_binaria +  getNumeroRegistro (argumento[2]) +\
				getNumeroRegistro (argumento[1]) +   getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_R_TYPE +\
				getLSB (instruccion)
			
			elif (clasificacion_instruccion == 'R10'):#Instrucciones ADDU, SUBU, AND, OR, XOR, NOR y SLT.
				controlCantArgumentos (argumento, 3)
				cadena_binaria = cadena_binaria +  getNumeroRegistro (argumento[1]) +\
				getNumeroRegistro (argumento[2]) +   getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_R_TYPE +\
				getLSB (instruccion)
			
			elif (clasificacion_instruccion == 'J0'):#Instruccion JR
				controlCantArgumentos (argumento, 1)
				cadena_binaria = cadena_binaria + getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_J1_TYPE +\
				getLSB (instruccion)
			
			elif (clasificacion_instruccion == 'J1'):#Instruccion JALR. Admite dos formatos.
				if (len(argumento) == 1):
					controlIgualdadRegistros (argumento[0], 'R31')
					cadena_binaria = cadena_binaria + getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_J2_TYPE +\
					'1' * CANT_BITS_OPERANDO + '0' * CANT_BITS_CEROS_J2_TYPE + getLSB (instruccion)
				elif (len(argumento)== 2):
					controlIgualdadRegistros (argumento[0], argumento[1])
					cadena_binaria = cadena_binaria + getNumeroRegistro (argumento[1]) + '0' * CANT_BITS_CEROS_J2_TYPE +\
					getNumeroRegistro (argumento[0]) + '0' * CANT_BITS_CEROS_J2_TYPE + getLSB (instruccion)
				else:
					print ('Instruccion JALR invalida. Fin')
					exit (1)
			
			elif (clasificacion_instruccion == 'I00'):#Instrucciones LH, LB, LW, LWU, LHU, LBU, SB, SH y SW.
				controlCantArgumentos (argumento, 2)
				pointer_array = argumento[1].split("{")
				pointer_array[1]=pointer_array[1][:len(pointer_array[1])-1]
				if (pointer_array[0] in constantes_letras):	#Reemplazo las constantes
					pointer_array[0] = constantes_numeros [ constantes_letras.index (pointer_array[0])]
				number_bin = bin(int(pointer_array[0]))[2:]
				for i in range(0, CANT_BITS_OFFSET - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				if ((int(pointer_array[0]) % 4) != 0):
					print ('Direccion no alineada. Fin.')
					exit (1)
				cadena_binaria = cadena_binaria + getNumeroRegistro (pointer_array[1]) + getNumeroRegistro (argumento[0]) +\
					number_bin


			elif (clasificacion_instruccion == 'I01'): #Instrucciones ADDI, ANDI, ORI, XORI y STLI.
				controlCantArgumentos (argumento, 3)
				if (argumento[2] in constantes_letras):	#Reemplazo las constantes
					argumento[2] = constantes_numeros [ constantes_letras.index (argumento[2])]
				number_bin = bin(int(argumento[2]))[2:]
				for i in range(0, CANT_BITS_IMMEDIATE - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				cadena_binaria = cadena_binaria + getNumeroRegistro (argumento[1]) + getNumeroRegistro (argumento[0]) +\
					number_bin

			elif (clasificacion_instruccion == 'I10'): #Instruccion LUI
				controlCantArgumentos (argumento, 2)
				if (argumento[1] in constantes_letras):	#Reemplazo las constantes
					argumento[1] = constantes_numeros [ constantes_letras.index (argumento[1])]
				number_bin = bin(int(argumento[1]))[2:]
				for i in range(0, CANT_BITS_IMMEDIATE - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				cadena_binaria = cadena_binaria + '0' * CANT_BITS_CEROS_I10_TYPE + getNumeroRegistro (argumento[0]) +\
					 number_bin
			

			elif (clasificacion_instruccion == 'I11'): #Instrucciones BEQ y BNE
				controlCantArgumentos (argumento, 3)
				if (argumento[2] in constantes_letras):	#Reemplazo las constantes
					argumento[2] = constantes_numeros [ constantes_letras.index (argumento[2])]
				number_bin = bin(int(argumento[2]))[2:]
				for i in range(0, CANT_BITS_OFFSET - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				cadena_binaria = cadena_binaria + getNumeroRegistro (argumento[0]) + getNumeroRegistro (argumento[1]) +\
					 number_bin
			

			elif (clasificacion_instruccion == 'I100'): #Instrucciones J y JAL
				controlCantArgumentos (argumento, 1)
				if (argumento[0] in constantes_letras):	#Reemplazo las constantes
					argumento[0] = constantes_numeros [ constantes_letras.index (argumento[0])]
				number_bin = bin(int(argumento[0]))[2:]
				for i in range(0, CANT_BITS_TARGET - len(number_bin)): #Me agrega los ceros a la izq
					number_bin = '0' + number_bin
				cadena_binaria = cadena_binaria + number_bin
				
				
		else: #Instruccion HALT
			cadena_binaria = '0' * WIDTH_MEM
		arreglo_binario.append (cadena_binaria)
		
print ("\nArreglo binario: ")
print (arreglo_binario)
print ("\n")

#Creacion de binario a guardar en mem.
cadena_global = ""
for i in range (len (arreglo_binario)):
	cadena_global = cadena_global + arreglo_binario [i] + "\n"

FileHandler (cadena_global, "init_ram_file.txt")

print ("Escritura de archivo correcta.")
print ("Se escribieron %d lineas con instrucciones.\n") % len(arreglo_binario)

print ('Fin')
