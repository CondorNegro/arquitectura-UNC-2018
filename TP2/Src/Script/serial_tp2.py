try:
    from Tkinter import *
except ImportError:
    raise ImportError,"Se requiere el modulo Tkinter"

# coding: utf-8
import time
import serial
from serial import *
import random
import os
import threading  

 
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

# Funcion para desactivar botones

def desactivarBotones():
	lock.acquire()
	botonDesconectarFPGA.config (state = DISABLED)
	botonaPrimerOperando.config (state = DISABLED)
	botonaSegundoOperando.config (state = DISABLED)
	botonaOperacion.config (state = DISABLED)
	lock.release()

# Funcion para activar botones

def activarBotones():
	lock.acquire()
	botonaPrimerOperando.config (state = ACTIVE)
	botonaSegundoOperando.config (state = ACTIVE)
	botonaOperacion.config (state = ACTIVE)
	botonDesconectarFPGA.config (state = ACTIVE)
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
	
	print 'Thread de conexion/desconexion OK.'
	try:
		if (puerto == "disconnect" and estado_puerto != "NO CONECTADO"):
			estadoPuerto="NO CONECTADO"
			etiquetaPuertoEstado.config (text = estado_puerto, fg = "red")
			desactivarBotones()
			botonConectarFPGA.config (state = ACTIVE)
			banderaPuertoLoop = 0
			ser.close()
			print 'Desconexion de puerto.'
		elif banderaPuertoLoop == 0:
			if puerto == "loop":
				ser = serial.serial_for_url ('loop://', timeout=1)  #Configuracion del loopback test de esta forma
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
					etiquetaPuertoEstado.config (text = estado_puerto, fg = "red")
					desactivarBotones()
					botonConectarFPGA.config(state=ACTIVE)
					print 'Error al tratar de abrir el puerto:', puerto
		else :
			print "Puerto ya configurado"
	except: 
		print 'Error en la conexion/desconexion.'
		activarBotones()
		#exit(1)




		

	
	
def loguear():
	activarBotonesOperacionLog()

def loguearModuloEspecifico(numeroModulo):
	try:
		HiloLogModulo = threading.Thread(target=loguearModuloViaThread, args=(numeroModulo,)) 
		HiloLogModulo.start()
	except:
		print 'Sistema operativo denego acceso a recursos.'
		desactivarBotonesOperacionLog()
		activarBotones()
		
	

def loguearModuloViaThread(numeroModulo):
	desactivarBotones()
	desactivarBotonesOperacionLog()
	print 'Thread de logueo OK.'
	global etiqueta_Resulado_impreIon
	try:
		ser.flushInput()
		ser.flushOutput()
		entry='0b101'
		final='0b010'
		
		StrTramaPrimerByte=chr(int(entry[2:5]+'0'+'0001',2)) #Cabecera.
		StrTramaUltimoByte=chr(int(final[2:5]+'0'+'0001',2)) #Cola.
		StrLHigh=chr(0x00) #Long
		StrLLow=chr(0x00) #Long
		strDeviceLogueo=chr(numeroModulo) #Device
		strOperacion='1'
		strTrama=StrTramaPrimerByte+StrLHigh+StrLLow+strDeviceLogueo+strOperacion+StrTramaUltimoByte
		ser.write(strTrama)
		time.sleep(0.5) #Para esperar que fpga me mande de vuelta los datos.(2 segundos)	
		while ser.inWaiting()>7: #inWaiting-> cantidad de bytes en buffer esperando.
			lectura=ser.read(8)
			print '>>',
			print lectura
			etiqueta_Resultad_impresioIlectura
			etiquetaResultado.config(text=etiqueta_Resultado_impresion, fg="dark green")
		activarBotones()
	except: 
		print 'Error en el logueo.'
		etiquetaResultado.config(text="ERROR_LOG", fg="red")
		activarBotones()
		
		
	
def leer():
	if(flagBER):
		cantDatos=cantDatosBER
		leerCantDatos(cantDatosBER)
	else:
		activarBotonStartLectura()

	
def leerCantDatos(cantDatos):
	if(cantDatos<1 or cantDatos > 16384):
		print 'Ingrese un valor correcto (del 1 al 16384).'
		activarBotones()
		desactivarBotonStartLectura()
		etiqueta_lectura_impresion="Valor incorrecto (del 1 al 16384)"
		etiquetaLectura.config(text=etiqueta_lectura_impresion, fg="red",font = "TkDefaultFont 12")
		etiquetaLectura.place(x=950, y=70)
			
	else:
		etiqueta_lectura_impresion="Valor correcto"
		etiquetaLectura.config( text=etiqueta_lectura_impresion, fg="dark green",font = "TkDefaultFont 12")
		etiquetaLectura.place(x=950, y=70)
		desactivarBotonStartLectura()
		try:
			HiloLeerModulo = threading.Thread(target=leerViaThread, args=(cantDatos,)) 
			HiloLeerModulo.start()
		
		except:
			print 'Sistema operativo denego acceso a recursos.'
			activarBotones()
			
		
		
def leerViaThread(cantDatos):
	desactivarBotones()

	print 'Thread de lectura OK.'
	global etiqueta_Resulado_impreIon
	global cadenaDeArchivo
	try:
		ser.flushInput()
		ser.flushOutput()
			
		StrDevice=chr(0x00) #Device
		
		entry='0b101'
		final='0b010'
		strOperacion='2'
		direccionDeLecturaLSB=0x00
		direccionDeLecturaMSB=0x00
		contadorTramasInvalidasPorPosicion=0
		contadorDatos=0
		numberOfSequence=0x00 #prueba de device
		while(contadorDatos <= (cantDatos-1)):
				StrDeviceLectura=chr(numberOfSequence) #Device
				StrTramaPrimerByteLectura=chr(int(entry[2:5]+'0'+'0011',2)) #Cabecera.
				StrTramaUltimoByteLectura=chr(int(final[2:5]+'0'+'0011',2)) #Cola.
				StrLHighLectura=chr(0x00) #Long
				StrLLowLectura=chr(0x00) #Long
				strTramaLectura=StrTramaPrimerByteLectura+StrLHighLectura+StrLLowLectura+StrDeviceLectura+strOperacion+chr(direccionDeLecturaMSB)+chr(direccionDeLecturaLSB)+StrTramaUltimoByteLectura
				ser.write(strTramaLectura)
				time.sleep(0.03)
				if (ser.inWaiting()>8): #inWaiting-> cantidad de bytes en buffer esperando.
					#print "pido direccion ", direccionDeLecturaMSB, direccionDeLecturaLSB
					lectura=ser.read(9)
					h=lectura[0] #header
					l=lectura[1] #largo
					j=lectura[2]
					d=lectura[3] #device
					dato0=lectura[4]
					dato1=lectura[5]
					dato2=lectura[6]
					dato3=lectura[7]
					t=lectura[8] #tail.
					hex1=h.encode("hex")
					hex2=l.encode("hex")
					hex3=d.encode("hex")  #device in hex!
					hex4=dato0.encode("hex")
					hex5=dato1.encode("hex")
					hex6=dato2.encode("hex")
					hex7=dato3.encode("hex")
					hex8=t.encode("hex")


					flagTramaValida=0
					if(hex1=='a4' and hex8=='41'): 
						flagTramaValida=1
						#print cantDatos-1
						#print contadorDatos
					if((flagTramaValida!=0) and (hex3==chr(numberOfSequence).encode("hex"))):
						contadorDatos=contadorDatos+1
						if(direccionDeLecturaLSB==0xFF):
							numberOfSequence=0
							direccionDeLecturaLSB=0x00
							direccionDeLecturaMSB=direccionDeLecturaMSB+2
							print 'Aumento de direccionLecturaMSB: ',
							print direccionDeLecturaMSB
						else:
							numberOfSequence=numberOfSequence+1
							direccionDeLecturaLSB=direccionDeLecturaLSB+1
						
						contadorTramasInvalidasPorPosicion=0
						#print hex4+hex5+hex6+hex7
						cadenaDeArchivo+=hex4+hex5+hex6+hex7+'\n'
					elif(flagTramaValida==0):
						print 'Trama invalida.'
						contadorTramasInvalidasPorPosicion=contadorTramasInvalidasPorPosicion+1
						if(contadorTramasInvalidasPorPosicion>20):
							print 'Mas de 20 tramas invalidas en la misma posicion de memoria.'
							print 'Fin del programa.'
							exit(1)					
					

		print "Termino la lectura de ", contadorDatos, " datos de la memoria."			
		FileHandler(cadenaDeArchivo)
		cadeaDeArchivo=""
		
		etiqueta_Resultado_impresion="Lectura_OK"
		etiquetaResultado.config(text=etiqueta_Resultado_impresion, fg="dark green")
		activarBotones()
	except: 
		print 'Error en la lectura.'
		etiquetaResultado.config(text="ERROR_LECTURA", fg="red")
		activarBotones()
		

		

# Funcion al presionar el boton salir.	
def salir():
	print 'Fin del programa.'
	exit(1)		

		
		



	
#Ventana principal - Configuracion

root = Tk() 
root.geometry ("380x600+0+0") #Tamanio
root.minsize (height=600, width=380)
root.maxsize (height=600, width=380)

# Rectangulos divisorios

canvasPuerto = Canvas (root)
canvasPuerto.create_rectangle (5, 5, 340, 80, outline='gray60')
canvasPuerto.place (x=1, y=1)

canvasOperaciones = Canvas (root)
canvasOperaciones.config (width=340, height=420)
canvasOperaciones.create_rectangle (5, 5, 340, 420, outline='gray60')
canvasOperaciones.place (x=1, y=100)



# Text boxes

campoPuerto = Entry (root) #Para ingresar texto.
campoPuerto.place (x = 87, y = 25)
campoPrimerOperando = Entry (root) #Para ingresar texto.
campoPrimerOperando.place (x = 200, y = 190)
campoSegundoOperando = Entry (root) #Para ingresar texto.
campoSegundoOperando.place (x = 200, y = 230)

# Menues desplegables
var = StringVar (root)
var.set ('Selecciones la operacion')
opciones = ['ADD', 'SUB', 'AND', 'OR', 'XOR', 'SRA', 'SRL', 'NOR']
menuOpCode = OptionMenu (root, var, *opciones)
menuOpCode.config (width = 20)
menuOpCode.pack (side = 'left', padx = 30, pady = 30)
menuOpCode.place (x = 170, y = 270)

# Botones

botonPrimerOperando = Button (root, text = "Cargar Primer operando", command = lambda: setPrimerOperando())
botonPrimerOperando.place (x = 10, y = 190, width = 150, height = 30)
botonSegundoOperando = Button (root, text="Cargar Segundo operando", command = lambda: setSegundoOperando())
botonSegundoOperando.place (x = 10, y = 230, width = 150, height = 30)
botonOperacion = Button (root, text = "Cargar Operacion", command = lambda: setCodigoOperacion())
botonOperacion.place (x = 10, y = 270, width = 150, height = 30)

### Conexion y desconexion FPGA
botonConectarFPGA = Button (root, text = "Conectar", command = lambda: conectarFPGA (str (campoPuerto.get())))
botonConectarFPGA.place (x = 250, y = 10, width = 80, height = 30)
botonDesconectarFPGA = Button (root, text = "Desconectar", state = DISABLED, command = lambda: conectarFPGA ("disconnect"))
botonDesconectarFPGA.place (x = 250, y = 40, width = 80, height = 30)

### Finalizar programa
botonSalir = Button (root, text = "Exit", command = lambda: salir(), state = ACTIVE)
botonSalir.place (x = 150, y = 550, width = 80, height = 30)




# Labels

etiquetaPuerto = Label (root, text = "Serial Port")
etiquetaPuerto.place (x = 20, y = 25)
etiquetaPuertoMensajeEstado = Label (root, text = "Status     : ")
etiquetaPuertoMensajeEstado.place (x = 20, y = 50)
etiquetaPuertoEstado = Label (root, text = estadoPuerto, fg = "red")
etiquetaPuertoEstado.place (x = 87, y = 50)
etiquetaInputDatos = Label (root, text = "Ingreso de datos: ", font = "TkDefaultFont 12")
etiquetaInputDatos.place (x = 10,  y = 110)
etiquetaOutputResultado = Label (root, text = "Resultado: ", font = "TkDefaultFont 12")
etiquetaOutputResultado.place (x = 10,  y = 360)
etiquetaResultado = Label (root, text = etiquetaResultadoImpresion, fg = "dark green", font = "TkDefaultFont 12")
etiquetaResultado.place (x = 10, y = 400)

# Titulo de la GUI 

root.title ("TP2 UART - Kleiner Matias, Lopez Gaston")

  
# Ejecucion de loop propio de GUI

root.mainloop()