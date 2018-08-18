`timescale 1ns / 1ps

`define NBTfiltro 8
`define NBTsignal 8
`define NRObitsBER 64
`define RAM_WIDTH  16
`define CONTADOR_MEMORIA_BITS 15
`define NBT_Sigma 11

module top_arquitectura
    (
        input uart_txd_in, 
        input CLK100MHZ,
        input [3:0] i_sw,
        input ck_rst,
        output [3:0] o_led,
        output [2:0] led0,
        output [2:0] led1,
        output [2:0] led2,
        output [2:0] led3,
        output uart_rxd_out   
    );
        
    parameter NBTfiltro=`NBTfiltro;
    parameter NBT_Sigma=`NBT_Sigma;
    parameter NBTsignal=`NBTsignal;
    parameter RAM_WIDTH= `RAM_WIDTH;
    parameter CONTADOR_MEMORIA_BITS=`CONTADOR_MEMORIA_BITS;
    parameter NRObitsBER=`NRObitsBER;


    wire [2:0] FROM_RF_module_fase_TO_topDSP_fase;
    wire [31:0] gpio_i_data_tri_i;
    wire [31:0] gpio_o_data_tri_o;
    wire reset;
    wire sys_clock;
    wire design1_clock;
    wire soft_reset;

    wire FROM_design1_lock_clock_TO_oLed1;
    wire FROM_memoria1_led_mem_TO_oLed0;
    wire FROM_memoria2_led_mem_TO_oLed0;

//seteo de coeficientes
    wire FROM_RF_module_enable_coef_set_TO_topDSP_enable_coef_set_top;
    wire FROM_RF_module_valid_coef_set_TO_topDSP_valid_coef_set_top;
    wire [NBTfiltro-1:0] FROM_RF_module_dir_coef_set_TO_topDSP_dir_coef_set_top; 
    wire [NBTfiltro-1:0] FROM_RF_module_coef_set_TO_coef_set_top;  

//manejo y seleccion de modulos 
    wire FROM_RF_module_seleccion_MuxGeneral_TO_generalMux_bit_seleccion; // Para indicar al mux general si quiero seleccionar un modulo de transmision o un modulo de recepcion
    wire [3:0] FROM_RF_module_mux_Modulo_TO_muxModulos1y2; // 4 bits indican desde el RF cual es el modulo que selecciona en el multiplexor para loggear. 
    wire  FROM_topDSP_bitPRBS1_TO_muxModulos1_bit_PRBS1;
    wire  FROM_topDSP_bitPRBS2_TO_muxModulos1_bit_PRBS2;
    wire signed [NBTsignal-1:0] FROM_topDSP_filtroTX1_TO_muxModulos1_signal_FTX1;
    wire signed [NBTsignal-1:0] FROM_topDSP_filtroTX2_TO_muxModulos1_signal_FTX2;
    wire signed [NBTsignal:0] FROM_topDSP_canal1_TO_muxModulos1_signal_canal1;
    wire signed [NBTsignal:0] FROM_topDSP_canal2_TO_muxModulos1_signal_canal2;
    wire signed [NBTsignal:0] FROM_topDSP_signalFiltroDiezmado1Mem_TO_MuxModulos2_signal_FRX1;
    wire signed [NBTsignal:0] FROM_topDSP_signalFiltroDiezmado2Mem_TO_MuxModulos2_signal_FRX2;
    wire signed [NBTsignal-1:0] FROM_topDSP_signalFiltroDiezmado1_TO_MuxModulos2_signal_FRX1;
    wire signed [NBTsignal-1:0] FROM_topDSP_signalFiltroDiezmado2_TO_MuxModulos2_signal_FRX2;
    wire [NBTsignal:0] FROM_topDSP_detector2_TO_contadoresBER_OR_MuxModulo_i_bitDetector2;
    wire [NBTsignal:0] FROM_topDSP_detector1_TO_contadoresBER_OR_MuxModulo_i_bitDetector1;
    wire [RAM_WIDTH-1:0] FROM_muxModulos1_mem1_TO_GeneralMux_data_a1;
    wire [RAM_WIDTH-1:0] FROM_muxModulos2_mem1_TO_GeneralMux_data_a2;
    wire [RAM_WIDTH-1:0] FROM_muxModulos1_mem2_TO_GeneralMux_data_b1;
    wire [RAM_WIDTH-1:0] FROM_muxModulos2_mem2_TO_GeneralMux_data_b2;
    wire [RAM_WIDTH-1:0] FROM_GeneralMux_data_general_a_TO_memoria1_dataA;
    wire [RAM_WIDTH-1:0] FROM_GeneralMux_data_general_b_TO_memoria2_dataA;

//valid
    wire FROM_topDSP_validPRBS_TO_muxModulos1_valid_PRBS;
    wire FROM_GeneralMux_valid_general_TO_memoria1y2_valid;
    wire FROM_MuxModulos1_valid_mem_TO_GeneralMux_valid_1;
    wire FROM_MuxModulos2_valid_mem_TO_GeneralMux_valid_2;
    wire FROM_topDSP_valid_FR_TO_muxModulos2_valid_FRX;

//enables    
    wire FROM_RF_module_enable_PRBS_TO_topDSP_enablePRBS;
    wire FROM_RF_module_enable_FTX_TO_topDSP_enableFTX;
    wire FROM_RF_module_enable_canal_TO_topDSP_enable_canal;
    wire FROM_RF_module_enable_FRX_TO_topDSP_enableFRX;
    wire FROM_RF_module_enable_Detector_TO_topDSP_enable_Detector;
    wire FROM_RF_module_enable_mem_TO_memoria1y2_enable;
    wire FROM_RF_module_enable_BER_TO_enableBER;

//manejo de memoria
    wire FROM_RF_module_initMem_TO_memoria1y2_init;
    wire FROM_RF_module_resetMem_TO_memoria1y2_reset;
    wire [RAM_WIDTH-1:0] FROM_memoria2_dataB_TO_RF_module_datosMemoria2;
    wire [RAM_WIDTH-1:0] FROM_memoria1_dataB_TO_RF_module_datosMemoria1;
    wire [CONTADOR_MEMORIA_BITS-1:0] FROM_RF_module_direccionLectura_TO_memoria1y2_addB;

//led de test    
    wire led_test_PRBS;
    wire ledBERSincronizado;
    wire [2:0] ledBER0;
    wire [2:0] ledBER1;
    wire [2:0] ledBER2;
    wire testRF;


    
    assign soft_reset = gpio_o_data_tri_o[31]; //bit 31 del gpio usado para reset general
    assign reset = ck_rst; //reset del micro
    assign sys_clock = CLK100MHZ; 
    assign o_led[0] = FROM_memoria1_led_mem_TO_oLed0&FROM_memoria2_led_mem_TO_oLed0; // si las dos memorias estan llenas, se enciende el led 0
    assign o_led[1] = FROM_design1_lock_clock_TO_oLed1; // led que indica que el clock del micro esta estabilizado
    assign o_led[2] = ledBERSincronizado;
    assign o_led[3] = led_test_PRBS; // led que indica que la PRBS esta funcionando, se enciende cada vez que el vector de la PRBS = SEED
    
    assign led0=ledBER0;
    assign led1=ledBER1;
    assign led2=ledBER2;
    assign led3[1]=testRF;

    

    wire [NRObitsBER-1:0] FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER1;
    wire [NRObitsBER-1:0] FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER2;
    wire [NRObitsBER-1:0] FROM_topDSP_contadorBits_TO_RF_module_contadorBits1;
    wire [NRObitsBER-1:0] FROM_topDSP_contadorBits_TO_RF_module_contadorBits2;

   
    wire valid_detector;
    wire [NBT_Sigma-1:0] FROM_RF_module_TO_topDSP_sigma_ruido;
    wire [NRObitsBER-1:0] FROM_RF_module_TO_topDSP_contador_max_BER;

    
//micro
    design_1 
    u_design_1
    (
        .clock100(design1_clock),
        .gpio_rtl_tri_i(gpio_i_data_tri_i),
        .gpio_rtl_tri_o(gpio_o_data_tri_o),
        .o_lock_clock(FROM_design1_lock_clock_TO_oLed1),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(uart_txd_in),
        .usb_uart_txd(uart_rxd_out)
    );

   
    top_DSP
    #(
    .NBTsignal(NBTsignal),
    .NBTfiltro(NBTfiltro)
    //.MAXCONTADORbits(NRObitsBER)
    )
    u_topDSP1
    (   
        .i_contador_max_BER(FROM_RF_module_TO_topDSP_contador_max_BER),
        .i_switch_Fase_Detector(FROM_RF_module_fase_TO_topDSP_fase),
        .CLK100MHZ(design1_clock), 
        .i_reset(soft_reset), 
        .i_enablePRBS(FROM_RF_module_enable_PRBS_TO_topDSP_enablePRBS), 
        .i_enableFTX(FROM_RF_module_enable_FTX_TO_topDSP_enableFTX),
        .i_enableFRX(FROM_RF_module_enable_FRX_TO_topDSP_enableFRX),
        .i_enable_canal(FROM_RF_module_enable_canal_TO_topDSP_enable_canal),
        .i_enable_Detector(FROM_RF_module_enable_Detector_TO_topDSP_enable_Detector),
        .o_bitPRBS1(FROM_topDSP_bitPRBS1_TO_muxModulos1_bit_PRBS1),
        .o_bitPRBS2(FROM_topDSP_bitPRBS2_TO_muxModulos1_bit_PRBS2),
        .o_filtroTX1(FROM_topDSP_filtroTX1_TO_muxModulos1_signal_FTX1),
        .o_filtroTX2(FROM_topDSP_filtroTX2_TO_muxModulos1_signal_FTX2),
        .o_canal1(FROM_topDSP_canal1_TO_muxModulos1_signal_canal1), 
        .o_canal2(FROM_topDSP_canal2_TO_muxModulos1_signal_canal2), 
        .o_signalFiltroDiezmado1Mem(FROM_topDSP_signalFiltroDiezmado1Mem_TO_MuxModulos2_signal_FRX1), 
        .o_signalFiltroDiezmado2Mem(FROM_topDSP_signalFiltroDiezmado2Mem_TO_MuxModulos2_signal_FRX2),
         .o_SignalDetector1(FROM_topDSP_detector1_TO_contadoresBER_OR_MuxModulo_i_bitDetector1), 
         .o_SignalDetector2(FROM_topDSP_detector2_TO_contadoresBER_OR_MuxModulo_i_bitDetector2),
        .o_valid_detector(valid_detector),
        .i_enableBER(FROM_RF_module_enable_BER_TO_enableBER),
        .o_led0(ledBER0),
        .o_led1(ledBER1),
        .o_led2(ledBER2),
        .o_contadorErroresBER1(FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER1),
        .o_contadorBitsBER1(FROM_topDSP_contadorBits_TO_RF_module_contadorBits1),  
        .o_contadorErroresBER2(FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER2), 
        .o_contadorBitsBER2(FROM_topDSP_contadorBits_TO_RF_module_contadorBits2),
        /**
        .o_contadorErroresBER3(outContErr3),
        .o_contadorBitsBER3(outContBits3),  
        .o_contadorErroresBER4(outContErr4),
        .o_contadorBitsBER4(outContBits4),  */
        .o_validPRBS(FROM_topDSP_validPRBS_TO_muxModulos1_valid_PRBS),
        .o_ledTestBER(ledBERSincronizado),
        .i_sigma_ruido(FROM_RF_module_TO_topDSP_sigma_ruido),  /////////ddddddddddddddddddddddddddddd
        .o_ledTest2(led_test_PRBS),
        .o_validFR(FROM_topDSP_valid_FR_TO_muxModulos2_valid_FRX),
        .i_enable_coef_set_top(FROM_RF_module_enable_coef_set_TO_topDSP_enable_coef_set_top), //habilita el seteo de los coeficientes de los filtros TX y RX
        .i_valid_coef_set_top(FROM_RF_module_valid_coef_set_TO_topDSP_valid_coef_set_top), //indica un coeficiente valido de los filtros TX y RX
        .i_dir_coef_set_top(FROM_RF_module_dir_coef_set_TO_topDSP_dir_coef_set_top), //indica cual es el coeficiente que se esta seteando (primer coeficiente, segundo, etc)
        .i_coef_set_top(FROM_RF_module_coef_set_TO_coef_set_top)    //indica el coeficiente en cuestion que se setea
    );


//mux 1, gestiona modulos de transmision    
    Mux_Modulos
    u_muxModulos1
    (
        .CLK100MHZ(design1_clock),
        .i_reset(soft_reset), 
        .i_select_module(FROM_RF_module_mux_Modulo_TO_muxModulos1y2), 
        .i_bit_PRBS1(FROM_topDSP_bitPRBS1_TO_muxModulos1_bit_PRBS1),
        .i_bit_PRBS2(FROM_topDSP_bitPRBS2_TO_muxModulos1_bit_PRBS2),
        .i_signal_FTX1(FROM_topDSP_filtroTX1_TO_muxModulos1_signal_FTX1),
        .i_signal_FTX2(FROM_topDSP_filtroTX2_TO_muxModulos1_signal_FTX2),
        .i_valid_PRBS(FROM_topDSP_validPRBS_TO_muxModulos1_valid_PRBS),
        .i_valid_FRX(0),
        .i_valid_detector(0),
        .i_valid_TX(1),  // siempre a 1 porque la memoria trabaja con valid por nivel y el filtro saca 1 simbolo por pulso de clock. El canal usa el mismo valid que el FTX.
        .i_signal_canal1(FROM_topDSP_canal1_TO_muxModulos1_signal_canal1),
        .i_signal_canal2(FROM_topDSP_canal2_TO_muxModulos1_signal_canal2),
        .i_signal_FRX1(0), // el mux modulos1 gestiona la parte de transmision, los modulos de recepcion estan conectados a 0
        .i_signal_FRX2(0),
        .i_bitDetector1(0),
        .i_bitDetector2(0),
        .o_mem1(FROM_muxModulos1_mem1_TO_GeneralMux_data_a1), // datos y valid del respectivo modulo seleccionado que van a general mux
        .o_mem2(FROM_muxModulos1_mem2_TO_GeneralMux_data_b1),
        .o_valid_mem(FROM_MuxModulos1_valid_mem_TO_GeneralMux_valid_1)
    );
   
//mux 2, gestiona modulos de recepcion       
    Mux_Modulos
    u_muxModulos2
    (
        .CLK100MHZ(design1_clock),
        .i_reset(soft_reset), 
        .i_select_module(FROM_RF_module_mux_Modulo_TO_muxModulos1y2),
        .i_bit_PRBS1(0), // el mux modulos2 gestiona la parte de recepcion, los modulos de transmision estan conectados a 0
        .i_bit_PRBS2(0),
        .i_signal_FTX1(0),
        .i_signal_FTX2(0),
        .i_valid_PRBS(0),
        .i_valid_TX(1),
        .i_valid_FRX(FROM_topDSP_valid_FR_TO_muxModulos2_valid_FRX),
        .i_signal_canal1(0),
        .i_signal_canal2(0),
        .i_signal_FRX1(FROM_topDSP_signalFiltroDiezmado1Mem_TO_MuxModulos2_signal_FRX1),
        .i_signal_FRX2(FROM_topDSP_signalFiltroDiezmado2Mem_TO_MuxModulos2_signal_FRX2),
        .i_bitDetector1(FROM_topDSP_detector1_TO_contadoresBER_OR_MuxModulo_i_bitDetector1),
        .i_bitDetector2(FROM_topDSP_detector2_TO_contadoresBER_OR_MuxModulo_i_bitDetector2),
        .i_valid_detector(valid_detector),
        .o_mem1(FROM_muxModulos2_mem1_TO_GeneralMux_data_a2), // datos y valid del respectivo modulo seleccionado que van a general mux
        .o_mem2(FROM_muxModulos2_mem2_TO_GeneralMux_data_b2),
        .o_valid_mem(FROM_MuxModulos2_valid_mem_TO_GeneralMux_valid_2)
    );    
   
//mux general, con un bit de seleccion se indica cual de los datos (mux 1 o mux 2) se va a utilizar    
    GeneralMux
    u_GeneralMux1
    (
        .CLK100MHZ(design1_clock),
        .i_reset(soft_reset), 
        .i_bit_seleccion(FROM_RF_module_seleccion_MuxGeneral_TO_generalMux_bit_seleccion), // un bit indica si se seleccionan los datos del mux1 (transmision) o mux2 (recepcion)
        .i_valid_1(FROM_MuxModulos1_valid_mem_TO_GeneralMux_valid_1),
        .i_valid_2(FROM_MuxModulos2_valid_mem_TO_GeneralMux_valid_2),
        .i_data_a1(FROM_muxModulos1_mem1_TO_GeneralMux_data_a1),
        .i_data_b1(FROM_muxModulos1_mem2_TO_GeneralMux_data_b1),
        .i_data_a2(FROM_muxModulos2_mem1_TO_GeneralMux_data_a2),
        .i_data_b2(FROM_muxModulos2_mem2_TO_GeneralMux_data_b2),
        .o_valid_general(FROM_GeneralMux_valid_general_TO_memoria1y2_valid), // valid y datos que van a la memoria
        .o_data_general_a(FROM_GeneralMux_data_general_a_TO_memoria1_dataA),
        .o_data_general_b(FROM_GeneralMux_data_general_b_TO_memoria2_dataA)
    );   
    
    
    RF_module
    #(
       .CONTADOR_MEMORIA_BITS(CONTADOR_MEMORIA_BITS)
    )
    u_RF_module1
    (   .o_fase(FROM_RF_module_fase_TO_topDSP_fase),
        .CLK100MHZ(design1_clock), 
        .i_reset(soft_reset), 
        .i_gpio(gpio_o_data_tri_o[30:0]), // el bit 31 del gpio lo usamos para reset general (soft_reset)
        .o_mux_Modulo(FROM_RF_module_mux_Modulo_TO_muxModulos1y2),
        .o_enable_PRBS(FROM_RF_module_enable_PRBS_TO_topDSP_enablePRBS),
        .o_enable_FTX(FROM_RF_module_enable_FTX_TO_topDSP_enableFTX),
        .o_enable_mem(FROM_RF_module_enable_mem_TO_memoria1y2_enable),
        .o_enable_canal(FROM_RF_module_enable_canal_TO_topDSP_enable_canal),
        .o_enable_FRX(FROM_RF_module_enable_FRX_TO_topDSP_enableFRX),
        .o_enable_detector(FROM_RF_module_enable_Detector_TO_topDSP_enable_Detector),  
        .o_enable_ContadorBER1(FROM_RF_module_enable_BER_TO_enableBER),  
        .o_direccionLectura(FROM_RF_module_direccionLectura_TO_memoria1y2_addB), 
        .o_initMem(FROM_RF_module_initMem_TO_memoria1y2_init), 
        .o_resetMem(FROM_RF_module_resetMem_TO_memoria1y2_reset),
        .o_seleccion_MuxGeneral(FROM_RF_module_seleccion_MuxGeneral_TO_generalMux_bit_seleccion),
        .i_datosMemoria1(FROM_memoria1_dataB_TO_RF_module_datosMemoria1),
        .i_datosMemoria2(FROM_memoria2_dataB_TO_RF_module_datosMemoria2),
        .o_datosMemoria1ToMicro(gpio_i_data_tri_i[15:0]),
        .o_datosMemoria2ToMicro(gpio_i_data_tri_i[31:16]),
        .o_enable_coef_set(FROM_RF_module_enable_coef_set_TO_topDSP_enable_coef_set_top),
        .o_valid_coef_set(FROM_RF_module_valid_coef_set_TO_topDSP_valid_coef_set_top),
        .o_dir_coef_set(FROM_RF_module_dir_coef_set_TO_topDSP_dir_coef_set_top),
        .o_coef_set(FROM_RF_module_coef_set_TO_coef_set_top),
        .i_contadorErroresBER1(FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER1),
        .i_contadorErroresBER2(FROM_topDSP_contador_Errores_TO_RF_module_contadorErroresBER2),
        .i_contadorBitsBER1(FROM_topDSP_contadorBits_TO_RF_module_contadorBits1),
        .i_contadorBitsBER2(FROM_topDSP_contadorBits_TO_RF_module_contadorBits2),
        .o_ledRF(testRF),
        .o_sigma(FROM_RF_module_TO_topDSP_sigma_ruido),
        .o_contador_max_BER(FROM_RF_module_TO_topDSP_contador_max_BER)
    );
       

          
    memoria
    #(      
        .RAM_WIDTH(RAM_WIDTH)
    )
    u_memoria_1
    (
        .i_dataA(FROM_GeneralMux_data_general_a_TO_memoria1_dataA), //datos a guardar.
        .i_valid(FROM_GeneralMux_valid_general_TO_memoria1y2_valid),  // valid de los datos a guardar.
        .i_init(FROM_RF_module_initMem_TO_memoria1y2_init),
        .i_enable(FROM_RF_module_enable_mem_TO_memoria1y2_enable), 
        .CLK100MHZ(design1_clock),
        .i_reset(FROM_RF_module_resetMem_TO_memoria1y2_reset), 
        .i_addB(FROM_RF_module_direccionLectura_TO_memoria1y2_addB), //direccion del dato a leer
        .o_led_mem(FROM_memoria1_led_mem_TO_oLed0), //indica si la memoria esta llena o no
        .o_dataB(FROM_memoria1_dataB_TO_RF_module_datosMemoria1) //dataB es la salida de datos de la memoria, indicaria el valor que contiene la posicion indicada en i_addB  
    );

    memoria
    #(
        .RAM_WIDTH(RAM_WIDTH)
    )
    u_memoria_2
    (
        .i_dataA(FROM_GeneralMux_data_general_b_TO_memoria2_dataA), //datos a guardar.
        .i_valid(FROM_GeneralMux_valid_general_TO_memoria1y2_valid), // valid de los datos a guardar.
        .i_init(FROM_RF_module_initMem_TO_memoria1y2_init),
        .i_enable(FROM_RF_module_enable_mem_TO_memoria1y2_enable),
        .CLK100MHZ(design1_clock),
        .i_reset(FROM_RF_module_resetMem_TO_memoria1y2_reset), 
        .i_addB(FROM_RF_module_direccionLectura_TO_memoria1y2_addB), //direccion del dato a leer
        .o_led_mem(FROM_memoria2_led_mem_TO_oLed0), //indica si la memoria esta llena o no
        .o_dataB(FROM_memoria2_dataB_TO_RF_module_datosMemoria2) //dataB es la salida de datos de la memoria, indicaria el valor que contiene la posicion indicada en i_addB  
    );
    
endmodule