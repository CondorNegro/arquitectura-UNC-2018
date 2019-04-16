 `timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del modulo debug_unit.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////



module test_bench_debug_unit();
       
   // Parametros
  parameter OUTPUT_WORD_LENGTH = 8;    //  Cantidad de bits de la palabra a transmitir.
  parameter HALT_INSTRUCTION = 32'hFFFFFFFF; //  Opcode de la instruccion HALT.
  parameter ADDR_MEM_PROG_LENGTH = 10;      //  Cantidad de bits del bus de direcciones de la memoria de programa.
  parameter ADDR_MEM_DATOS_LENGTH = 10;     //  Cantidad de bits del bus de direcciones de la memoria de datos.
  parameter CANTIDAD_ESTADOS = 13;      //  Cantidad de estados
  parameter LONGITUD_INSTRUCCION = 32;  //  Cantidad de bits de la instruccion
  parameter CANT_BITS_REGISTRO = 32;
  parameter CANT_DATOS_DATABASE = 3; // Cantidad de datos a traer del database
  parameter CANT_COLUMNAS_MEM_DATOS = 4;
  parameter RAM_DATOS_DEPTH = 1024;
  parameter CANT_REGISTROS = 3;
   
   //Todo puerto de salida del modulo es un cable.
   //Todo puerto de estimulo o generacion de entrada es un registro.
   
   // Entradas.
   reg  reg_i_clock;
   reg  reg_i_reset;
   reg  reg_i_tx_done;
   reg  reg_i_rx_done;
   reg  [OUTPUT_WORD_LENGTH - 1 : 0]  reg_i_data_rx;
   reg  reg_i_soft_reset_ack;
   reg reg_flag_halt;
   reg [LONGITUD_INSTRUCCION - 1 : 0] reg_dato_database;
   reg [CANT_BITS_REGISTRO - 1 : 0] reg_dato_mem_datos;
   reg reg_bit_sucio;
   reg [CANT_BITS_REGISTRO - 1 : 0] reg_reg_data_from_register_file;
    

   // Salidas.
   wire wire_o_tx_start;
   wire [OUTPUT_WORD_LENGTH - 1 : 0]  wire_o_data_tx;
   wire wire_o_soft_reset;
   wire wire_o_write_mem_programa;
   wire [ADDR_MEM_PROG_LENGTH - 1 : 0]  wire_o_addr_mem_programa;
   wire [LONGITUD_INSTRUCCION - 1 : 0]  wire_o_dato_mem_programa;
   wire wire_modo_ejecucion;
   wire wire_enable_mem;
   wire wire_rsta_mem;
   wire wire_regcea_mem;
   wire wire_led;
   wire wire_enable_pc;
   wire wire_control_mux_addr_mem_top_if;
   wire [clogb2 (CANT_DATOS_DATABASE - 1) - 1 : 0] wire_control_database;
   wire wire_enable_pipeline;
   wire wire_control_write_read_mem_datos;
   wire wire_control_address_mem_datos;
   wire wire_enable_mem_datos;
   wire [ADDR_MEM_DATOS_LENGTH + clogb2 (CANT_COLUMNAS_MEM_DATOS - 1) - 1 : 0] wire_address_debug_unit;
   wire [clogb2 (CANT_REGISTROS - 1) - 1 : 0] wire_reg_read_to_register_file;
                          
   
   
  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
      input integer depth;
          for (clogb2=0; depth>0; clogb2=clogb2+1)
              depth = depth >> 1;
  endfunction
   
   initial    begin
        reg_i_clock = 1'b0;
        reg_i_reset = 1'b1; // Reset en 0, se resetea cuando se pone a 1. (Normal cerrado el boton del reset).
        reg_i_tx_done = 1'b0;
        reg_i_data_rx = 0;
        reg_i_rx_done = 1'b0; //tiene que pasar a 1 cuando recibe el dato completamente.
        reg_i_soft_reset_ack = 1'b1; //despues tiene que valer 0.
        reg_flag_halt = 0;
        reg_dato_database = 32'b10101010111111110000000011110000;
        reg_dato_mem_datos = 10;
        reg_bit_sucio = 0;
        reg_reg_data_from_register_file = 4;

        
        #10 reg_i_reset = 1'b0;
        #10 reg_i_reset = 1'b1;
        
        //hasta aca estoy en el estado 1 (ESPERA).
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        
        //ahora paso a estado 2 (SOFT_RESET).
        #50 reg_i_soft_reset_ack = 1'b0;
        
        //ahora paso a estado 3 (ESPERA_PC_ACK).
        #10 reg_i_data_rx = 1'b1; 
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        
        //ahora paso a estado 4 (READ_PROGRAMA), cargo el programa.
        #10 reg_i_data_rx = 4'b1011;
        
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0; //1 instruccion, 4 veces tengo que mandar el rx done (8bits x 4 = 32)
                
        #10 reg_i_data_rx = 4'b1001;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0; //1 instruccion, 4 veces tengo que mandar el rx done (8bits x 4 = 32)
        
        #10 reg_i_data_rx = 4'b1111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0; //1 instruccion, 4 veces tengo que mandar el rx done (8bits x 4 = 32)
        
        
        #10 reg_i_data_rx = 0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0; //1 instruccion, 4 veces tengo que mandar el rx done (8bits x 4 = 32)
        
        
        
        
        
        
        
        
        
        //MANDO HALT PARA SALIR DE READ PROGRAMA
        #10 reg_i_data_rx = 8'b11111111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
    
            
        #10 reg_i_data_rx = 8'b11111111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
    
        #10 reg_i_data_rx = 8'b11111111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        
        
        #10 reg_i_data_rx = 8'b11111111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //ahora paso a estado 5 (ESPERA_START).
        #10 reg_i_data_rx = 8'b00000111;
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_flag_halt = 0;

        // Transmision de datos desde placa a PC
        //Dato 1
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00011000; // PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; // PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;


        
        

        #10 reg_i_data_rx = 8'b10100000; //NO HAGO NADA
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;


        // Dato 2
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00011000; //PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; //PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        // Dato 3
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00011000; //PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; //PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        
        // Activo HALT
        #10 reg_flag_halt = 1;
        

        
        // Contenido R0
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00011000; //PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; //PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        #10 reg_reg_data_from_register_file = 5;

        // Contenido R1
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00011000; //PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; //PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;


        #10 reg_reg_data_from_register_file = 6;

        // Contenido R2
        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00011000; //PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; //PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;







        
        
        
        
        
        
        
        
        
        
        
        
        
        #5 reg_bit_sucio = 1'b1;
        


        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00011000; // PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; // PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00011000; // PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        #50 reg_bit_sucio = 1'b0;

        #10 reg_i_data_rx = 8'b00100000; // PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        
        // Envio fin de memoria.
        #250000 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00011000; // PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; // PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        #10 reg_i_data_rx = 8'b00001000; // PART3
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00010000; // PART2
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        
        #10 reg_i_data_rx = 8'b00011000; // PART1
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;



        #10 reg_i_data_rx = 8'b00100000; // PART0
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;

        #300000 reg_i_data_rx = 8'b00101000; //Salgo de FIN MEM CHECK
        #10 reg_i_rx_done = 1'b1;
        #10 reg_i_rx_done = 1'b0;
        
        

        
        
        // Test 5: Prueba reset.
        #500000 reg_i_reset = 1'b1; // Reset.
        #10 reg_i_reset = 1'b0; // Desactivo el reset.

       #1000000 $finish;
   end
   
   always #2.5 reg_i_clock = ~reg_i_clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
debug_unit
   #(
        .OUTPUT_WORD_LENGTH (OUTPUT_WORD_LENGTH),
        .HALT_INSTRUCTION (HALT_INSTRUCTION),
        .ADDR_MEM_PROG_LENGTH (ADDR_MEM_PROG_LENGTH),
        .ADDR_MEM_DATOS_LENGTH (ADDR_MEM_DATOS_LENGTH),
        .CANTIDAD_ESTADOS (CANTIDAD_ESTADOS),
        .LONGITUD_INSTRUCCION (LONGITUD_INSTRUCCION),
        .CANT_DATOS_DATABASE (CANT_DATOS_DATABASE),
        .CANT_COLUMNAS_MEM_DATOS (CANT_COLUMNAS_MEM_DATOS),
        .CANT_BITS_REGISTRO (CANT_BITS_REGISTRO),
        .RAM_DATOS_DEPTH (RAM_DATOS_DEPTH),
        .CANT_REGISTROS (CANT_REGISTROS)
    ) 
   u_debug_unit_1    // Una sola instancia de este modulo.
   (
       .i_clock (reg_i_clock),
       .i_reset (reg_i_reset),
       .i_tx_done (reg_i_tx_done),
       .i_rx_done (reg_i_rx_done),
       .i_data_rx (reg_i_data_rx),
       .i_soft_reset_ack (reg_i_soft_reset_ack),
       .i_flag_halt (reg_flag_halt),
       .i_dato_database (reg_dato_database),
       .i_dato_mem_datos (reg_dato_mem_datos),
       .i_bit_sucio (reg_bit_sucio),
       .i_reg_data_from_register_file (reg_reg_data_from_register_file),
       .o_reg_read_to_register_file (wire_reg_read_to_register_file),
       .o_tx_start (wire_o_tx_start),
       .o_data_tx (wire_o_data_tx),
       .o_soft_reset (wire_o_soft_reset),
       .o_write_mem_programa (wire_o_write_mem_programa),
       .o_addr_mem_programa (wire_o_addr_mem_programa),
       .o_dato_mem_programa (wire_o_dato_mem_programa),
       .o_modo_ejecucion (wire_modo_ejecucion),
       .o_enable_mem_programa (wire_enable_mem),
       .o_rsta_mem (wire_rsta_mem),
       .o_regcea_mem (wire_regcea_mem),
       .o_enable_PC (wire_enable_pc),
       .o_control_mux_addr_mem_top_if (wire_control_mux_addr_mem_top_if),
       .o_control_database (wire_control_database),
       .o_enable_pipeline (wire_enable_pipeline),
       .o_control_write_read_mem_datos (wire_control_write_read_mem_datos),
       .o_control_address_mem_datos (wire_control_address_mem_datos),
       .o_enable_mem_datos (wire_enable_mem_datos),
       .o_address_debug_unit (wire_address_debug_unit),
       .o_led (wire_led)
   );
  
endmodule


