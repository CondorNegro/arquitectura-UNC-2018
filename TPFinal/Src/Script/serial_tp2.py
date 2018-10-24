# TP 3. BIP I.
# Arquitectura de Computadoras. FCEFyN. UNC.
# Anio 2018.
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
CANT_STOP_BITS = 2


# Variables globales

ser = serial.Serial()
banderaPuertoLoop = 0
estadoPuerto = "NO CONECTADO"
etiquetaResultadoImpresion = "Resultado"
lock = threading.Lock()

# Funcion de traduccion del nombre de la operacion a su opcode correspondiente.
def getOPCODE (x):
    return {
        'Soft reset': '10000000',
        'Init': '01000000',
    }.get (x, '11111111')  #11111111 es el por defecto


# Funcion para desactivar botones

def desactivarBotones():
	lock.acquire()
	botonDesconectarFPGA.config (state = DISABLED)
	botonIniciarBIP.config (state = DISABLED)
	lock.release()

# Funcion para activar botones, sigue el comportamiento de una maquina de estados

def activarBotones():
	lock.acquire()
	botonDesconectarFPGA.config (state = ACTIVE)
	botonIniciarBIP.config (state = ACTIVE)
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
	global banderaPuertoLoop
	global ser
	global estadoPuerto
	global currentState
	
	print 'Thread de conexion/desconexion OK.'
	try:
		if (puerto == "disconnect" and estadoPuerto != "NO CONECTADO"):
			estadoPuerto = "NO CONECTADO"
			etiquetaPuertoEstado.config (text = estadoPuerto, fg = "red")
			desactivarBotones()
			botonConectarFPGA.config (state = ACTIVE)
			banderaPuertoLoop = 0
			ser.close()
			print 'Desconexion de puerto.'
		elif banderaPuertoLoop == 0:
			if puerto == "loop":
				ser = serial.serial_for_url ('loop://', timeout = 1)  #Configuracion del loopback test de esta forma
				ser.isOpen()        #Abertura del puerto.
				ser.timeout = None  #Siempre escucha
				ser.flushInput()	#Limpieza de buffers
				ser.flushOutput()
				estadoPuerto = "loop - OK"
				etiquetaPuertoEstado.config (text = estadoPuerto, fg = "dark green")
				activarBotones()
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
					estadoPuerto = str (puerto) + " - OK"
					etiquetaPuertoEstado.config (text = estadoPuerto, fg = "dark green")
					banderaPuertoLoop = 1
					ser.isOpen()        	#Abertura del puerto.
					ser.timeout = None    	#Siempre escucha
					ser.flushInput()		#Limpieza de buffers
					ser.flushOutput()
					activarBotones()
					print 'Conexion OK en puerto : ', puerto
				except SerialException:
					estadoPuerto = str (puerto) + " - ERROR"
					etiquetaPuertoEstado.config (text = estadoPuerto, fg = "red")
					desactivarBotones()
					botonConectarFPGA.config(state = ACTIVE)
					print 'Error al tratar de abrir el puerto:', puerto
		else :
			print "Puerto ya configurado"
	except: 
		print 'Error en la conexion/desconexion.'
		activarBotones()


# Funcion que recibe el resultado obtenido de la ALU

def readResultado():
	valor_ACC = ""
	contador_bytes = 0
	valor_CC = ""
	time.sleep (0.2)
	while ((ser.inWaiting() > 0) and (contador_bytes < 5)): #inWaiting -> cantidad de bytes en buffer esperando.
		contador_bytes = contador_bytes + 1
		lectura = ser.read (1)
		etiquetaResultadoImpresion = bin(ord (lectura))[2:][::-1]
		
		for i in range (0, 8 - len(etiquetaResultadoImpresion), 1):
			if (i != 8):	
				etiquetaResultadoImpresion = etiquetaResultadoImpresion + '0'
		print '>>',
		print etiquetaResultadoImpresion
		print '>>',
		print lectura
		if (contador_bytes > 4):	#Reiniciar contador
			contador_bytes = 0
		elif (contador_bytes < 3):	# Contador de ciclos.
			if (contador_bytes < 2):	# Parte baja.
				valor_CC = etiquetaResultadoImpresion
			else:						# Parte alta.
				valor_CC = etiquetaResultadoImpresion + valor_CC
		else : # Valor del Acumulador
			if (contador_bytes < 4):	# Parte baja.
				valor_ACC = etiquetaResultadoImpresion
			else:						# Parte alta.
				valor_ACC = etiquetaResultadoImpresion + valor_ACC
	etiquetaResultado.config (text = "CC:  " + valor_CC + " \n " + "ACC: " + valor_ACC, fg = "dark green")
	
		

# Funcion para setear los datos que forman parte de la operacion
# @param: dato 	Dato a cargar
def setDato ():
	try:
		hiloSetDato = threading.Thread (target = setDatoViaThread) 
		hiloSetDato.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		activarBotones()
		
	
# Funcion que ejecuta el hilo que setea los datos que forman parte de la operacion
# @param: dato 	Dato a cargar
def setDatoViaThread ():
	desactivarBotones()
	print 'Thread de seteo de datos OK.'
	global etiquetaResultadoImpresion
	try:
		ser.flushInput()
		ser.flushOutput()
		dato = getOPCODE ('Soft reset')
		if (len (dato) == 8):
			ser.write (chr (int (dato, 2)))
			time.sleep (1.0) #Espera.
			#readResultado() #Lectura de resultado
		else:
			print 'Warning: Deben ser 8 bits.'
			etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
		dato = getOPCODE ('Init')
		if (len (dato) == 8):
			ser.write (chr (int (dato, 2)))
			#time.sleep (1.0) #Espera.
			readResultado() #Lectura de resultado
		else:
			print 'Warning: Deben ser 8 bits.'
			etiquetaResultado.config (text = "Warning: Deben ser 8 bits", fg = "red")
		activarBotones()
	except: 
		print 'Error en el seteo de los datos.'
		etiquetaResultado.config (text = "ERROR_LOG", fg = "red")
		activarBotones()
		

# Funcion al presionar el boton salir.	
def salir():
	print 'Fin del programa.'
	exit(1)		

		
		



	
#Ventana principal - Configuracion

root = Tk() 
root.geometry ("350x380+0+0") #Tamanio
root.minsize (height=350, width=380)
root.maxsize (height=350, width=380)

# Rectangulos divisorios

canvasPuerto = Canvas (root)
canvasPuerto.create_rectangle (5, 5, 340, 80, outline='gray60')
canvasPuerto.place (x=1, y=1)

canvasOperaciones = Canvas (root)
canvasOperaciones.config (width = 340, height = 300)
canvasOperaciones.create_rectangle (5, 5, 340, 180, outline='gray60')
canvasOperaciones.place (x=1, y=100)



# Text boxes

campoPuerto = Entry (root) #Para ingresar texto.
campoPuerto.place (x = 87, y = 25)

# Botones

botonIniciarBIP = Button (root, text = "Iniciar BIP I", command = lambda: setDato (), state = DISABLED)
botonIniciarBIP.place (x = 100, y = 150, width = 150, height = 30)

### Botones - Conexion y desconexion FPGA

botonConectarFPGA = Button (root, text = "Conectar", command = lambda: conectarFPGA (str (campoPuerto.get())))
botonConectarFPGA.place (x = 250, y = 10, width = 80, height = 30)
botonDesconectarFPGA = Button (root, text = "Desconectar", state = DISABLED, command = lambda: conectarFPGA ("disconnect"))
botonDesconectarFPGA.place (x = 250, y = 40, width = 80, height = 30)

### Boton - Finalizar programa
botonSalir = Button (root, text = "Exit", command = lambda: salir(), state = ACTIVE)
botonSalir.place (x = 150, y = 300, width = 80, height = 30)




# Labels

etiquetaPuerto = Label (root, text = "Serial Port")
etiquetaPuerto.place (x = 20, y = 25)
etiquetaPuertoMensajeEstado = Label (root, text = "Status     : ")
etiquetaPuertoMensajeEstado.place (x = 20, y = 50)
etiquetaPuertoEstado = Label (root, text = estadoPuerto, fg = "red")
etiquetaPuertoEstado.place (x = 87, y = 50)
etiquetaInputDatos = Label (root, text = "Iniciar sistema: ", font = "TkDefaultFont 12")
etiquetaInputDatos.place (x = 10,  y = 110)
etiquetaOutputResultado = Label (root, text = "Resultado: ", font = "TkDefaultFont 12")
etiquetaOutputResultado.place (x = 10,  y = 200)
etiquetaResultado = Label (root, text = etiquetaResultadoImpresion, fg = "dark green", font = "TkDefaultFont 12")
etiquetaResultado.place (x = 10, y = 230)

# Titulo de la GUI 

root.title ("TP3 BIP I - Kleiner Matias, Lopez Gaston")

  
# Ejecucion de loop propio de GUI

root.mainloop()