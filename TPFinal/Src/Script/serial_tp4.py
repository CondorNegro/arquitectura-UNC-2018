# TP 4. MIPS.
# Arquitectura de Computadoras. FCEFyN. UNC.
# Anio 2019.
# Autores: Lopez Gaston, Kleiner Matias.

try:
    from Tkinter import *
except ImportError:
    raise ImportError,"Se requiere el modulo Tkinter"

# coding: utf-8
import time 			# Para sleeps
import serial			# Comunicacion serie
from serial import *	# Comunicacion serie
import os				# Funciones del Sistema Operativo
import threading  		# Para uso de threads
import math
 
#Constantes 
BAUDRATE = 9600
WIDTH_WORD = 8
CANT_BITS_INSTRUCCION = 32
CANT_STOP_BITS = 2
FILE_NAME = "init_ram_file.txt"
FLAG_TEST = False
CANT_BITS_ADDRESS_MEM_PROGRAMA = 10
CANT_REGSITROS = 32
CANT_BITS_ADDR_REGISTROS = int (math.log(CANT_REGSITROS, 2))
CANT_BITS_ALU_CTRL = 4
CANT_BITS_ALU_OP = 2
HALT_INSTRUCTION = '1' * CANT_BITS_INSTRUCCION

# Variables globales

ser = serial.Serial()
bandera_puerto_loop = 0
estado_puerto = "NO CONECTADO"
etiqueta_resultado_impresion = "Resultado"
etiqueta_resultado_modo_de_ejecucion = ""
etiqueta_resultado_modo_de_ejecucion_valor_MIPS = ""
etiqueta_resultado_pc = ""
etiqueta_resultado_adder_pc = ""
etiqueta_contador_ciclos = ""
etiqueta_instruction_fetch = ""
etiqueta_branch_dir = ""
etiqueta_control_salto = ""
etiqueta_dato_reg_A = ""
etiqueta_dato_reg_B = ""
etiqueta_valor_inmediato = ""
etiqueta_rs = ""
etiqueta_rd = ""
etiqueta_rt = ""
etiqueta_reg_dst = ""
etiqueta_mem_to_reg = ""
etiqueta_alu_op = ""
etiqueta_alu_ctrl = ""
etiqueta_alu_src = ""
etiqueta_mem_read = ""
etiqueta_mem_write = ""
etiqueta_reg_write = ""
lock = threading.Lock()
modo_ejecucion = 0 #0: continuo - 1: debug


# Funcion que efectua la lectura de un archivo y devuelve su contenido.
def fileReader (file_name):
	cadena_linea = ""
	try:
		file = open (file_name, 'r')
		cadena_linea = file.read()
		file.close()
		return cadena_linea
	except:
		print ('Error en el manejo del archivo.')
		print ('Fin.')
		exit(1)
	

# Funcion de traduccion del nombre de la operacion a su binario correspondiente.
def getCode (x):
    return {
        'Soft reset': '00000000',
		'Soft reset ack': '00000001',
        'Send instructions': '10000000',
		'Start MIPS': '11000000',
		'PC-H' : '00010000',
		'PC-L' : '00001000',
		'CC-H' : '00011000',
		'CC-L' : '00000100',
		'PCAdd-H': '00010100',
		'PCAdd-L': '00001100',
		'IF-3' : '00011100',
		'IF-2' : '00000010',
		'IF-1' : '00010010',
		'IF-0' : '00001010',
		'BR-H' : '00011010', #Branch
		'BR-L' : '00000110',
		'DA-3' : '00010110', #Dato A
		'DA-2' : '00001110',
		'DA-1' : '00011110',
		'DA-0' : '00000001',
		'DB-3' : '00010001', #Dato B
		'DB-2' : '00001001',
		'DB-1' : '00011001',
		'DB-0' : '00000101',
		'IM-3' : '00010101', #Valor inmediato con extension de signo
		'IM-2' : '00001101',
		'IM-1' : '00011101',
		'IM-0' : '00000011',
		'AR-H' : '00010011', #Address registers
		'AR-L' : '00001011',
		'SC-H' : '00011011', #Signals controls
		'SC-L' : '00000111'
    }.get (x, '11111111')  #11111111 es el por defecto


def getHexadecimal (binario):
	arrayHex = ['A', 'B', 'C', 'D', 'E', 'F']
	resultado = ""
	grupoCuatro = ''
	if ( (len(binario) > 0) and ((len(binario)% 4) == 0) ):
		for i in range(0, len(binario), 4):
			grupoCuatro = binario[i : i + 4]
			
			try:
				decimal =  int (grupoCuatro, 2)
				if (decimal > 9 and decimal < 16):
					resultado = resultado + arrayHex [decimal - 10]
				else:
					resultado = resultado + str (decimal)
				
			except:
				print 'Decimal invalido en getHexadecimal.'
				exit (1)
			

	else:
		print 'Binario incompleto en getHexadecimal.'
		return binario
	
	return resultado
		


# Funcion para desactivar botones
def desactivarBotones():
	lock.acquire()
	botonDesconectarFPGA.config (state = DISABLED)
	botonSoftReset.config (state = DISABLED)
	botonSendInstructions.config (state = DISABLED)
	botonSetModoEjecucion.config (state = DISABLED)
	botonIniciarMIPS.config (state = DISABLED)
	lock.release()

# Funcion para activar botones, segun el modo pasado como parametro. Los demas botones no especificados 
# en los distintos modos se colocan como DISABLED.
# Modos: 0- Activacion del boton de desconexion con FPGA.
# 		 1- Activacion del boton de desconexion con FPGA y del boton de soft reset.
# 		 2- Activacion del boton de desconexion con FPGA y del boton de enviar instrucciones.
#        3- Activacion del boton de desconexion con FPGA y del boton Set modo de ejecucion.
#        4- Activacion del boton de desconexion con FPGA, del boton Set modo de ejecucion y del boton Iniciar MIPS.
def activarBotones (modo):
	lock.acquire()
	if (modo == 0):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonSoftReset.config (state = DISABLED)
		botonSendInstructions.config (state = DISABLED)
		botonSetModoEjecucion.config (state = DISABLED)
		botonIniciarMIPS.config (state = DISABLED)
	elif (modo == 1):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonSoftReset.config (state = ACTIVE)
		botonSendInstructions.config (state = DISABLED)
		botonSetModoEjecucion.config (state = DISABLED)
		botonIniciarMIPS.config (state = DISABLED)
	elif (modo == 2):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonSoftReset.config (state = DISABLED)
		botonSendInstructions.config (state = ACTIVE)
		botonSetModoEjecucion.config (state = DISABLED)
		botonIniciarMIPS.config (state = DISABLED)
	elif (modo == 3):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonSoftReset.config (state = DISABLED)
		botonSendInstructions.config (state = DISABLED)
		botonSetModoEjecucion.config (state = ACTIVE)
		botonIniciarMIPS.config (state = DISABLED)
	elif (modo == 4):
		botonDesconectarFPGA.config (state = ACTIVE)
		botonSoftReset.config (state = DISABLED)
		botonSendInstructions.config (state = DISABLED)
		botonSetModoEjecucion.config (state = ACTIVE)
		botonIniciarMIPS.config (state = ACTIVE)
	else:
		print 'Modo invalido. Fin'
		exit (1)	
	lock.release()


# Funcion para conectar FPGA

def conectarFPGA(puerto):
	try:
		HiloConexion = threading.Thread (target = conexionViaThread, args = (puerto,)) 
		HiloConexion.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'


# Funcion que ejecuta el thread de la conexion
	
def conexionViaThread(puerto):
	global bandera_puerto_loop
	global ser
	global estado_puerto
	global currentState
	
	print 'Thread de conexion/desconexion OK.'
	try:
		if (puerto == "disconnect" and estado_puerto != "NO CONECTADO"):
			estado_puerto = "NO CONECTADO"
			etiquetaPuertoEstado.config (text = estado_puerto, fg = "red")
			desactivarBotones()
			botonConectarFPGA.config (state = ACTIVE)
			bandera_puerto_loop = 0
			ser.close()
			print 'Desconexion de puerto.'
		elif bandera_puerto_loop == 0:
			if puerto == "loop":
				ser = serial.serial_for_url ('loop://', timeout = 1)  #Configuracion del loopback test de esta forma
				ser.isOpen()        #Abertura del puerto.
				ser.timeout = None  #Siempre escucha
				ser.flushInput()	#Limpieza de buffers
				ser.flushOutput()
				estado_puerto = "loop - OK"
				etiquetaPuertoEstado.config (text = estado_puerto, fg = "dark green")
				activarBotones (1)
				print 'Loop-ok: ', puerto
			else:
				try:
					ser=serial.Serial(
							port = puerto, #Configurar con el puerto
							baudrate = BAUDRATE,
							parity = serial.PARITY_NONE,
							stopbits = CANT_STOP_BITS, #Cant de bits de stop
							bytesize = WIDTH_WORD
					)
					estado_puerto = str (puerto) + " - OK"
					etiquetaPuertoEstado.config (text = estado_puerto, fg = "dark green")
					bandera_puerto_loop = 1
					ser.isOpen()        	#Abertura del puerto.
					ser.timeout = None    	#Siempre escucha
					ser.flushInput()		#Limpieza de buffers
					ser.flushOutput()
					activarBotones (1)
					print 'Conexion OK en puerto : ', puerto
				except SerialException:
					estado_puerto = str (puerto) + " - ERROR"
					etiquetaPuertoEstado.config (text = estado_puerto, fg = "red")
					desactivarBotones()
					botonConectarFPGA.config(state = ACTIVE)
					print 'Error al tratar de abrir el puerto:', puerto
		else :
			print "Puerto ya configurado"
	except: 
		print 'Error en la conexion/desconexion.'
		activarBotones (0)

# Funcion para enviar un byte al MIPS por UART
def writeSerial (data):
	global etiqueta_resultado_impresion
	try:
		if (not FLAG_TEST):
			ser.write (chr (int (data, 2)))
		else:
			print data
			print ((int (data, 2)))
		time.sleep (1.0) #Espera.
		return 0
	except:
		print ("Error en la funcion writeSerial. Info a enviar invalida.")
		etiqueta_resultado_impresion = "Error en la funcion writeSerial. Data invalida."
		etiquetaResultado.config (text = etiqueta_resultado_impresion, fg = "red")
		return -1 


# Funcion que recibe los datos obtenidos de la FPGA via UART. Puede efectuar una comparacion de los datos recibidos
# con una cadena enviada como parametro si la misma es distinta a la cadena vacia.
# Imprime un mensaje y el valor obtenido en la GUI. 
# Devuelve -1 en caso de error y 0 en caso de una lectura correcta. 
def readResultado (cantBytes, cadenaComparacion):
	if (cantBytes < 0):
		print ("Error en la funcion readResultado. Cantidad de bytes a leer invalida.")
		exit (1)
	if (cadenaComparacion != ''):
		if (len(cadenaComparacion) != (8 * cantBytes)):
			print ("Error en la funcion readResultado. Cadena de comparacion invalida.")
			exit (1)
	contador_bytes = 0
	time.sleep (0.2)
	global etiqueta_resultado_impresion
	if (not FLAG_TEST):
		while ((ser.inWaiting() > 0) and (contador_bytes < cantBytes)): #inWaiting -> cantidad de bytes en buffer esperando.
			contador_bytes = contador_bytes + 1
			lectura = ser.read (1)
			etiqueta_resultado_impresion = bin(ord (lectura))[2:][::-1]
			for i in range (0, 8 - len(etiqueta_resultado_impresion), 1):
				if (i != 8):	
					etiqueta_resultado_impresion = etiqueta_resultado_impresion + '0'
			print '>>',
			print etiqueta_resultado_impresion
			print '>>',
			print lectura
		if (cadenaComparacion != ''):
			if (cadenaComparacion == etiqueta_resultado_impresion):
				etiquetaResultado.config (text = "Valor obtenido:  " + etiqueta_resultado_impresion, fg = "dark green")
			else:
				etiquetaResultado.config (text = "Valor obtenido invalido", fg = "red")
				return -1 #Error
		else:
			etiquetaResultado.config (text = "Valor obtenido:  " + etiqueta_resultado_impresion, fg = "dark green")
	return 0


# Funcion que recibe los datos obtenidos de la FPGA via UART.
# Devuelve el valor leido.
# No imprime nada en la GUI.
def readResultadoEjecucion (cantBytes):
	if (cantBytes < 0):
		print ("Error en la funcion readResultado. Cantidad de bytes a leer invalida.")
		exit (1)
	
	contador_bytes = 0
	time.sleep (0.2)
	resultado = ""
	if (not FLAG_TEST):
		while ((ser.inWaiting() > 0) and (contador_bytes < cantBytes)): #inWaiting -> cantidad de bytes en buffer esperando.
			contador_bytes = contador_bytes + 1
			lectura = ser.read (1)
			resultado = bin(ord (lectura))[2:][::-1]
			for i in range (0, 8 - len(resultado), 1):
				if (i != 8):	
					resultado = resultado + '0'
			print '>>',
			print resultado
			print '>>',
			print lectura
		
	else:
		contador_bytes = cantBytes
		resultado = "00000000"
	
	return [resultado, contador_bytes]



# Funcion que recibe valores obtenidos de la FPGA via UART. Estos datos corresponden a:
#  Contador de programa.
#  Contador de ciclos.
#  Valores intermedios en los latches.
def recibirDatosFromFPGA ():
	global etiqueta_resultado_pc
	global etiqueta_contador_ciclos
	global etiqueta_resultado_adder_pc
	global etiqueta_instruction_fetch
	global etiqueta_branch_dir
	global etiqueta_control_salto
	global etiqueta_dato_reg_A
	global etiqueta_dato_reg_B
	global etiqueta_valor_inmediato
	global etiqueta_rs
	global etiqueta_rd
	global etiqueta_rt
	global etiqueta_reg_dst
	global etiqueta_mem_to_reg
	global etiqueta_alu_op
	global etiqueta_alu_ctrl
	global etiqueta_alu_src
	global etiqueta_mem_read
	global etiqueta_mem_write
	global etiqueta_reg_write
		
	
	flag_receive = True
	contador_de_programa = ""
	contador_de_programa_aux = ""
	contador_de_ciclos = ""
	contador_de_ciclos_aux = ""
	adder_contador_de_programa = ""
	adder_contador_de_programa_aux = ""
	instruction_fetch = ""
	instruction_fetch_aux = ""
	branch_dir = ""
	branch_dir_aux = ""
	control_salto = ""
	control_salto_aux = ""
	dato_reg_A = ""
	dato_reg_A_aux = ""
	dato_reg_B = ""
	dato_reg_B_aux = ""
	valor_inmediato = ""
	valor_inmediato_aux = ""
	rs = ""
	rs_aux = ""
	rd = ""
	rd_aux = ""
	rt = ""
	rt_aux = ""
	reg_dst = ""
	reg_dst_aux = ""
	mem_to_reg = ""
	mem_to_reg_aux = ""
	alu_op = ""
	alu_op_aux = ""
	alu_ctrl = ""
	alu_ctrl_aux = ""
	alu_src = ""
	alu_src_aux = ""
	mem_read = ""
	mem_read_aux = ""
	mem_write = ""
	mem_write_aux = ""
	reg_write = ""
	reg_write_aux = ""
	

	contador_etapas = 0
	contador_subetapas = 0
	cantidad_bytes_control = 0


	while (flag_receive):

		if (contador_etapas == 0): #PC

			if (contador_subetapas == 0): #Parte H
				contador_de_programa, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('PC-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: #Parte L
				contador_de_programa_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('PC-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_de_programa = contador_de_programa + contador_de_programa_aux
						etiqueta_resultado_pc = contador_de_programa
						etiquetaPCValorMIPS.config (text = etiqueta_resultado_pc)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0 
				

		elif (contador_etapas == 1): #Contador de ciclos

			if (contador_subetapas == 0): # Parte H
				contador_de_ciclos, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('CC-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: # Parte L
				contador_de_ciclos_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('CC-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_de_ciclos = contador_de_ciclos + contador_de_ciclos_aux
						etiqueta_contador_ciclos = contador_de_ciclos
						etiquetaContadorCiclosValorMIPS.config (text = etiqueta_contador_ciclos)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0 


		elif (contador_etapas == 2): #Adder IF 

			if (contador_subetapas == 0): #Parte H
				adder_contador_de_programa, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('PCAdd-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: #Parte L
				adder_contador_de_programa_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('PCAdd-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						adder_contador_de_programa = adder_contador_de_programa + adder_contador_de_programa_aux
						etiqueta_resultado_adder_pc = adder_contador_de_programa
						etiquetaPCAddValorMIPS.config (text = etiqueta_resultado_adder_pc)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0 
		
		elif (contador_etapas == 3): #Instruction (output IF)

			if (contador_subetapas == 0): # Parte 3
				instruction_fetch, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IF-3'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			if (contador_subetapas == 1): # Parte 2
				instruction_fetch_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IF-2'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						instruction_fetch = instruction_fetch + instruction_fetch_aux

			if (contador_subetapas == 2): #Parte 1
				instruction_fetch_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IF-1'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						instruction_fetch = instruction_fetch + instruction_fetch_aux

			else: # Parte 0
				instruction_fetch_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IF-0'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						instruction_fetch = instruction_fetch + instruction_fetch_aux
						etiqueta_instruction_fetch = getHexadecimal (instruction_fetch)
						etiquetaInstructionFetchValorMIPS.config (text = etiqueta_instruction_fetch)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0
						#flag_receive = False
						#if ((modo_ejecucion == '0') or (instruction_fetch == ('0' * 32))): #Continuo
						#	activarBotones (1)
						#else: #Debug
						#	activarBotones (4)
		
		
		
		elif (contador_etapas == 4): # Branch
			if (contador_subetapas == 0): # Parte H
				branch_dir, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('BR-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: # Parte L
				branch_dir_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('BR-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						branch_dir = branch_dir + branch_dir_aux
						etiqueta_branch_dir = branch_dir [CANT_BITS_INSTRUCCION / 2 - CANT_BITS_ADDRESS_MEM_PROGRAMA ::]
						etiqueta_control_salto = branch_dir [CANT_BITS_INSTRUCCION / 2 - CANT_BITS_ADDRESS_MEM_PROGRAMA - 1]
						etiquetaBranchDirValorMIPS.config (text = etiqueta_branch_dir)
						etiquetaBranchControlValorMIPS .config (text = etiqueta_control_salto)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0 

		elif (contador_etapas == 5): # Reg_dato_A
			if (contador_subetapas == 0): # Parte 3
				dato_reg_A, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DA-3'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			if (contador_subetapas == 1): # Parte 2
				dato_reg_A_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DA-2'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						dato_reg_A = dato_reg_A + dato_reg_A_aux

			if (contador_subetapas == 2): #Parte 1
				dato_reg_A_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DA-1'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						dato_reg_A = dato_reg_A + dato_reg_A_aux

			else: # Parte 0
				dato_reg_A_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DA-0'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						dato_reg_A = dato_reg_A + dato_reg_A_aux
						etiqueta_dato_reg_A = getHexadecimal (dato_reg_A)
						etiquetaDatoRegAValorMIPS.config (text = etiqueta_dato_reg_A)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0
						#flag_receive = False
						#if ((modo_ejecucion == '0') or (dato_reg_A == ('0' * 32))): #Continuo
						#	activarBotones (1)
						#else: #Debug
						#	activarBotones (4)

		elif (contador_etapas == 6): # Reg_dato_B
			if (contador_subetapas == 0): # Parte 3
				dato_reg_B, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DB-3'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			if (contador_subetapas == 1): # Parte 2
				dato_reg_B_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DB-2'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						dato_reg_B = dato_reg_B + dato_reg_B_aux

			if (contador_subetapas == 2): #Parte 1
				dato_reg_B_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DB-1'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						dato_reg_B = dato_reg_B + dato_reg_B_aux

			else: # Parte 0
				dato_reg_B_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('DB-0'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						dato_reg_B = dato_reg_B + dato_reg_B_aux
						etiqueta_dato_reg_B = getHexadecimal (dato_reg_B)
						etiquetaDatoRegBValorMIPS.config (text = etiqueta_dato_reg_B)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0
						#flag_receive = False
						#if ((modo_ejecucion == '0') or (dato_reg_B == ('0' * 32))): #Continuo
						#	activarBotones (1)
						#else: #Debug
						#	activarBotones (4)

		elif (contador_etapas == 7): # Valor inmediato con extension de signo
			if (contador_subetapas == 0): # Parte 3
				valor_inmediato, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IM-3'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			if (contador_subetapas == 1): # Parte 2
				valor_inmediato_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IM-2'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						valor_inmediato = valor_inmediato + valor_inmediato_aux

			if (contador_subetapas == 2): #Parte 1
				valor_inmediato_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IM-1'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1
						valor_inmediato = valor_inmediato + valor_inmediato_aux

			else: # Parte 0
				valor_inmediato_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('IM-0'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						valor_inmediato = valor_inmediato + valor_inmediato_aux
						etiqueta_valor_inmediato = getHexadecimal (valor_inmediato)
						etiquetaValorInmediatoValorMIPS.config (text = etiqueta_valor_inmediato)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0
						#flag_receive = False
						#if ((modo_ejecucion == '0') or (valor_inmediato == ('0' * 32))): #Continuo
						#	activarBotones (1)
						#else: #Debug
						#	activarBotones (4)
		
		elif (contador_etapas == 8): # Direcciones de registros rs, rt y rd
			if (contador_subetapas == 0): # Parte H
				rs, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('AR-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: # Parte L
				rs_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('AR-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						rs = rs + rs_aux

						etiqueta_rs = 'R' + str (int (rs [-CANT_BITS_ADDR_REGISTROS * 3 : -CANT_BITS_ADDR_REGISTROS * 2 ], 2))
						etiqueta_rt = 'R' + str (int (rs [-CANT_BITS_ADDR_REGISTROS * 2 : -CANT_BITS_ADDR_REGISTROS], 2 ))
						etiqueta_rd = 'R' + str (int (rs [-CANT_BITS_ADDR_REGISTROS : ], 2))
						
						etiquetaRSValorMIPS.config (text = etiqueta_rs)
						etiquetaRTValorMIPS.config (text = etiqueta_rt)
						etiquetaRDValorMIPS.config (text = etiqueta_rd)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0 

		
		elif (contador_etapas == 9): # Seniales de control ID/EX
			if (contador_subetapas == 0): # Parte H
				reg_dst, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('SC-H'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_subetapas = contador_subetapas + 1

			else: # Parte L
				reg_dst_aux, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('SC-L'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						reg_dst = reg_dst + reg_dst_aux
						
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 6 ]) == '1'):
							etiqueta_reg_dst = 'Rd'
						else:
							etiqueta_reg_dst = 'Rt'
						
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 1 ]) == '1'):
							etiqueta_mem_to_reg = 'Si'
						else:
							etiqueta_mem_to_reg = 'No'

						
						etiqueta_alu_op = reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP  : - CANT_BITS_ALU_CTRL ]
						etiqueta_alu_ctrl = reg_dst [ - CANT_BITS_ALU_CTRL  : ]
						
						
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 4 ]) == '1'):
							etiqueta_alu_src = 'Valor inmediato'
						else:
							etiqueta_alu_src = 'Registro B'

						
						
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 3 ]) == '1'):
							etiqueta_mem_read = 'Si'
						else:
							etiqueta_mem_read = 'No'
						 
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 2 ]) == '1'):
							etiqueta_mem_write = 'Si'
						else:
							etiqueta_mem_write = 'No'
						
						if (str (reg_dst [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 5 ]) == '1'):
							etiqueta_reg_write = 'Si'
						else:
							etiqueta_reg_write = 'No' 
						
						etiquetaRegDestinoValorMIPS.config (text = etiqueta_reg_dst)
						etiquetaMemToRegValorMIPS.config (text = etiqueta_mem_to_reg)
						etiquetaALUOpValorMIPS.config (text = etiqueta_alu_op)
						etiquetaALUControlValorMIPS.config (text = etiqueta_alu_ctrl)
						etiquetaALUSrcValorMIPS.config (text = etiqueta_alu_src)
						etiquetaMemReadValorMIPS.config (text = etiqueta_mem_read)
						etiquetaMemWriteValorMIPS.config (text = etiqueta_mem_write)
						etiquetaRegWriteValorMIPS.config (text = etiqueta_reg_write)
						contador_etapas = contador_etapas + 1
						contador_subetapas = 0
						flag_receive = False
						if ((modo_ejecucion == '0') or (instruction_fetch == (HALT_INSTRUCTION))): #Continuo
							activarBotones (1)
						else: #Debug
							activarBotones (4) 

						

		




# Funcion que genera un thread que permite realizar un soft reset en la FPGA.
def softReset():
	try:
		hiloSoftReset = threading.Thread (target = softResetViaThread) 
		hiloSoftReset.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones (1)

# Funcion del thread que permite realizar un soft reset en la FPGA.
def softResetViaThread():
	desactivarBotones()
	print 'Thread de soft reset OK.'
	global etiqueta_resultado_impresion
	try:
		data_send = getCode('Soft reset')
		if (len (data_send) == 8):
			code_error_wr = writeSerial (data_send)
			code_error = readResultado (1, getCode ('Soft reset ack')) #Lectura de soft reset ack (1 byte)
			if ((code_error < 0) or (code_error_wr < 0)): #Hubo error en la comparacion con la cadena patron
				activarBotones (1)  
			else:
				activarBotones (2)
		else:
			print 'Warning: Deben ser 8 bits.'
			etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
			activarBotones (0)
	except: 
		print 'Error en el soft reset.'
		etiquetaResultado.config (text = "ERROR_LOG", fg = "red")
		activarBotones(0)

# Funcion que genera un thread que permite realizar el envio de instrucciones a la memoria de programa del MIPS.
def sendInstructions():
	try:
		hiloSendInstructions = threading.Thread (target = sendInstructionsViaThread) 
		hiloSendInstructions.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones (2)

# Funcion del thread que permite realizar el envio de instrucciones a la memoria de programa del MIPS.
def sendInstructionsViaThread():
	desactivarBotones()
	print 'Thread de send instructions OK.'
	global etiqueta_resultado_impresion
	try:
		data_send = getCode('Send instructions')
		if (len (data_send) == 8):
			code_error = writeSerial (data_send)
			if (code_error < 0):
				activarBotones (2)
			else:
				cadena_archivo = fileReader (FILE_NAME)
				cadena_archivo = cadena_archivo.split ("\n")
				if (FLAG_TEST):
					print "Array de archivo: ",
					print cadena_archivo
				flag_activar_botones_3 = True
				for i in range(len(cadena_archivo)):
					if ((cadena_archivo[i] != '') and (len(cadena_archivo[i]) == (CANT_BITS_INSTRUCCION))):
						for j in range(CANT_BITS_INSTRUCCION/WIDTH_WORD):
							code_error = writeSerial (cadena_archivo[i][WIDTH_WORD * j:WIDTH_WORD * (j+1)][::-1])
							if (code_error < 0):
								flag_activar_botones_3 = False
								break
					if (not flag_activar_botones_3):
						break
				if (flag_activar_botones_3):
					activarBotones (3)
					etiquetaResultado.config (text = "Instrucciones OK", fg = "dark green")
				else:
					activarBotones(2)
		else:
			print 'Warning: Deben ser 8 bits.'
			etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
			activarBotones (0)
	except: 
		print 'Error en send instructions.'
		etiquetaResultado.config (text = "ERROR_LOG", fg = "red")
		activarBotones(0)

# Funcion que genera un thread que permite comenzar la ejecucion del MIPS.
def iniciarMIPS():
	try:
		hiloIniciarMIPS = threading.Thread (target = iniciarMIPSViaThread) 
		hiloIniciarMIPS.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones (4)

# Funcion del thread que permite comenzar la ejecucion del MIPS.
def iniciarMIPSViaThread():
	desactivarBotones()
	print 'Thread de iniciar MIPS OK.'
	global etiqueta_resultado_impresion
	global modo_ejecucion
	global ser
	ser.flushInput()
	ser.flushOutput()
	while (ser.inWaiting() > 0):
		ser.read (1)
	time.sleep(1)
	while (ser.inWaiting() > 0):
		ser.read (1)
	try:
		data_send = getCode('Start MIPS')
		if (len (data_send) == 8):
			data_send =  data_send[0:2] + modo_ejecucion + data_send[3:]
			code_error = writeSerial (data_send)
			if (code_error < 0):
				activarBotones (4)
			else:
				etiqueta_resultado_impresion = "Start MIPS."
				etiquetaResultado.config (text = etiqueta_resultado_impresion, fg = "dark green")
				recibirDatosFromFPGA ()
				
		else:
			print 'Warning: Deben ser 8 bits.'
			etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
			activarBotones (0)
	except: 
		print 'Error en iniciar MIPS.'
		etiquetaResultado.config (text = "ERROR_LOG", fg = "red")
		activarBotones (0)

# Funcion que genera un thread que permite setear el modo de ejecucion del MIPS.
def setModoEjecucion (modo):
	try:
		hiloSetModoEjecucion = threading.Thread (target = setModoEjecucionViaThread, args = (modo,)) 
		hiloSetModoEjecucion.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones (3)

# Funcion del thread que permite setear el modo de ejecucion del MIPS.
def setModoEjecucionViaThread (modo):
	desactivarBotones()
	print 'Thread de set modo de ejecucion OK.'
	global etiqueta_resultado_impresion
	global modo_ejecucion
	global etiqueta_resultado_modo_de_ejecucion
	global etiqueta_resultado_modo_de_ejecucion_valor_MIPS
	if ((modo != '0') and (modo != '1')):
		etiqueta_resultado_modo_de_ejecucion = "Valor ingresado invalido"
		etiquetaResultadoModoEjecucion.config (text = etiqueta_resultado_modo_de_ejecucion, fg= "red")
		activarBotones (3)
	else:
		modo_ejecucion = modo
		if (modo == '0'):
			etiqueta_resultado_modo_de_ejecucion_valor_MIPS = "Continuo"
		else:
			etiqueta_resultado_modo_de_ejecucion_valor_MIPS = "Debug"
		etiquetaModoEjecucionValorMIPS.config (text = etiqueta_resultado_modo_de_ejecucion_valor_MIPS)
		etiqueta_resultado_impresion = "Modo de ejecucion: " + modo_ejecucion
		etiquetaResultado.config (text = etiqueta_resultado_impresion, fg = "dark green")
		etiqueta_resultado_modo_de_ejecucion = ""
		etiquetaResultadoModoEjecucion.config (text = etiqueta_resultado_modo_de_ejecucion, fg= "red")
		activarBotones (4)

	
		
# Funcion al presionar el boton salir.	
def salir():
	print 'Fin del programa.'
	exit(0)		

		
		



	
#Ventana principal - Configuracion

root = Tk() 
root.geometry ("560x1430+0+0") #Tamanio
root.minsize (height=560, width=1430)
root.maxsize (height=560, width=1430)

# Rectangulos divisorios

canvasPuerto = Canvas (root)
canvasPuerto.create_rectangle (5, 5, 340, 80, outline='gray60')
canvasPuerto.place (x=1, y=1)

canvasOperaciones = Canvas (root)
canvasOperaciones.config (width = 340, height = 330)
canvasOperaciones.create_rectangle (5, 5, 340, 180, outline='gray60')
canvasOperaciones.place (x=1, y=100)

canvasSetModoEjecucion = Canvas (root)
canvasSetModoEjecucion.config (width = 340, height = 390)
canvasSetModoEjecucion.create_rectangle (5, 5, 340, 120, outline='gray60')
canvasSetModoEjecucion.place (x=1, y=290)

canvasResultado = Canvas (root)
canvasResultado.config (width = 340, height = 330)
canvasResultado.create_rectangle (5, 5, 340, 70, outline='gray60')
canvasResultado.place (x=1, y=420)


canvasValoresMIPS = Canvas (root)
canvasValoresMIPS.config (width = 1040, height = 530)
canvasValoresMIPS.create_rectangle (5, 5, 1040, 530, outline='gray60')
canvasValoresMIPS.place (x=380, y=2)


# Text boxes

campoPuerto = Entry (root) #Para ingresar texto.
campoPuerto.place (x = 87, y = 25)
campoModoEjecucion = Entry (root)
campoModoEjecucion.place (x = 20, y = 355)


# Botones
botonSoftReset = Button (root, text = "Soft reset", command = lambda: softReset (), state = DISABLED)
botonSoftReset.place (x = 100, y = 150, width = 150, height = 30)
botonSendInstructions = Button (root, text = "Enviar instrucciones", command = lambda: sendInstructions (), state = DISABLED)
botonSendInstructions.place (x = 100, y = 190, width = 150, height = 30)
botonSetModoEjecucion = Button (root, text = "Set modo de ejecucion", command = lambda: setModoEjecucion (str (campoModoEjecucion.get())),\
	 state = DISABLED)
botonSetModoEjecucion.place (x = 180, y = 345, width = 150, height = 30)
botonIniciarMIPS = Button (root, text = "Iniciar MIPS", command = lambda: iniciarMIPS (), state = DISABLED)
botonIniciarMIPS.place (x = 100, y = 230, width = 150, height = 30)

### Botones - Conexion y desconexion FPGA

botonConectarFPGA = Button (root, text = "Conectar", command = lambda: conectarFPGA (str (campoPuerto.get())))
botonConectarFPGA.place (x = 250, y = 10, width = 80, height = 30)
botonDesconectarFPGA = Button (root, text = "Desconectar", state = DISABLED, command = lambda: conectarFPGA ("disconnect"))
botonDesconectarFPGA.place (x = 250, y = 40, width = 80, height = 30)

### Boton - Finalizar programa
botonSalir = Button (root, text = "Exit", command = lambda: salir(), state = ACTIVE)
botonSalir.place (x = 100, y = 510, width = 150, height = 30)




# Labels

etiquetaPuerto = Label (root, text = "Serial Port")
etiquetaPuerto.place (x = 20, y = 25)
etiquetaPuertoMensajeEstado = Label (root, text = "Status     : ")
etiquetaPuertoMensajeEstado.place (x = 20, y = 50)
etiquetaPuertoEstado = Label (root, text = estado_puerto, fg = "red")
etiquetaPuertoEstado.place (x = 87, y = 50)
etiquetaInputDatos = Label (root, text = "Comandos del sistema: ", font = "TkDefaultFont 12")
etiquetaInputDatos.place (x = 10,  y = 110)
etiquetaOutputResultado = Label (root, text = "Resultado: ", font = "TkDefaultFont 12")
etiquetaOutputResultado.place (x = 10,  y = 430)
etiquetaResultado = Label (root, text = etiqueta_resultado_impresion, fg = "dark green", font = "TkDefaultFont 12")
etiquetaResultado.place (x = 10, y = 460)
etiquetaModoEjecucion = Label (root, text = "Setear modo de ejecucion:", font = "TkDefaultFont 12")
etiquetaModoEjecucion.place (x = 10, y = 300)
etiquetaInfoModoEjecucion = Label (root, text = "0 (Continuo) - 1 (Debug)", font = "TkDefaultFont 9")
etiquetaInfoModoEjecucion.place (x = 10, y = 330)
etiquetaResultadoModoEjecucion = Label (root, text = etiqueta_resultado_modo_de_ejecucion, font = "TkDefaultFont 9")
etiquetaResultadoModoEjecucion.place (x = 10, y = 380)


# Etiquetas de valores del MIPS.

etiquetaTitleCanvasValoresMIPS = Label (root, text = "Valores del MIPS: ", fg = "dark green", font = "TkDefaultFont 14")
etiquetaTitleCanvasValoresMIPS.place (x = 400,  y = 20)

etiquetaModoEjecucionCanvasDerecha = Label (root, text = "Modo de ejecucion: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaModoEjecucionCanvasDerecha.place (x = 400,  y = 70)
etiquetaModoEjecucionValorMIPS = Label (root, text = etiqueta_resultado_modo_de_ejecucion_valor_MIPS,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaModoEjecucionValorMIPS.place (x = 620,  y = 70)

etiquetaPC = Label (root, text = "Contador de programa: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaPC.place (x = 400,  y = 100)
etiquetaPCValorMIPS = Label (root, text = etiqueta_resultado_pc,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaPCValorMIPS.place (x = 620,  y = 100)

etiquetaContadorCiclos = Label (root, text = "Contador de ciclos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaContadorCiclos.place (x = 400,  y = 130)
etiquetaContadorCiclosValorMIPS = Label (root, text = etiqueta_contador_ciclos,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaContadorCiclosValorMIPS.place (x = 620,  y = 130)


# IF 

etiquetaLatchIFID = Label (root, text = "LATCH IF/ID: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIFID.place (x = 400,  y = 190)
etiquetaPCAdd = Label (root, text = "Salida adder de PC: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaPCAdd.place (x = 400,  y = 220)
etiquetaPCAddValorMIPS = Label (root, text = etiqueta_resultado_adder_pc,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaPCAddValorMIPS.place (x = 620,  y = 220)

etiquetaInstructionFetch = Label (root, text = "Instruccion: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaInstructionFetch.place (x = 400,  y = 250)
etiquetaInstructionFetchValorMIPS = Label (root, text = etiqueta_instruction_fetch,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaInstructionFetchValorMIPS.place (x = 620,  y = 250)



# ID

etiquetaLatchIFID = Label (root, text = "LATCH ID/EX: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIFID.place (x = 400,  y = 290)

etiquetaBranchDir = Label (root, text = "Direccion de salto: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaBranchDir.place (x = 400,  y = 320)
etiquetaBranchDirValorMIPS = Label (root, text = etiqueta_branch_dir,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaBranchDirValorMIPS.place (x = 620,  y = 320)

etiquetaBranchControl = Label (root, text = "Control del salto: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaBranchControl.place (x = 400,  y = 350)
etiquetaBranchControlValorMIPS = Label (root, text = etiqueta_control_salto,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaBranchControlValorMIPS.place (x = 620,  y = 350)

etiquetaDatoRegA = Label (root, text = "Dato de registro A: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaDatoRegA.place (x = 400,  y = 380)
etiquetaDatoRegAValorMIPS = Label (root, text = etiqueta_dato_reg_A,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaDatoRegAValorMIPS.place (x = 620,  y = 380)

etiquetaDatoRegB = Label (root, text = "Dato de registro B: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaDatoRegB.place (x = 400,  y = 410)
etiquetaDatoRegBValorMIPS = Label (root, text = etiqueta_dato_reg_B,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaDatoRegBValorMIPS.place (x = 620,  y = 410)

etiquetaValorInmediato = Label (root, text = "Valor inmediato: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaValorInmediato.place (x = 400,  y = 440)
etiquetaValorInmediatoValorMIPS = Label (root, text = etiqueta_valor_inmediato,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaValorInmediatoValorMIPS.place (x = 620,  y = 440)

etiquetaRS = Label (root, text = "Direccion rs: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRS.place (x = 400,  y = 470)
etiquetaRSValorMIPS = Label (root, text = etiqueta_rs,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRSValorMIPS.place (x = 620,  y = 470)

etiquetaRT = Label (root, text = "Direccion rt: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRT.place (x = 400,  y = 500)
etiquetaRTValorMIPS = Label (root, text = etiqueta_rt,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRTValorMIPS.place (x = 620,  y = 500)

etiquetaLatchIFID = Label (root, text = "LATCH ID/EX: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIFID.place (x = 900,  y = 20)

etiquetaRD = Label (root, text = "Direccion rd: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRD.place (x = 900,  y = 70)
etiquetaRDValorMIPS = Label (root, text = etiqueta_rd,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRDValorMIPS.place (x = 1200,  y = 70)

etiquetaRegDestino = Label (root, text = "Registro destino: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegDestino.place (x = 900,  y = 100)
etiquetaRegDestinoValorMIPS = Label (root, text = etiqueta_reg_dst,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegDestinoValorMIPS.place (x = 1200,  y = 100)

etiquetaRegWrite = Label (root, text = "Escribir registro: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegWrite.place (x = 900,  y = 130)
etiquetaRegWriteValorMIPS = Label (root, text = etiqueta_reg_write,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegWriteValorMIPS.place (x = 1200,  y = 130)

etiquetaALUSrc = Label (root, text = "Segundo operando ALU: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUSrc.place (x = 900,  y = 160)
etiquetaALUSrcValorMIPS = Label (root, text = etiqueta_alu_src,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUSrcValorMIPS.place (x = 1200,  y = 160)




etiquetaMemRead = Label (root, text = "Lectura memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemRead.place (x = 900,  y = 190)
etiquetaMemReadValorMIPS = Label (root, text = etiqueta_mem_read,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemReadValorMIPS.place (x = 1200,  y = 190)

etiquetaMemWrite = Label (root, text = "Escritura memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemWrite.place (x = 900,  y = 220)
etiquetaMemWriteValorMIPS = Label (root, text = etiqueta_mem_write,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemWriteValorMIPS.place (x = 1200,  y = 220)

etiquetaMemToReg = Label (root, text = "Datos de memoria a registros: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemToReg.place (x = 900,  y = 250)
etiquetaMemToRegValorMIPS = Label (root, text = etiqueta_mem_to_reg,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemToRegValorMIPS.place (x = 1200,  y = 250)


etiquetaALUOp = Label (root, text = "ALU op: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUOp.place (x = 900,  y = 280)
etiquetaALUOpValorMIPS = Label (root, text = etiqueta_alu_op,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUOpValorMIPS.place (x = 1200,  y = 280)


etiquetaALUControl = Label (root, text = "ALU ctrl: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUControl.place (x = 900,  y = 310)
etiquetaALUControlValorMIPS = Label (root, text = etiqueta_alu_ctrl,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUControlValorMIPS.place (x = 1200,  y = 310)


# Titulo de la GUI 

root.title ("TP4 MIPS - Kleiner Matias, Lopez Gaston")

  
# Ejecucion de loop propio de GUI

root.mainloop()