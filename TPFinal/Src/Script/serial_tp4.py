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
FLAG_TEST = True
CANT_BITS_ADDRESS_MEM_PROGRAMA = 10
CANT_REGISTROS = 32
CANT_BITS_REGISTROS = 32
CANT_BITS_ADDR_REGISTROS = int (math.log(CANT_REGISTROS, 2))
CANT_BITS_ALU_CTRL = 4
CANT_BITS_ALU_OP = 2
HALT_INSTRUCTION = '1' * CANT_BITS_INSTRUCCION
CANT_BITS_SELECT_BYTES_MEM_DATA = 3
CANT_DATOS_DB = 12

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
etiqueta_reg_dst_ID_to_EX = ""
etiqueta_mem_to_reg_ID_to_EX = ""
etiqueta_alu_op = ""
etiqueta_alu_ctrl = ""
etiqueta_alu_src = ""
etiqueta_mem_read_ID_to_EX = ""
etiqueta_mem_write_ID_to_EX = ""
etiqueta_reg_write_ID_to_EX = ""
etiqueta_falg_halt_ID_to_EX = ""
etiqueta_select_bytes_mem_data_ID_to_EX = ""
etiqueta_data_write_mem = ""
etiqueta_resultado_ALU = ""
etiqueta_reg_write_EX_to_MEM = ""
etiqueta_mem_read_EX_to_MEM = ""
etiqueta_mem_write_EX_to_MEM = ""
etiqueta_mem_to_reg_EX_to_MEM = ""
etiqueta_select_bytes_mem_datos_EX_to_MEM = "" 
etiqueta_halt_detected_EX_to_MEM = "" 
etiqueta_registro_destino_EX_to_MEM = ""
etiqueta_data_ALU_MEM_WB = ""
etiqueta_data_read_mem = ""
etiqueta_halt_detected_MEM_to_WB = ""
etiqueta_mem_to_reg_MEM_to_WB = ""
etiqueta_reg_write_MEM_TO_WB = ""
etiqueta_mem_to_reg_MEM_to_WB = ""
etiqueta_registro_destino_MEM_to_WB = ""

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
		'Send-Part-3' : '00010000',
		'Send-Part-2' : '00001000',
		'Send-Part-1' : '00011000',
		'Send-Part-0' : '00000100'
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
		time.sleep (0.02) #Espera.
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
	time.sleep (0.02)
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
	time.sleep (0.02)
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
		resultado = "11010010"
	
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
	global etiqueta_reg_dst_ID_to_EX
	global etiqueta_mem_to_reg_ID_to_EX
	global etiqueta_alu_op
	global etiqueta_alu_ctrl
	global etiqueta_alu_src
	global etiqueta_mem_read_ID_to_EX
	global etiqueta_mem_write_ID_to_EX
	global etiqueta_reg_write_ID_to_EX
	global etiqueta_falg_halt_ID_to_EX
	global etiqueta_select_bytes_mem_data_ID_to_EX
	global etiqueta_resultado_ALU
	global etiqueta_data_write_mem
	global etiqueta_reg_write_EX_to_MEM
	global etiqueta_mem_read_EX_to_MEM
	global etiqueta_mem_write_EX_to_MEM
	global etiqueta_mem_to_reg_EX_to_MEM
	global etiqueta_select_bytes_mem_datos_EX_to_MEM 
	global etiqueta_halt_detected_EX_to_MEM 
	global etiqueta_registro_destino_EX_to_MEM
	global etiqueta_data_ALU_MEM_WB
	global etiqueta_data_read_mem
	global etiqueta_halt_detected_MEM_to_WB
	global etiqueta_mem_to_reg_MEM_to_WB
	global etiqueta_reg_write_MEM_TO_WB
	global etiqueta_mem_to_reg_MEM_to_WB
	global etiqueta_registro_destino_MEM_to_WB
	
	flag_receive = True
	bytes_recibidos = ""
	bytes_recibidos_aux = ""
	
	

	contador_etapas = -1
	contador_etapas_send = 0
	cantidad_bytes_control = 0


	while (flag_receive):

		if (contador_etapas_send == 0): # Parte 3
				bytes_recibidos, cantidad_bytes_control = readResultadoEjecucion (1)
				if (cantidad_bytes_control == 1):
					code_error = writeSerial (getCode('Send-Part-3'))
					if (code_error < 0):
						activarBotones (1)
						flag_receive = False
					else:
						ser.flushInput()
						contador_etapas_send = contador_etapas_send + 1

		if (contador_etapas_send == 1):# Parte 2
			bytes_recibidos_aux, cantidad_bytes_control = readResultadoEjecucion (1)
			if (cantidad_bytes_control == 1):
				code_error = writeSerial (getCode('Send-Part-2'))
				if (code_error < 0):
					activarBotones (1)
					flag_receive = False
				else:
					ser.flushInput()
					contador_etapas_send = contador_etapas_send + 1
					bytes_recibidos = bytes_recibidos + bytes_recibidos_aux

		if (contador_etapas_send == 2): #Parte 1
			bytes_recibidos_aux, cantidad_bytes_control = readResultadoEjecucion (1)
			if (cantidad_bytes_control == 1):
				code_error = writeSerial (getCode('Send-Part-1'))
				if (code_error < 0):
					activarBotones (1)
					flag_receive = False
				else:
					ser.flushInput()
					contador_etapas_send = contador_etapas_send + 1
					bytes_recibidos = bytes_recibidos + bytes_recibidos_aux

		if (contador_etapas_send == 3): # Parte 0
			bytes_recibidos_aux, cantidad_bytes_control = readResultadoEjecucion (1)
			if (cantidad_bytes_control == 1):
				code_error = writeSerial (getCode('Send-Part-0'))
				if (code_error < 0):
					activarBotones (1)
					flag_receive = False
				else:
					ser.flushInput()
					bytes_recibidos = bytes_recibidos + bytes_recibidos_aux
					
					contador_etapas = contador_etapas + 1
					contador_etapas_send = 0
								
		

		if (contador_etapas == 0): #PC y CC
			etiqueta_resultado_pc = bytes_recibidos [0 : WIDTH_WORD * 2] #PC
			etiquetaPCValorMIPS.config (text = etiqueta_resultado_pc)
						
				
			etiqueta_contador_ciclos = bytes_recibidos [WIDTH_WORD * 2 : ] #CC
			etiquetaContadorCiclosValorMIPS.config (text = etiqueta_contador_ciclos)

		elif (contador_etapas == 1): # Adder PC, branch dir y branch control 
			etiqueta_resultado_adder_pc = bytes_recibidos [0 : WIDTH_WORD * 2] #Adder PC
			etiquetaPCAddValorMIPS.config (text = etiqueta_resultado_adder_pc)	
			
			etiqueta_branch_dir = bytes_recibidos [- CANT_BITS_ADDRESS_MEM_PROGRAMA : ]
			etiqueta_control_salto = bytes_recibidos [- CANT_BITS_ADDRESS_MEM_PROGRAMA - 1]
			etiquetaBranchDirValorMIPS.config (text = etiqueta_branch_dir)
			etiquetaBranchControlValorMIPS .config (text = etiqueta_control_salto)		

		elif (contador_etapas == 2): #Instruction
			etiqueta_instruction_fetch = getHexadecimal (bytes_recibidos)
			etiquetaInstructionFetchValorMIPS.config (text = etiqueta_instruction_fetch)

		elif (contador_etapas == 3):
			etiqueta_dato_reg_A = getHexadecimal (bytes_recibidos)
			etiquetaDatoRegAValorMIPS.config (text = etiqueta_dato_reg_A)

		elif (contador_etapas == 4):
			etiqueta_dato_reg_B = getHexadecimal (bytes_recibidos)
			etiquetaDatoRegBValorMIPS.config (text = etiqueta_dato_reg_B)
		
		elif (contador_etapas == 5):
			etiqueta_valor_inmediato = getHexadecimal (bytes_recibidos)
			etiquetaValorInmediatoValorMIPS.config (text = etiqueta_valor_inmediato)
		
		
		elif (contador_etapas == 6): # Direcciones de registros rs, rt y rd. Seniales de control de etapa ID.
			etiqueta_rs = 'R' + str (int (bytes_recibidos [-CANT_BITS_ADDR_REGISTROS * 3 : -CANT_BITS_ADDR_REGISTROS * 2 ], 2))
			etiqueta_rt = 'R' + str (int (bytes_recibidos [-CANT_BITS_ADDR_REGISTROS * 2 : -CANT_BITS_ADDR_REGISTROS], 2 ))
			etiqueta_rd = 'R' + str (int (bytes_recibidos [-CANT_BITS_ADDR_REGISTROS : ], 2))
			
			etiquetaRSValorMIPS.config (text = etiqueta_rs)
			etiquetaRTValorMIPS.config (text = etiqueta_rt)
			etiquetaRDValorMIPS.config (text = etiqueta_rd)

			bytes_recibidos_auxiliar = bytes_recibidos [0 : WIDTH_WORD * 2]			
			etiqueta_falg_halt_ID_to_EX = bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 7 ]
			
			select_bytes_condicion = int (bytes_recibidos_auxiliar [ - CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 7 - \
				CANT_BITS_SELECT_BYTES_MEM_DATA : - CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 7 ], 2)
			if (select_bytes_condicion == 0):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Ninguno'
			elif (select_bytes_condicion == 1):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Byte unsigned'
			elif (select_bytes_condicion == 2):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Halfword unsigned'			
			elif (select_bytes_condicion == 3):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Word unsigned'
			elif (select_bytes_condicion == 5):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Byte signed'
			elif (select_bytes_condicion == 6):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Halfword signed'
			elif (select_bytes_condicion == 7):
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Word signed'
			else:
				etiqueta_select_bytes_mem_data_ID_to_EX = 'Ninguno'


			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 6 ]) == '1'):
				etiqueta_reg_dst_ID_to_EX = 'Rd'
			else:
				etiqueta_reg_dst_ID_to_EX = 'Rt'
			
			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 1 ]) == '1'):
				etiqueta_mem_to_reg_ID_to_EX = 'Si'
			else:
				etiqueta_mem_to_reg_ID_to_EX = 'No'

			
			etiqueta_alu_op = bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP  : - CANT_BITS_ALU_CTRL ]
			etiqueta_alu_ctrl = bytes_recibidos_auxiliar [ - CANT_BITS_ALU_CTRL  : ]
			
			
			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 4 ]) == '1'):
				etiqueta_alu_src = 'Valor inmediato'
			else:
				etiqueta_alu_src = 'Registro B'

			
			
			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 3 ]) == '1'):
				etiqueta_mem_read_ID_to_EX = 'Si'
			else:
				etiqueta_mem_read_ID_to_EX = 'No'
				
			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 2 ]) == '1'):
				etiqueta_mem_write_ID_to_EX = 'Si'
			else:
				etiqueta_mem_write_ID_to_EX = 'No'
			
			if (str (bytes_recibidos_auxiliar [- CANT_BITS_ALU_CTRL - CANT_BITS_ALU_OP - 5 ]) == '1'):
				etiqueta_reg_write_ID_to_EX = 'Si'
			else:
				etiqueta_reg_write_ID_to_EX = 'No' 
			
			etiquetaFlagHaltIDtoEXValorMIPS.config (text = etiqueta_falg_halt_ID_to_EX)
			etiquetaSelectBytesMemDataIDtoEXValorMIPS.config (text = etiqueta_select_bytes_mem_data_ID_to_EX)
			etiquetaRegDestinoIDtoEXValorMIPS.config (text = etiqueta_reg_dst_ID_to_EX)
			etiquetaMemToRegIDtoEXValorMIPS.config (text = etiqueta_mem_to_reg_ID_to_EX)
			etiquetaALUOpValorMIPS.config (text = etiqueta_alu_op)
			etiquetaALUControlValorMIPS.config (text = etiqueta_alu_ctrl)
			etiquetaALUSrcValorMIPS.config (text = etiqueta_alu_src)
			etiquetaMemReadIDtoEXValorMIPS.config (text = etiqueta_mem_read_ID_to_EX)
			etiquetaMemWriteIDtoEXValorMIPS.config (text = etiqueta_mem_write_ID_to_EX)
			etiquetaRegWriteIDtoEXValorMIPS.config (text = etiqueta_reg_write_ID_to_EX)
						
		elif (contador_etapas == 7): #Resultado ALU
			etiqueta_resultado_ALU = getHexadecimal (bytes_recibidos)
			etiquetaResultadoALUValorMIPS.config (text = etiqueta_resultado_ALU)
			
		elif (contador_etapas == 8): #Dato de ALU a MEM
			etiqueta_data_write_mem = getHexadecimal (bytes_recibidos)
			etiquetaDataWriteMemValorMIPS.config (text = etiqueta_data_write_mem)

		elif (contador_etapas == 9): # Seniales de control etapa EX y MEM.
			base = 2
			if (str (bytes_recibidos [-CANT_BITS_SELECT_BYTES_MEM_DATA - CANT_BITS_ADDR_REGISTROS - base - 2]) == '1'):
				etiqueta_mem_read_EX_to_MEM = 'Si'
			else:
				etiqueta_mem_read_EX_to_MEM = 'No'
				
			if (str (bytes_recibidos [-CANT_BITS_SELECT_BYTES_MEM_DATA - CANT_BITS_ADDR_REGISTROS - base - 1]) == '1'):
				etiqueta_mem_write_EX_to_MEM = 'Si'
			else:
				etiqueta_mem_write_EX_to_MEM = 'No'
			
			if (str (bytes_recibidos [-CANT_BITS_SELECT_BYTES_MEM_DATA - CANT_BITS_ADDR_REGISTROS - base - 3]) == '1'):
				etiqueta_reg_write_EX_to_MEM = 'Si'
			else:
				etiqueta_reg_write_EX_to_MEM = 'No' 

			if (str (bytes_recibidos [-CANT_BITS_SELECT_BYTES_MEM_DATA - CANT_BITS_ADDR_REGISTROS - base]) == '1'):
				etiqueta_mem_to_reg_EX_to_MEM = 'Si'
			else:
				etiqueta_mem_to_reg_EX_to_MEM = 'No'
			
			etiquetaRegWriteEXtoMEMValorMIPS.config (text = etiqueta_reg_write_EX_to_MEM)
			
			etiquetaMemReadEXtoMEMValorMIPS.config (text = etiqueta_mem_read_EX_to_MEM)
			
			etiquetaMemWriteEXtoMEMValorMIPS.config (text = etiqueta_mem_write_EX_to_MEM)
			
			etiquetaMemtoRegEXtoMEMValorMIPS.config (text = etiqueta_mem_to_reg_EX_to_MEM)
			
						
			select_bytes_condicion = int (bytes_recibidos [-CANT_BITS_SELECT_BYTES_MEM_DATA - \
				CANT_BITS_ADDR_REGISTROS - 1 : -CANT_BITS_ADDR_REGISTROS - 1], 2)
			if (select_bytes_condicion == 0):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Ninguno'
			elif (select_bytes_condicion == 1):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Byte unsigned'
			elif (select_bytes_condicion == 2):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Halfword unsigned'			
			elif (select_bytes_condicion == 3):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Word unsigned'
			elif (select_bytes_condicion == 5):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Byte signed'
			elif (select_bytes_condicion == 6):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Halfword signed'
			elif (select_bytes_condicion == 7):
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Word signed'
			else:
				etiqueta_select_bytes_mem_datos_EX_to_MEM = 'Ninguno'
			
			etiquetaSelectBytesMemDatosEXtoMEMValorMIPS.config (text = etiqueta_select_bytes_mem_datos_EX_to_MEM)
			
			etiqueta_halt_detected_EX_to_MEM = bytes_recibidos [-CANT_BITS_ADDR_REGISTROS - 1]
			etiquetaHaltDetectedEXtoMEMValorMIPS.config (text = etiqueta_halt_detected_EX_to_MEM)

			
			etiqueta_registro_destino_EX_to_MEM = 'R' + str (int (bytes_recibidos [-CANT_BITS_ADDR_REGISTROS : ], 2))
			etiquetaRegistroDestinoEXtoMEMValorMIPS.config (text = etiqueta_registro_destino_EX_to_MEM)


			# Memoria datos

			bytes_recibidos_mem = bytes_recibidos [0 : WIDTH_WORD * 2]	
			etiqueta_registro_destino_MEM_to_WB = 'R' + str (int (bytes_recibidos_mem [- CANT_BITS_ADDR_REGISTROS : ], 2))
			etiquetaRegistroDestinoMEMtoWBValorMIPS.config (text = etiqueta_registro_destino_MEM_to_WB)

			etiqueta_halt_detected_MEM_to_WB = bytes_recibidos_mem [- CANT_BITS_ADDR_REGISTROS - 1]
			etiquetaHaltDetectedMEMtoWBValorMIPS.config (text = etiqueta_halt_detected_MEM_to_WB)

			if (str (bytes_recibidos_mem [- CANT_BITS_ADDR_REGISTROS - 3]) == '1'):
				etiqueta_reg_write_MEM_TO_WB = 'Si'
			else:
				etiqueta_reg_write_MEM_TO_WB = 'No' 

			if (str (bytes_recibidos_mem [- CANT_BITS_ADDR_REGISTROS - 2]) == '1'):
				etiqueta_mem_to_reg_MEM_to_WB = 'Si'
			else:
				etiqueta_mem_to_reg_MEM_to_WB = 'No'
			
			etiquetaRegWriteMEMtoWBValorMIPS.config (text = etiqueta_reg_write_MEM_TO_WB)
						
			etiquetaMemtoRegMEMtoWBValorMIPS.config (text = etiqueta_mem_to_reg_MEM_to_WB)

		
		
		elif (contador_etapas == 10): #Data MEM
			etiqueta_data_read_mem = getHexadecimal (bytes_recibidos)
			etiquetaDataReadMemValorMIPS.config (text = etiqueta_data_read_mem)
		
		elif (contador_etapas == 11): #Data ALU de top memoria de datos
			etiqueta_data_ALU_MEM_WB = getHexadecimal (bytes_recibidos)
			etiquetaDataALUMemWbValorMIPS.config (text = etiqueta_data_ALU_MEM_WB)
		
		

		if (contador_etapas == (CANT_DATOS_DB - 1)):
			flag_receive = False
			if ((modo_ejecucion == '0') or (etiqueta_halt_detected_EX_to_MEM == ('1'))): #Continuo o Debug con halt
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
	time.sleep (0.02)
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
root.geometry ("600x1840+0+0") #Tamanio
root.minsize (height=600, width=1840)
root.maxsize (height=600, width=1840)

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
canvasValoresMIPS.config (width = 1450, height = 570)
canvasValoresMIPS.create_rectangle (5, 5, 1450, 570, outline='gray60')
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
botonSalir.place (x = 100, y = 530, width = 150, height = 30)




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

etiquetaLatchIDEX = Label (root, text = "LATCH ID/EX: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIDEX.place (x = 400,  y = 290)

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

etiquetaLatchIDEX2 = Label (root, text = "LATCH ID/EX: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIDEX2.place (x = 900,  y = 20)

etiquetaRD = Label (root, text = "Direccion rd: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRD.place (x = 900,  y = 70)
etiquetaRDValorMIPS = Label (root, text = etiqueta_rd,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRDValorMIPS.place (x = 1200,  y = 70)


etiquetaFlagHaltIDtoEX = Label (root, text = "Flag HALT: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaFlagHaltIDtoEX.place (x = 900,  y = 100)
etiquetaFlagHaltIDtoEXValorMIPS = Label (root, text = etiqueta_falg_halt_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaFlagHaltIDtoEXValorMIPS.place (x = 1200,  y = 100)


etiquetaSelectBytesMemDataIDtoEX = Label (root, text = "Seleccion en memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaSelectBytesMemDataIDtoEX.place (x = 900,  y = 130)
etiquetaSelectBytesMemDataIDtoEXValorMIPS = Label (root, text = etiqueta_select_bytes_mem_data_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaSelectBytesMemDataIDtoEXValorMIPS.place (x = 1200,  y = 130)


etiquetaRegDestinoIDtoEX = Label (root, text = "Registro destino: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegDestinoIDtoEX.place (x = 900,  y = 160)
etiquetaRegDestinoIDtoEXValorMIPS = Label (root, text = etiqueta_reg_dst_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegDestinoIDtoEXValorMIPS.place (x = 1200,  y = 160)

etiquetaRegWriteIDtoEX = Label (root, text = "Escribir registro: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegWriteIDtoEX.place (x = 900,  y = 190)
etiquetaRegWriteIDtoEXValorMIPS = Label (root, text = etiqueta_reg_write_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegWriteIDtoEXValorMIPS.place (x = 1200,  y = 190)

etiquetaALUSrc = Label (root, text = "Segundo operando ALU: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUSrc.place (x = 900,  y = 220)
etiquetaALUSrcValorMIPS = Label (root, text = etiqueta_alu_src,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUSrcValorMIPS.place (x = 1200,  y = 220)




etiquetaMemReadIDtoEX = Label (root, text = "Lectura memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemReadIDtoEX.place (x = 900,  y = 250)
etiquetaMemReadIDtoEXValorMIPS = Label (root, text = etiqueta_mem_read_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemReadIDtoEXValorMIPS.place (x = 1200,  y = 250)

etiquetaMemWriteIDtoEX = Label (root, text = "Escritura memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemWriteIDtoEX.place (x = 900,  y = 280)
etiquetaMemWriteIDtoEXValorMIPS = Label (root, text = etiqueta_mem_write_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemWriteIDtoEXValorMIPS.place (x = 1200,  y = 280)

etiquetaMemToRegIDtoEX = Label (root, text = "Datos de memoria a registros: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemToRegIDtoEX.place (x = 900,  y = 310)
etiquetaMemToRegIDtoEXValorMIPS = Label (root, text = etiqueta_mem_to_reg_ID_to_EX,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemToRegIDtoEXValorMIPS.place (x = 1200,  y = 310)


etiquetaALUOp = Label (root, text = "ALU op: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUOp.place (x = 900,  y = 340)
etiquetaALUOpValorMIPS = Label (root, text = etiqueta_alu_op,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUOpValorMIPS.place (x = 1200,  y = 340)


etiquetaALUControl = Label (root, text = "ALU ctrl: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaALUControl.place (x = 900,  y = 370)
etiquetaALUControlValorMIPS = Label (root, text = etiqueta_alu_ctrl,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaALUControlValorMIPS.place (x = 1200,  y = 370)







# Ejecucion
etiquetaLatchEXMEM = Label (root, text = "LATCH EX/MEM: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchEXMEM.place (x = 1400,  y = 20)

etiquetaResultadoALU = Label (root, text = "Resultado ALU: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaResultadoALU.place (x = 1400,  y = 70)
etiquetaResultadoALUValorMIPS = Label (root, text = etiqueta_resultado_ALU,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaResultadoALUValorMIPS.place (x = 1700,  y = 70)


etiquetaDataWriteMemData = Label (root, text = "Dato a escribir en memoria: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaDataWriteMemData.place (x = 1400,  y = 100)
etiquetaDataWriteMemValorMIPS = Label (root, text = etiqueta_data_write_mem,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaDataWriteMemValorMIPS.place (x = 1700,  y = 100)


etiquetaRegWriteEXtoMEM = Label (root, text = "Escribir registro: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegWriteEXtoMEM.place (x = 1400,  y = 130)
etiquetaRegWriteEXtoMEMValorMIPS = Label (root, text = etiqueta_reg_write_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegWriteEXtoMEMValorMIPS.place (x = 1700,  y = 130)


etiquetaMemReadEXtoMEM = Label (root, text = "Lectura de memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemReadEXtoMEM.place (x = 1400,  y = 160)
etiquetaMemReadEXtoMEMValorMIPS = Label (root, text = etiqueta_mem_read_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemReadEXtoMEMValorMIPS.place (x = 1700,  y = 160)


etiquetaMemWriteEXtoMEM = Label (root, text = "Escritura de memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemWriteEXtoMEM.place (x = 1400,  y = 190)
etiquetaMemWriteEXtoMEMValorMIPS = Label (root, text = etiqueta_mem_write_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemWriteEXtoMEMValorMIPS.place (x = 1700,  y = 190)


etiquetaMemtoRegEXtoMEM = Label (root, text = "Datos de memoria a registros: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemtoRegEXtoMEM.place (x = 1400,  y = 220)
etiquetaMemtoRegEXtoMEMValorMIPS = Label (root, text = etiqueta_mem_to_reg_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemtoRegEXtoMEMValorMIPS.place (x = 1700,  y = 220)



etiquetaSelectBytesMemDatosEXtoMEM = Label (root, text = "Seleccion en memoria de datos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaSelectBytesMemDatosEXtoMEM.place (x = 1400,  y = 250)
etiquetaSelectBytesMemDatosEXtoMEMValorMIPS= Label (root, text = etiqueta_select_bytes_mem_datos_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaSelectBytesMemDatosEXtoMEMValorMIPS.place (x = 1700,  y = 250)


etiquetaHaltDetectedEXtoMEM = Label (root, text = "Flag HALT: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaHaltDetectedEXtoMEM.place (x = 1400,  y = 280)
etiquetaHaltDetectedEXtoMEMValorMIPS= Label (root, text = etiqueta_halt_detected_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaHaltDetectedEXtoMEMValorMIPS.place (x = 1700,  y = 280)


etiquetaRegistroDestinoEXtoMEM = Label (root, text = "Registro destino: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegistroDestinoEXtoMEM.place (x = 1400,  y = 310)
etiquetaRegistroDestinoEXtoMEMValorMIPS= Label (root, text = etiqueta_registro_destino_EX_to_MEM,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegistroDestinoEXtoMEMValorMIPS.place (x = 1700,  y = 310)



# Memoria

etiquetaLatchMEMWB = Label (root, text = "LATCH MEM/WB: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchMEMWB.place (x = 1400,  y = 360)

etiquetaDataAluMemWb = Label (root, text = "Data ALU: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaDataAluMemWb.place (x = 1400,  y = 390)
etiquetaDataALUMemWbValorMIPS = Label (root, text = etiqueta_data_ALU_MEM_WB,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaDataALUMemWbValorMIPS.place (x = 1700,  y = 390)


etiquetaDataReadMemData = Label (root, text = "Dato de memoria: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaDataReadMemData.place (x = 1400,  y = 420)
etiquetaDataReadMemValorMIPS = Label (root, text = etiqueta_data_read_mem,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaDataReadMemValorMIPS.place (x = 1700,  y = 420)


etiquetaRegWriteMEMtoWB = Label (root, text = "Escribir registro: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegWriteMEMtoWB.place (x = 1400,  y = 450)
etiquetaRegWriteMEMtoWBValorMIPS = Label (root, text = etiqueta_reg_write_MEM_TO_WB,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegWriteMEMtoWBValorMIPS.place (x = 1700,  y = 450)



etiquetaMemtoRegMEMtoWB = Label (root, text = "Datos de memoria a registros: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaMemtoRegMEMtoWB.place (x = 1400,  y = 480)
etiquetaMemtoRegMEMtoWBValorMIPS = Label (root, text = etiqueta_mem_to_reg_MEM_to_WB,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaMemtoRegMEMtoWBValorMIPS.place (x = 1700,  y = 480)



etiquetaHaltDetectedMEMtoWB = Label (root, text = "Flag HALT: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaHaltDetectedMEMtoWB.place (x = 1400,  y = 510)
etiquetaHaltDetectedMEMtoWBValorMIPS= Label (root, text = etiqueta_halt_detected_MEM_to_WB,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaHaltDetectedMEMtoWBValorMIPS.place (x = 1700,  y = 510)


etiquetaRegistroDestinoMEMtoWB = Label (root, text = "Registro destino: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaRegistroDestinoMEMtoWB.place (x = 1400,  y = 540)
etiquetaRegistroDestinoMEMtoWBValorMIPS= Label (root, text = etiqueta_registro_destino_MEM_to_WB,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaRegistroDestinoMEMtoWBValorMIPS.place (x = 1700,  y = 540)




# Titulo de la GUI 

root.title ("TP4 MIPS - Kleiner Matias, Lopez Gaston")

  
# Ejecucion de loop propio de GUI

root.mainloop()