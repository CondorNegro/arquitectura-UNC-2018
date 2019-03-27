`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Branch address calculator.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module branch_address_calculator
   #(
       
       parameter CANT_BITS_ADDR = 11,
       parameter CANT_BITS_IMMEDIATE = 16,
       parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26,
       parameter CANT_BITS_FLAG_BRANCH = 3,
       parameter CANT_BITS_REGISTROS = 32 
   )
   (
       input [CANT_BITS_FLAG_BRANCH - 1 : 0] i_flag_branch,
       input [CANT_BITS_ADDR - 1 : 0] i_adder_pc,
       input [CANT_BITS_IMMEDIATE - 1 : 0] i_immediate_address,
       input [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] i_instruction_index_branch,
       input [CANT_BITS_REGISTROS - 1 : 0] i_dato_reg_A,
       input [CANT_BITS_REGISTROS - 1 : 0] i_dato_reg_B,
       output reg o_branch_control,
       output reg [CANT_BITS_ADDR - 1 : 0] o_branch_dir
      
   );



    wire [CANT_BITS_ADDR - 1 : 0] wire_resultado_sumador;

    always@(*) begin
      case (i_flag_branch) 
        
        0:
            begin
              o_branch_control = 1'b0;
              o_branch_dir = wire_resultado_sumador;
              
            end

        1://JR
            begin
              o_branch_control = 1'b1;
              o_branch_dir = i_dato_reg_A;
            end

        2://JALR
            begin
              o_branch_control = 1'b1;
              o_branch_dir = i_dato_reg_A;
            end

        3://BEQ
            begin
              if ((i_dato_reg_A - i_dato_reg_B) == 0) begin
                o_branch_control = 1'b1;
              end
              else begin
                o_branch_control = 1'b0;
              end
              o_branch_dir = wire_resultado_sumador;
            end

        4://BNE
            begin
              if ((i_dato_reg_A - i_dato_reg_B) != 0) begin
                o_branch_control = 1'b1;
              end
              else begin
                o_branch_control = 1'b0;
              o_branch_dir = wire_resultado_sumador;
             end
            end
        
        5://J, JAL
            begin
              o_branch_control = 1'b1;
              o_branch_dir = i_instruction_index_branch [CANT_BITS_ADDR - 1 : 0];
              //en MIPS se deberia concatenar con BITS MSB del PC, 
            end

        default:
            begin
              o_branch_control = 1'b0;
              o_branch_dir = wire_resultado_sumador;
            end

      endcase
    end


adder
   #(
       .INPUT_OUTPUT_LENGTH (CANT_BITS_ADDR)
   )
   u_adder_1
   (
       .i_data_A (i_adder_pc),
       .i_data_B (i_immediate_address[CANT_BITS_ADDR - 1 : 0]), //No se realiza un desplazamiento de dos (<<2) porque el PC suma de a uno.
       .o_result (wire_resultado_sumador)
   );




endmodule
