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
        parameter CANT_REGISTROS = 32
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
       
        // Control de instruction decode.

        input i_RegDst,
        input i_RegWrite,
        input i_ALUSrc,
        input [CANT_BITS_ALU_OP - 1 : 0] i_ALUOp,
        input i_MemRead,
        input i_MemWrite,
        input i_MemtoReg,
        input [CANT_BITS_ALU_CONTROL - 1 : 0] i_ALUCtrl,

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

    // Instruction decode control.
    reg reg_RegDst;
    reg reg_RegWrite;
    reg reg_ALUSrc;
    reg [CANT_BITS_ALU_OP - 1 : 0] reg_ALUOp;
    reg reg_MemRead;
    reg reg_MemWrite;
    reg reg_MemtoReg;
    reg [CANT_BITS_ALU_CONTROL - 1 : 0] reg_ALUCtrl; 

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
        reg_RegWrite <= 0;
        reg_ALUSrc <= 0;
        reg_ALUOp <= 0;
        reg_MemRead <= 0;
        reg_MemWrite <= 0;
        reg_MemtoReg <= 0;
        reg_ALUCtrl <= 0;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
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
            reg_RegWrite <= i_RegWrite;
            reg_ALUSrc <= i_ALUSrc;
            reg_ALUOp <= i_ALUOp;
            reg_MemRead <= i_MemRead;
            reg_MemWrite <= i_MemWrite;
            reg_MemtoReg <= i_MemtoReg;
            reg_ALUCtrl <= i_ALUCtrl;
        end
        else if (i_control == 2) begin // Se devuelve el contador de programa a la salida.
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_pc;
            reg_branch_dir <= reg_branch_dir;
            reg_branch_control <= reg_branch_control;
            reg_data_A <= reg_data_A; 
            reg_data_B <= reg_data_B;
            reg_extension_signo_constante <= reg_extension_signo_constante;
            reg_rs <= reg_rs;
            reg_rt <= reg_rt;
            reg_rd <= reg_rd;
            reg_RegDst <= reg_RegDst;
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
        end
        else if (i_control == 3) begin // Se devuelve el contador de ciclos a la salida.
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_contador_ciclos;
            reg_branch_dir <= reg_branch_dir;
            reg_branch_control <= reg_branch_control;
            reg_data_A <= reg_data_A; 
            reg_data_B <= reg_data_B;
            reg_extension_signo_constante <= reg_extension_signo_constante;
            reg_rs <= reg_rs;
            reg_rt <= reg_rt;
            reg_rd <= reg_rd;
            reg_RegDst <= reg_RegDst;
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
        end
        else if (i_control == 4) begin //Se devuelve la salida del adder del instruction fetch en la salida de este modulo.
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_adder_pc;
            reg_branch_dir <= reg_branch_dir;
            reg_branch_control <= reg_branch_control;
            reg_data_A <= reg_data_A; 
            reg_data_B <= reg_data_B;
            reg_extension_signo_constante <= reg_extension_signo_constante;
            reg_rs <= reg_rs;
            reg_rt <= reg_rt;
            reg_rd <= reg_rd;
            reg_RegDst <= reg_RegDst;
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
        end
        else if (i_control == 5) begin // Se devuelve la instruccion que pasa a la etapa de ID en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
            reg_contador_ciclos <= reg_contador_ciclos;
            o_dato <= reg_instruction_fetch;
            reg_branch_dir <= reg_branch_dir;
            reg_branch_control <= reg_branch_control;
            reg_data_A <= reg_data_A; 
            reg_data_B <= reg_data_B;
            reg_extension_signo_constante <= reg_extension_signo_constante;
            reg_rs <= reg_rs;
            reg_rt <= reg_rt;
            reg_rd <= reg_rd;
            reg_RegDst <= reg_RegDst;
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
        end
        else if (i_control == 6) begin // Se devuelve la direccion y el control del salto en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= {reg_branch_control, reg_branch_dir};
        end
        else if (i_control == 7) begin // Se devuelve el contenido de reg_data_A  en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= reg_data_A;
        end
        else if (i_control == 8) begin // Se devuelve el contenido de reg_data_B  en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= reg_data_B;
        end
        else if (i_control == 9) begin // Se devuelve el contenido de reg_extension_signo_constante en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= reg_extension_signo_constante;
        end
        else if (i_control == 10) begin // Se devuelve el contenido de reg_rs, reg_rt y reg_rd en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= {reg_rs, reg_rt, reg_rd};
        end
        else if (i_control == 11) begin // Se devuelve el contenido de las señales de control en la salida de este modulo. 
            reg_pc <= reg_pc;
            reg_adder_pc <= reg_adder_pc;
            reg_instruction_fetch <= reg_instruction_fetch;
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
            reg_RegWrite <= reg_RegWrite;
            reg_ALUSrc <= reg_ALUSrc;
            reg_ALUOp <= reg_ALUOp;
            reg_MemRead <= reg_MemRead;
            reg_MemWrite <= reg_MemWrite;
            reg_MemtoReg <= reg_MemtoReg;
            reg_ALUCtrl <= reg_ALUCtrl;
            o_dato <= {reg_RegDst, reg_RegWrite, reg_ALUSrc, reg_MemRead, reg_MemWrite, reg_MemtoReg, reg_ALUOp, reg_ALUCtrl};
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
            reg_RegWrite <= 0;
            reg_ALUSrc <= 0;
            reg_ALUOp <= 0;
            reg_MemRead <= 0;
            reg_MemWrite <= 0;
            reg_MemtoReg <= 0;
            reg_ALUCtrl <= 0;
        end
    end

  end

endmodule
