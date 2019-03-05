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

 
#Constantes 
BAUDRATE = 9600
WIDTH_WORD = 8
CANT_BITS_INSTRUCCION = 32
CANT_STOP_BITS = 2
FILE_NAME = "init_ram_file.txt"
FLAG_TEST = False

# Variables globales

ser = serial.Serial()
bandera_puerto_loop = 0
estado_puerto = "NO CONECTADO"
etiqueta_resultado_impresion = "Resultado"
etiqueta_resultado_modo_de_ejecucion = ""
etiqueta_resultado_modo_de_ejecucion_valor_MIPS = ""
etiqueta_resultado_pc = ""
etiqueta_resultado_pc_plus_4 = ""
etiqueta_contador_ciclos = ""
etiqueta_instruction_fetch = ""
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
    }.get (x, '11111111')  #11111111 es el por defecto


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
				activarBotones (1)
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
root.geometry ("560x760+0+0") #Tamanio
root.minsize (height=560, width=760)
root.maxsize (height=560, width=760)

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
canvasValoresMIPS.config (width = 340, height = 530)
canvasValoresMIPS.create_rectangle (5, 5, 340, 530, outline='gray60')
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
etiquetaModoEjecucionValorMIPS.place (x = 580,  y = 70)

etiquetaPC = Label (root, text = "Contador de programa: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaPC.place (x = 400,  y = 100)
etiquetaPCValorMIPS = Label (root, text = etiqueta_resultado_pc,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaPCValorMIPS.place (x = 580,  y = 100)

etiquetaContadorCiclos = Label (root, text = "Contador de ciclos: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaContadorCiclos.place (x = 400,  y = 130)
etiquetaContadorCiclosValorMIPS = Label (root, text = etiqueta_contador_ciclos,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaContadorCiclosValorMIPS.place (x = 580,  y = 130)

etiquetaLatchIFID = Label (root, text = "LATCH IF/ID: ", fg = "dark green", font = "TkDefaultFont 12")
etiquetaLatchIFID.place (x = 400,  y = 190)
etiquetaPC4 = Label (root, text = "Salida adder de PC: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaPC4.place (x = 400,  y = 220)
etiquetaPC4ValorMIPS = Label (root, text = etiqueta_resultado_pc_plus_4,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaPC4ValorMIPS.place (x = 580,  y = 220)

etiquetaInstructionFetch = Label (root, text = "Instruccion: ", fg = "brown", font = "TkDefaultFont 12")
etiquetaInstructionFetch.place (x = 400,  y = 250)
etiquetaInstructionFetchValorMIPS = Label (root, text = etiqueta_instruction_fetch,\
	 fg = "black", font = "TkDefaultFont 12")
etiquetaInstructionFetchValorMIPS.place (x = 580,  y = 250)

# Titulo de la GUI 

root.title ("TP4 MIPS - Kleiner Matias, Lopez Gaston")

  
# Ejecucion de loop propio de GUI

root.mainloop()