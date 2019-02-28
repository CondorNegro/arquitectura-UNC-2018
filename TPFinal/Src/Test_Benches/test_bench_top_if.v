`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Test bench del top if.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////


`define RAM_WIDTH_PROGRAMA     32
`define RAM_PERFORMANCE_PROGRAMA "LOW_LATENCY"
`define INIT_FILE_PROGRAMA     ""
`define RAM_DEPTH_PROGRAMA   2048
`define ADDR_MEM_PROGRAMA_LENGTH 11

module test_bench_top_if();


  // Parametros
   parameter RAM_WIDTH_PROGRAMA        =  `RAM_WIDTH_PROGRAMA;
   parameter RAM_PERFORMANCE_PROGRAMA  = `RAM_PERFORMANCE_PROGRAMA;
   parameter INIT_FILE_PROGRAMA        =  `INIT_FILE_PROGRAMA;
   parameter RAM_DEPTH_PROGRAMA        =  `RAM_DEPTH_PROGRAMA;
   parameter ADDR_MEM_PROGRAMA_LENGTH  =  `ADDR_MEM_PROGRAMA_LENGTH;


  //Todo puerto de salida del modulo es un cable.
  //Todo puerto de estimulo o generacion de entrada es un registro.

  // Entradas.
  reg clock;                                  // Clock.
  reg soft_reset;                             // Reset.
  reg enable_contador_PC;
  reg enable_mem;
  reg write_read_mem;
  reg rsta_mem;
  reg regcea_mem;

  reg [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] addr_mem_programa;
  reg [RAM_WIDTH_PROGRAMA - 1 : 0] data_mem_programa;
  reg control_mux_PC;
  reg control_mux_addr_mem;
  reg control_mux_ouput;
  reg [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] branch_dir;


  wire [RAM_WIDTH_PROGRAMA - 1 : 0] wire_instruction;
  wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_direccion_PC_PLUS_4;
  wire [ADDR_MEM_PROGRAMA_LENGTH - 1 : 0] wire_contador_programa;
  wire wire_led_mem;
  wire wire_reset_ack_mem;

  initial    begin
   clock = 1'b0;
   soft_reset = 1'b0; // Reset en 0. (Normal cerrado el boton del reset).


   enable_contador_PC = 0;
   enable_mem = 0;
   write_read_mem = 0;
   rsta_mem = 0;
   regcea_mem = 0;
   addr_mem_programa = 0;
   data_mem_programa = 0;
   control_mux_PC = 0;
   control_mux_addr_mem = 0;
   control_mux_ouput = 0;
   branch_dir = 0;

   /* Primera prueba, pruebo contador de programa (Resultado esperado: el PC debe contar hasta que el enable sea cero.
   Ademas despues de la instruccion cinco la salida de memoria debe ser halt). */


   #100 soft_reset = 1'b1;
   #200  enable_mem = 1'b1;
   #10 enable_contador_PC = 1'b1;
   #10 enable_contador_PC = 1'b0;

   /// de mem_programa
   #10 control_mux_addr_mem= 1'b1; //mem de programa toma la dir de debug unit para escribir las instruc. (no se toma la dir de pc)
   #20 data_mem_programa = 8'b00000101; // Dato a guardar.
   #20 addr_mem_programa = 11'b0000001; // Seteo de direccion de mem.
   #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
   #20 write_read_mem = 1'b0;
   #20 data_mem_programa = 8'b00000010; // Dato a guardar.
   #20 addr_mem_programa = 11'b0000010; // Seteo de direccion de mem.
   #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
   #20 write_read_mem = 1'b0; // Ahora se guarda el dato.
   #20 addr_mem_programa = 11'b0000011; // Lectura del 1 que se guardo.
   #20 data_mem_programa = 8'b00000101; // Dato a guardar.
   #20 addr_mem_programa = 11'b0000100; // Seteo de direccion de mem.
   #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
   #20 write_read_mem = 1'b0;
   /// de mem programa
    #10 control_mux_addr_mem= 1'b0; //tomo dir de pc y no de debug unit.
    #10 enable_contador_PC = 1'b1;
    #20 enable_contador_PC = 1'b0;





    /* Segunda prueba: pruebo direccion de salto y envio de nop a la salida. (Resultado esperado: el PC debe detenerse en el halt
    leido en la direccion de salto (direccion 10)). La salida envia NOP y al ultimo un HALT. */


    #100 soft_reset = 1'b0;
    #100 soft_reset = 1'b1;
    #10  enable_mem = 1'b1;
    #10 enable_contador_PC = 1'b1;
    #10 enable_contador_PC = 1'b0;

    /// de mem_programa
    #10 control_mux_addr_mem= 1'b1; //mem de programa toma la dir de debug unit para escribir las instruc. (no se toma la dir de pc)
    #20 data_mem_programa = 8'b00000101; // Dato a guardar.
    #20 addr_mem_programa = 11'b0000001; // Seteo de direccion de mem.
    #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
    #20 write_read_mem = 1'b0;
    #20 data_mem_programa = 8'b00000010; // Dato a guardar.
    #20 addr_mem_programa = 11'b0000010; // Seteo de direccion de mem.
    #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
    #20 write_read_mem = 1'b0; // Ahora se guarda el dato.
    #20 addr_mem_programa = 11'b0000011; // Lectura del 1 que se guardo.
    #20 data_mem_programa = 8'b00000101; // Dato a guardar.
    #20 addr_mem_programa = 11'b0000100; // Seteo de direccion de mem.
    #20 write_read_mem = 1'b1; // Ahora se guarda el dato.
    #20 write_read_mem = 1'b0;
    /// de mem programa
     #10 control_mux_addr_mem= 1'b0; //tomo dir de pc y no de debug unit.
     #10 control_mux_ouput = 1'b1;
     #10 branch_dir = 10;
     #10 control_mux_PC = 1'b1;
     #10 enable_contador_PC = 1'b1;
     #20 control_mux_ouput = 1'b0;
     #10 enable_contador_PC = 1'b0;




   // Prueba reset.
   #3000000 soft_reset = 1'b0; // Reset.
   #3000000 soft_reset = 1'b1; // Desactivo el reset.




   #5000000 $finish;
  end

  always #2.5 clock=~clock;  // Simulacion de clock.



//Modulo para pasarle los estimulos del banco de pruebas.
top_if
  #(
      .RAM_WIDTH_PROGRAMA (RAM_WIDTH_PROGRAMA),
      .RAM_PERFORMANCE_PROGRAMA (RAM_PERFORMANCE_PROGRAMA),
      .INIT_FILE_PROGRAMA (INIT_FILE_PROGRAMA),
      .RAM_DEPTH_PROGRAMA (RAM_DEPTH_PROGRAMA),
      .CANT_BITS_ADDR (ADDR_MEM_PROGRAMA_LENGTH)
   )
  u_top_if_1
  (
    .i_clock (clock),
    .i_soft_reset (soft_reset),
    .i_enable_contador_PC (enable_contador_PC),
    .i_enable_mem (enable_mem),
    .i_write_read_mem (write_read_mem),
    .i_rsta_mem (rsta_mem),
    .i_regcea_mem (regcea_mem),
    .i_addr_mem_programa (addr_mem_programa),
    .i_data_mem_programa (data_mem_programa),
    .i_control_mux_PC (control_mux_PC),
    .i_control_mux_addr_mem (control_mux_addr_mem),
    .i_control_mux_ouput (control_mux_ouput),
    .i_branch_dir (branch_dir),
    .o_instruction (wire_instruction),
    .o_direccion_PC_PLUS_4 (wire_direccion_PC_PLUS_4),
    .o_contador_programa (wire_contador_programa),
    .o_led_mem (wire_led_mem),
    .o_reset_ack_mem (wire_reset_ack_mem)
  );

endmodule
