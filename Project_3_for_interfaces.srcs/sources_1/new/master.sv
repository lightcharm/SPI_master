`timescale 1ns / 1ps
`include "defines.v"

/*
Вариант 2
SPI - Serial Peripheral Interface
Mode 0. Тактовая последовательность SCK начинается с формирования положительного
фронта. Считывание данных осуществляется по положительному фронту на линии SCK.
Смена данных по отрицательному фронту.
*/

module master(
    input CLK,
    input nRST,
    input CS,
    input logic [3:0] address_for_flash,
    input [255:0] data_from_flash
    );

//logic [255:0] data_from_flash;

//Считывание данных по положительному фронту
always_ff @(posedge CLK or negedge nRST) begin
    if (!nRST) begin
        data_from_flash = 256'b0;
        //SCK_o <= 1'b0;
        
    end
    else begin
        case (CS)     //set CS
            `FLASH_MEMORY: begin
                if (1) begin
                    data_from_flash = 
                    
                    $display("FLASH_MEMORY");
                end
                else if (1==0) begin
                    
                end
                else begin
                    
                end
            end
            /*`MPU_GYRO: begin
                if () begin
                    
                    
                     $display("MPU_GYRO");
                end
                else if () begin
                    
                end
                else begin
                    
                end
            end
            `REGISTER: begin
                if () begin
                    
                    
                    $display("REGISTER");
                end
                else if () begin
                    
                end
                else begin
                    
                end
            end*/
            default: begin
                $display("IDLE");
            end
        endcase
    end
end

endmodule