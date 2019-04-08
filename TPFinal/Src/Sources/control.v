`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Control.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2019.
//////////////////////////////////////////////////////////////////////////////////////////////////


module control
   #(
       
       parameter CANT_BITS_INSTRUCTION = 32,
       parameter CANT_BITS_FLAG_BRANCH = 3,
       parameter CANT_BITS_ALU_OP = 2,
       parameter CANT_BITS_ALU_CONTROL = 4,
       parameter CANT_BITS_ESPECIAL = 6,
       parameter CANT_BITS_ID_LSB = 6,
       parameter CANT_BITS_SELECT_BYTES_MEM_DATA = 2
    
    )
   (
       input i_clock,
       input i_soft_reset,
       input [CANT_BITS_INSTRUCTION - 1 : 0] i_instruction,
       input i_enable_etapa,
       output reg o_RegDst,
       output reg o_RegWrite,
       output reg o_ALUSrc,
       output reg [CANT_BITS_ALU_OP - 1 : 0] o_ALUOp,
       output reg [CANT_BITS_ALU_CONTROL - 1 : 0] o_ALUCtrl,
       output reg o_MemRead,
       output reg o_MemWrite,
       output reg o_MemtoReg,
       output reg [CANT_BITS_SELECT_BYTES_MEM_DATA - 1 : 0] o_select_bytes_mem_datos     
   );


   /* Control general */
   always@(*) begin
        if (i_enable_etapa) begin  
                if (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
                begin 
                    case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
                        0://SLL
                            begin 
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        2://SRL
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        3://SRA
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        4://SLLV
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        6://SRLV
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        7://SRAV
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        33://ADDU
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        35://SUBU
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        36://AND
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        37://OR
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        38://XOR
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        39://NOR
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        42://SLT
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        8://JR
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        9://JALR 
                            begin
                                o_RegDst = 1;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        default:
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                    endcase
                end
                else begin // 6 bits MSB distinto de cero.
                    case (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL])//6 bits MSB.
                        32://LB
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 1;
                            end
                        33://LH
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 2;
                            end
                        35://LW
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 3;
                            end
                        39://LWU
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 3;
                            end
                        36://LBU
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 1;
                            end
                        37://LHU
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 1;
                                o_MemWrite = 0;
                                o_MemtoReg = 1;
                                o_select_bytes_mem_datos = 2;
                            end
                        40://SB
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 1;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 1;
                            end
                        41://SH
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 1;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 2;
                            end
                        43://SW
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 1;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 3;
                            end
                        8://ADDI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        12://ANDI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        13://ORI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        14://XORI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        15://LUI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        10://SLTI
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        4://BEQ
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        5://BNE
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 1;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        2://J
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                        3://JAL
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 1;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            
                            end
                        default:
                            begin
                                o_RegDst = 0;
                                o_RegWrite = 0;
                                o_ALUSrc = 0;
                                o_MemRead = 0;
                                o_MemWrite = 0;
                                o_MemtoReg = 0;
                                o_select_bytes_mem_datos = 0;
                            end
                    endcase
                end
        end
        else begin
            o_RegDst = o_RegDst;
            o_RegWrite = o_RegWrite;
            o_ALUSrc = o_ALUSrc;
            o_MemRead = o_MemRead;
            o_MemWrite = o_MemWrite;
            o_MemtoReg = o_MemtoReg;
            o_select_bytes_mem_datos = o_select_bytes_mem_datos;
        end    
   end



    // ALU OP.
   always@(posedge i_clock) begin
        if (~ i_soft_reset) begin
          o_ALUOp <= 2'b00;
        end
        else begin
            if (i_enable_etapa) begin
                    if (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
                    begin 
                        case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
                            0://SLL
                                begin 
                                    o_ALUOp <= 2'b10;
                                end
                            2://SRL
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            3://SRA
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            4://SLLV
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            6://SRLV
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            7://SRAV
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            33://ADDU
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            35://SUBU
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            36://AND
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            37://OR
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            38://XOR
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            39://NOR
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            42://SLT
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            8://JR
                                begin
                                    o_ALUOp <= 2'b01;
                                end
                            9://JALR 
                                begin
                                    o_ALUOp <= 2'b01;
                                end
                            default:
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                        endcase
                    end
                    else begin // 6 bits MSB distinto de cero.
                    case (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL])//6 bits MSB.
                            32://LB
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            33://LH
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            35://LW
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            39://LWU
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            36://LBU
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            37://LHU
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            40://SB
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            41://SH
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            43://SW
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            8://ADDI
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            12://ANDI
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            13://ORI
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            14://XORI
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            15://LUI
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                            10://SLTI
                                begin
                                    o_ALUOp <= 2'b10;
                                end
                            4://BEQ
                                begin
                                    o_ALUOp <= 2'b01;
                                end
                            5://BNE
                                begin
                                    o_ALUOp <= 2'b01;
                                end
                            2://J
                                begin
                                    o_ALUOp <= 2'b01;
                                end
                            3://JAL
                                begin
                                    o_ALUOp <= 2'b01;
                                
                                end
                            default:
                                begin
                                    o_ALUOp <= 2'b00;
                                end
                        endcase
                    end 
            end
            else begin
                o_ALUOp <= o_ALUOp;
            end   
        end
   end





    /* ALU Control. */
    always@(*) begin
        case (o_ALUOp)
            2'b00: //Load o Store.
                begin
                    if (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL] == 15) begin //LUI
                        o_ALUCtrl = 4'b1000;
                    end
                    else begin
                        o_ALUCtrl = 4'b0010;
                    end
                    
                end
            2'b01: //Saltos.
                begin
                    o_ALUCtrl = 4'b1110;
                end
            2'b10: // Tipo R. 
                begin
                    if (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL] == {CANT_BITS_ESPECIAL{1'b0}}) //6 bits MSB en cero.
                    begin 
                        case (i_instruction [CANT_BITS_ID_LSB - 1 : 0]) //6 bits LSB.
                            0://SLL
                                begin 
                                    o_ALUCtrl = 4'b1011;
                                end
                            2://SRL
                                begin
                                    o_ALUCtrl = 4'b1100;
                                end
                            3://SRA
                                begin
                                    o_ALUCtrl = 4'b1101;
                                end
                            4://SLLV
                                begin
                                    o_ALUCtrl = 4'b1011;
                                end
                            6://SRLV
                                begin
                                    o_ALUCtrl = 4'b1100;
                                end
                            7://SRAV
                                begin
                                    o_ALUCtrl = 4'b1101;
                                end
                            33://ADDU
                                begin
                                    o_ALUCtrl = 4'b0010;
                                end
                            35://SUBU
                                begin
                                    o_ALUCtrl = 4'b0110;
                                end
                            36://AND
                                begin
                                    o_ALUCtrl = 4'b0000;
                                end
                            37://OR
                                begin
                                    o_ALUCtrl = 4'b0001;
                                end
                            38://XOR
                                begin
                                    o_ALUCtrl = 4'b1001;
                                end
                            39://NOR
                                begin
                                    o_ALUCtrl = 4'b1010;
                                end
                            42://SLT
                                begin
                                    o_ALUCtrl = 4'b0111;
                                end
                  
                            default:
                                begin
                                    o_ALUCtrl = 4'b0010;
                                end
                        endcase
                    end
                    else begin
                      case (i_instruction [CANT_BITS_INSTRUCTION - 1 : CANT_BITS_INSTRUCTION - CANT_BITS_ESPECIAL])
                           
                            8://ADDI
                                begin
                                    o_ALUCtrl = 4'b0010;
                                end
                            12://ANDI
                                begin
                                    o_ALUCtrl = 4'b0000;
                                end
                            13://ORI
                                begin
                                    o_ALUCtrl = 4'b0001;
                                end
                            14://XORI
                                begin
                                    o_ALUCtrl = 4'b1001;
                                end
                        
                            10://SLTI
                                begin
                                    o_ALUCtrl = 4'b0111;
                                end
                            
                            
                            default:
                                begin
                                    o_ALUCtrl = 4'b0010;
                                end
                      endcase
                    end
                end
            default:
                begin
                    o_ALUCtrl = 4'b0110;
                end
        endcase
        
    end



    




endmodule
