`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Trabajo Práctico N° 1. ALU.
// ALU.
// Integrantes: Kleiner Matías, López Gastón.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Año 2018.
//////////////////////////////////////////////////////////////////////////////////

// Constantes.
`define CANT_SWITCHES 6
`define CANT_BOTONES 4
`define CANT_LEDS 6

module alu(   
    i_clock,
    i_reset,  
    i_switch, 
    i_enable,
    o_leds
    );

// Parámetros.
parameter CANT_SWITCHES=`CANT_SWITCHES;
parameter CANT_BOTONES=`CANT_BOTONES;
parameter CANT_LEDS=`CANT_LEDS;

// Entradas - Salidas.
input i_clock;                              // Clock.
input [CANT_SWITCHES - 1 : 0] i_switch;     // Switches (para introducir operandos y operadores).
input i_reset;                              // Reset (hard reset).
input [CANT_BOTONES - 1 : 0] i_enable;      // Botones para indicar qué elemento de la operación es lo que se señala con los switches (primer operando, operador o segundo operando).
output [CANT_LEDS - 1 : 0] o_leds;          // Leds para indicar el resultado binario.

// Registros.
reg signed [CANT_SWITCHES - 1 : 0] reg_operando_1;  
reg signed [CANT_SWITCHES - 1 : 0] reg_operando_2; 
reg [CANT_SWITCHES - 1 : 0] reg_operacion;
reg signed [CANT_LEDS - 1 : 0] reg_resultado_operacion;


always@(posedge i_clock) begin
    
    //Se resetean los registros
    if (i_reset) begin
        reg_operando_1 <= 0;
        reg_operando_2 <= 0;
        reg_operacion <= 0;
        reg_resultado_operacion <= 0;
    end
    
    else begin
        //Si se presiona el boton 1 (001), se guarda el valor del switch en reg_operando_1
        if (i_enable  == 3'b001) begin 
            reg_operando_1 <= i_switch;
            reg_operando_2 <= reg_operando_2;
            reg_operacion <= reg_operacion;		
        end
        
        //Si se presiona el boton 2 (010), se guarda el valor del switch en reg_operacion.
        else if (i_enable == 3'b010) begin 
            reg_operacion <= i_switch;
            reg_operando_1 <= reg_operando_1;
            reg_operando_2 <= reg_operando_2;	
        end
        
        //Si se presiona el boton 3 (100), se guarda el valor del switch en reg_operando_2
        else if (i_enable == 3'b100) begin  
            reg_operando_2 <= i_switch;
            reg_operando_1 <= reg_operando_1;
            reg_operacion <= reg_operacion;
        end
        
        // De otra forma, los registros mantienen su valor.
        else begin  
            reg_operacion <= reg_operacion;
            reg_operando_1 <= reg_operando_1;	   
            reg_operando_2 <= reg_operando_2;	      
        end
    
        
        // Case donde se testea el valor de la operación y en base a eso se opera entre operando1 y operando2.
        // Operaciones basadas en MIPS IV Instruction Set.
        case (reg_operacion)
            
            //ADD
            4'b1000 : begin
               reg_resultado_operacion <= reg_operando_1 + reg_operando_2;
            end
             
             //SUB
             4'b1010 : begin
               reg_resultado_operacion <= reg_operando_1 - reg_operando_2;
             end
            
            //AND
             4'b1100 : begin
                reg_resultado_operacion <= reg_operando_1 & reg_operando_2;
             end
             
             //OR
             4'b1101 : begin
                reg_resultado_operacion <= reg_operando_1 | reg_operando_2;
             end
            
            //XOR
             4'b1110 : begin
               reg_resultado_operacion <= reg_operando_1 ^ reg_operando_2;
             end
             
             //SRA (Shift Right Aritmethic).
             4'b0011 : begin
                 reg_resultado_operacion <= reg_operando_1 >>> reg_operando_2;
             end
                         
            //SRL  (Shift Right Logical).
            4'b0010 : begin
               reg_resultado_operacion <= reg_operando_1 >> reg_operando_2;
            end
            
            //NOR
            4'b1111 : begin
               reg_resultado_operacion <= ~ (reg_operando_1 | reg_operando_2);
            end
            
            default : begin
                reg_resultado_operacion <= reg_resultado_operacion;
            end
            
        endcase
    end
end 

// Asignación de salida.
assign {o_leds} = reg_resultado_operacion;

endmodule

