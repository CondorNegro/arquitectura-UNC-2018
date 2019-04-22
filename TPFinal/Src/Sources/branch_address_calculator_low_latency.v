`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Branch address calculator con low latency. (Se pierde un solo ciclo de clock).
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module branch_address_calculator_low_latency
   #(
       
       parameter CANT_BITS_ADDR = 11,
       parameter CANT_BITS_INSTRUCTION_INDEX_BRANCH = 26,
       parameter CANT_BITS_FLAG_BRANCH = 3
   )
   (
       input [CANT_BITS_FLAG_BRANCH - 1 : 0] i_flag_branch,
       input [CANT_BITS_INSTRUCTION_INDEX_BRANCH - 1 : 0] i_instruction_index_branch,
       input i_enable_etapa,
       output reg o_branch_control,
       output reg [CANT_BITS_ADDR - 1 : 0] o_branch_dir,
       output reg o_disable_for_exception_to_hazard_detection_unit
      
   );



    

    always@(*) begin
        if (i_enable_etapa) begin
            case (i_flag_branch) 
                
                0:
                    begin
                    o_branch_control = 1'b0;
                    o_branch_dir = 0;
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    
                    end

                1://JR
                    begin
                    o_branch_control = 1'b1;
                    o_branch_dir = 0;
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    end

                2://JALR
                    begin
                    o_branch_control = 1'b1;
                    o_branch_dir = 0;
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    end

                3://BEQ
                    begin
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    o_branch_control = 1'b0;
                    o_branch_dir = 0;
                    end

                4://BNE
                    begin
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    o_branch_control = 1'b0;
                    o_branch_dir = 0;
                    end
                
                5://J, JAL
                    begin
                    o_branch_control = 1'b1;
                    o_branch_dir = i_instruction_index_branch [CANT_BITS_ADDR - 1 : 0];
                    o_disable_for_exception_to_hazard_detection_unit = 1'b1;
                    //en MIPS se deberia concatenar con BITS MSB del PC, 
                    end

                default:
                    begin
                    o_branch_control = 1'b0;
                    o_branch_dir = 0;
                    o_disable_for_exception_to_hazard_detection_unit = 1'b0;
                    end

            endcase
        end
      
    end







endmodule
