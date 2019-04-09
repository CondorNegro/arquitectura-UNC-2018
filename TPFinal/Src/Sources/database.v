`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Base de datos.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module database
   #(
        parameter ADDR_LENGTH = 11,
        parameter LONGITUD_INSTRUCCION = 32,
        parameter CANT_BITS_CONTROL = 4,
        parameter CANT_BITS_REGISTROS = 32,
        parameter CANT_BITS_ALU_OP = 2,
        parameter CANT_BITS_ALU_CONTROL = 4,
        parameter CANT_REGISTROS = 32,
        parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 3,
        parameter WIDTH_DATA_MEM = 32
   )
   (
        input i_clock,
        input i_soft_reset,
        input [CANT_BITS_CONTROL - 1 : 0] i_control,

        input [ADDR_LENGTH - 1 : 0] i_contador_ciclos, 

        // Intruction Fetch.
        input [ADDR_LENGTH - 1 : 0] i_pc,
        input [ADDR_LENGTH - 1 : 0] i_adder_pc,
        input [LONGITUD_INSTRUCCION - 1 : 0] i_instruction_fetch,


        // Instruction Decode.

        input [ADDR_LENGTH - 1 : 0] i_branch_dir,
        input i_branch_control,

        input [CANT_BITS_REGISTROS - 1 : 0] i_data_A,
        input [CANT_BITS_REGISTROS - 1 : 0] i_data_B,

        input [CANT_BITS_REGISTROS - 1 : 0] i_extension_signo_constante,
        input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rs,
        input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rt,
        input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_reg_rd,
        input i_halt_detected_ID_to_EX,
       
        // Control de instruction decode.

        input i_RegDst,
        input i_RegWrite_ID_to_EX,
        input i_ALUSrc,
        input [CANT_BITS_ALU_OP - 1 : 0] i_ALUOp,
        input i_MemRead_ID_to_EX,
        input i_MemWrite_ID_to_EX,
        input i_MemtoReg_ID_to_EX,
        input [CANT_BITS_ALU_CONTROL - 1 : 0] i_ALUCtrl,
        input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_bytes_mem_data_ID_to_EX,


        // Ejecucion

        input i_RegWrite_EX_to_MEM,
        input i_MemRead_EX_to_MEM,
        input i_MemWrite_EX_to_MEM, 
        input i_MemtoReg_EX_to_MEM,
        input [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] i_select_bytes_mem_datos_EX_to_MEM,
        input i_halt_detected_EX_to_MEM, 
        input [clogb2 (CANT_REGISTROS - 1) - 1 : 0] i_registro_destino_EX_to_MEM,
        input [CANT_BITS_REGISTROS - 1 : 0] i_result_alu,
        input [WIDTH_DATA_MEM - 1 : 0] i_data_write_to_mem,

        output reg [LONGITUD_INSTRUCCION - 1 : 0] o_dato

   );

    reg [ADDR_LENGTH - 1 : 0] reg_contador_ciclos;

    // Instruction fetch.
    reg [ADDR_LENGTH - 1 : 0] reg_pc;
    reg [ADDR_LENGTH - 1 : 0] reg_adder_pc;
    reg [LONGITUD_INSTRUCCION - 1 : 0] reg_instruction_fetch;

    //Instruction decode.
    reg [ADDR_LENGTH - 1 : 0] reg_branch_dir;
    reg reg_branch_control;

    reg [CANT_BITS_REGISTROS - 1 : 0] reg_data_A;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_data_B;

    reg [CANT_BITS_REGISTROS - 1 : 0] reg_extension_signo_constante;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rs;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rt;
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_rd;
    reg reg_halt_detected_ID_to_EX;

    // Instruction decode control.
    reg reg_RegDst;
    reg reg_RegWrite_ID_to_EX;
    reg reg_ALUSrc;
    reg [CANT_BITS_ALU_OP - 1 : 0] reg_ALUOp;
    reg reg_MemRead_ID_to_EX;
    reg reg_MemWrite_ID_to_EX;
    reg reg_MemtoReg_ID_to_EX;
    reg [CANT_BITS_ALU_CONTROL - 1 : 0] reg_ALUCtrl;
    reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] reg_select_bytes_mem_data_ID_to_EX; 

    // Ejecucion

    reg reg_RegWrite_EX_to_MEM;
    reg reg_MemRead_EX_to_MEM;
    reg reg_MemWrite_EX_to_MEM; 
    reg reg_MemtoReg_EX_to_MEM;
    reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] reg_select_bytes_mem_datos_EX_to_MEM;
    reg reg_halt_detected_EX_to_MEM; 
    reg [clogb2 (CANT_REGISTROS - 1) - 1 : 0] reg_registro_destino_EX_to_MEM;
    reg [CANT_BITS_REGISTROS - 1 : 0] reg_result_alu;
    reg [WIDTH_DATA_MEM - 1 : 0] reg_data_write_to_mem;

   //  The following function calculates the address width based on specified RAM depth
    function integer clogb2;
        input integer depth;
            for (clogb2=0; depth>0; clogb2=clogb2+1)
                depth = depth >> 1;
    endfunction
  
  always @(posedge i_clock) begin
    if (~ i_soft_reset) begin
        reg_pc <= 0;
        reg_adder_pc <= 4;
        reg_instruction_fetch <= 0;
        reg_contador_ciclos <= 0;
        o_dato <= 0;
        reg_branch_dir <= 0;
        reg_branch_control <= 0;
        reg_data_A <= 0; 
        reg_data_B <= 0;
        reg_extension_signo_constante <= 0;
        reg_rs <= 0;
        reg_rt <= 0;
        reg_rd <= 0;
        reg_RegDst <= 0;
        reg_RegWrite_ID_to_EX <= 0;
        reg_ALUSrc <= 0;
        reg_ALUOp <= 0;
        reg_MemRead_ID_to_EX <= 0;
        reg_MemWrite_ID_to_EX <= 0;
        reg_MemtoReg_ID_to_EX <= 0;
        reg_ALUCtrl <= 0;
        reg_select_bytes_mem_data_ID_to_EX <= 0;
        reg_halt_detected_ID_to_EX <= 0;
        reg_RegWrite_EX_to_MEM <= 0;
        reg_MemRead_EX_to_MEM <= 0;
        reg_MemWrite_EX_to_MEM <= 0; 
        reg_MemtoReg_EX_to_MEM <= 0;
        reg_select_bytes_mem_datos_EX_to_MEM <= 0;
        reg_halt_detected_EX_to_MEM <= 0; 
        reg_registro_destino_EX_to_MEM <= 0;
        reg_result_alu <= 0;
        reg_data_write_to_mem <= 0;
    end
    else begin
        if (i_control == 0) begin // No se hace nada, se mantienen los valores.
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
            o_dato <= o_dato;
            reg_contador_ciclos <= reg_contador_ciclos;
            reg_branch_dir <= reg_branch_dir;
            reg_branch_control <= reg_branch_control;
            reg_data_A <= reg_data_A; 
            reg_data_B <= reg_data_B;
            reg_extension_signo_constante <= reg_extension_signo_constante;
            reg_rs <= reg_rs;
            reg_rt <= reg_rt;
            reg_rd <= reg_rd;
            reg_RegDst <= reg_RegDst;
            reg_RegWrite_ID_to_EX <= reg_RegWrite_ID_to_EX;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead_ID_to_EX <= reg_MemRead_ID_to_EX;
            reg_MemWrite_ID_to_EX <= reg_MemWrite_ID_to_EX;
            reg_MemtoReg_ID_to_EX <= reg_MemtoReg_ID_to_EX;
            reg_ALUCtrl <= reg_ALUCtrl;
            reg_select_bytes_mem_data_ID_to_EX <= reg_select_bytes_mem_data_ID_to_EX;
            reg_halt_detected_ID_to_EX <= reg_halt_detected_ID_to_EX;
            reg_RegWrite_EX_to_MEM <= reg_RegWrite_EX_to_MEM;
            reg_MemRead_EX_to_MEM <= reg_MemRead_EX_to_MEM;
            reg_MemWrite_EX_to_MEM <= reg_MemWrite_EX_to_MEM; 
            reg_MemtoReg_EX_to_MEM <= reg_MemtoReg_EX_to_MEM;
            reg_select_bytes_mem_datos_EX_to_MEM <= reg_select_bytes_mem_datos_EX_to_MEM;
            reg_halt_detected_EX_to_MEM <= reg_halt_detected_EX_to_MEM; 
            reg_registro_destino_EX_to_MEM <= reg_registro_destino_EX_to_MEM;
            reg_result_alu <= reg_result_alu;
            reg_data_write_to_mem <= reg_data_write_to_mem;
        end 
        if (i_control == 1) begin // Se guardan los valores de las entradas en los registros.
            reg_pc <= i_pc;
            reg_adder_pc <= i_adder_pc;
            reg_instruction_fetch <= i_instruction_fetch;
            reg_contador_ciclos <= i_contador_ciclos;
            o_dato <= 0;
            reg_branch_dir <= i_branch_dir;
            reg_branch_control <= i_branch_control;
            reg_data_A <= i_data_A; 
            reg_data_B <= i_data_B;
            reg_extension_signo_constante <= i_extension_signo_constante;
            reg_rs <= i_reg_rs;
            reg_rt <= i_reg_rt;
            reg_rd <= i_reg_rd;
            reg_RegDst <= i_RegDst;
            reg_RegWrite_ID_to_EX <= i_RegWrite_ID_to_EX;
            reg_ALUSrc <= i_ALUSrc;
            reg_ALUOp <= i_ALUOp;
            reg_MemRead_ID_to_EX <= i_MemRead_ID_to_EX;
            reg_MemWrite_ID_to_EX <= i_MemWrite_ID_to_EX;
            reg_MemtoReg_ID_to_EX <= i_MemtoReg_ID_to_EX;
            reg_ALUCtrl <= i_ALUCtrl;
            reg_select_bytes_mem_data_ID_to_EX <= i_select_bytes_mem_data_ID_to_EX;
            reg_halt_detected_ID_to_EX <= i_halt_detected_ID_to_EX;
            reg_RegWrite_EX_to_MEM <= i_RegWrite_EX_to_MEM;
            reg_MemRead_EX_to_MEM <= i_MemRead_EX_to_MEM;
            reg_MemWrite_EX_to_MEM <= i_MemWrite_EX_to_MEM; 
            reg_MemtoReg_EX_to_MEM <= i_MemtoReg_EX_to_MEM;
            reg_select_bytes_mem_datos_EX_to_MEM <= i_select_bytes_mem_datos_EX_to_MEM;
            reg_halt_detected_EX_to_MEM <= i_halt_detected_EX_to_MEM; 
            reg_registro_destino_EX_to_MEM <= i_registro_destino_EX_to_MEM;
            reg_result_alu <= i_result_alu;
            reg_data_write_to_mem <= i_data_write_to_mem;            
        end
        else if (i_control == 2) begin // Se devuelve el contador de programa y el contador de ciclos a la salida.
            o_dato <= {reg_pc, {((CANT_BITS_REGISTROS/2) - ADDR_LENGTH){1'b0}}, reg_contador_ciclos};
        end
        else if (i_control == 3) begin // Se devuelve la salida del adder del instruction fetch en la salida de este modulo. Tambien la direccion y el control del salto.
            o_dato <= {reg_adder_pc, {((CANT_BITS_REGISTROS/2) - ADDR_LENGTH - 1){1'b0}} , reg_branch_control, reg_branch_dir};
        end
        
        else if (i_control == 4) begin // Se devuelve la instruccion que pasa a la etapa de ID en la salida de este modulo. 
            o_dato <= reg_instruction_fetch;
        end
        
        else if (i_control == 5) begin // Se devuelve el contenido de reg_data_A  en la salida de este modulo. 
            o_dato <= reg_data_A;
        end
        else if (i_control == 6) begin // Se devuelve el contenido de reg_data_B  en la salida de este modulo. 
            o_dato <= reg_data_B;
        end
        else if (i_control == 7) begin // Se devuelve el contenido de reg_extension_signo_constante en la salida de este modulo. 
            o_dato <= reg_extension_signo_constante;
        end
        else if (i_control == 8) begin // Se devuelve el contenido de reg_rs, reg_rt y reg_rd en la salida de este modulo, ademas de las señales de control de la etapa ID. 
            o_dato <= {reg_select_bytes_mem_data_ID_to_EX, reg_halt_detected_ID_to_EX, reg_RegDst, reg_RegWrite_ID_to_EX, reg_ALUSrc, reg_MemRead_ID_to_EX, reg_MemWrite_ID_to_EX, reg_MemtoReg_ID_to_EX, reg_ALUOp, reg_ALUCtrl, {((CANT_BITS_REGISTROS/2) - clogb2 (CANT_REGISTROS - 1) * 3){1'b0}}, reg_rs, reg_rt, reg_rd};
        end
        // Ejecucion
        else if (i_control == 9) begin // Se devuelve el resultado de la ALU.
            o_dato <= reg_result_alu; 
        end
        else if (i_control == 10) begin // Se devuelve lo que se va a escribir en memoria.
            o_dato <= reg_data_write_to_mem;
        end
        else if (i_control == 11) begin // Se devuelven señales de control y el registro destino de la etapa EX.
            o_dato <= {reg_RegWrite_EX_to_MEM, reg_MemRead_EX_to_MEM, reg_MemWrite_EX_to_MEM, reg_MemtoReg_EX_to_MEM, reg_select_bytes_mem_datos_EX_to_MEM, reg_halt_detected_EX_to_MEM, reg_registro_destino_EX_to_MEM};
        end
        else begin
            reg_pc <= 0;
            reg_adder_pc <= 4;
            reg_instruction_fetch <= 0;
            reg_contador_ciclos <= 0;
            o_dato <= 0;
            reg_branch_dir <= 0;
            reg_branch_control <= 0;
            reg_data_A <= 0; 
            reg_data_B <= 0;
            reg_extension_signo_constante <= 0;
            reg_rs <= 0;
            reg_rt <= 0;
            reg_rd <= 0;
            reg_RegDst <= 0;
            reg_RegWrite_ID_to_EX <= 0;
            reg_ALUSrc <= 0;
            reg_ALUOp <= 0;
            reg_MemRead_ID_to_EX <= 0;
            reg_MemWrite_ID_to_EX <= 0;
            reg_MemtoReg_ID_to_EX <= 0;
            reg_ALUCtrl <= 0;
            reg_select_bytes_mem_data_ID_to_EX <= 0;
            reg_halt_detected_ID_to_EX <= 0;
            reg_RegWrite_EX_to_MEM <= 0;
            reg_MemRead_EX_to_MEM <= 0;
            reg_MemWrite_EX_to_MEM <= 0; 
            reg_MemtoReg_EX_to_MEM <= 0;
            reg_select_bytes_mem_datos_EX_to_MEM <= 0;
            reg_halt_detected_EX_to_MEM <= 0; 
            reg_registro_destino_EX_to_MEM <= 0;
            reg_result_alu <= 0;
            reg_data_write_to_mem <= 0;
        end
    end

  end

endmodule
