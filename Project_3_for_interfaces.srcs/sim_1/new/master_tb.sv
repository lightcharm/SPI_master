`timescale 1ns / 1ps

module master_tb();

parameter PERIOD = 12;
parameter LEN = 32;
parameter LEN_D_FLASH = 56;
parameter LEN_ADRESS_FLASH = 24;
parameter LEN_DATA_FLASH = 32;

logic clk;
logic reset;

// TB
logic [1:0] CS = `FLASH_MEMORY;     //2'b0;
logic [3:0] address_for_flash = 4'b0;
logic [255:0] data_buffer;

//__________________________________
// FLASH_memory
logic [256-1:0] FLASH [0:16-1];

//данные, которые хотим считать
assign FLASH[0] = 255'b11;
assign data_buffer = FLASH[0];

master dut (
    .CLK(clk),
    .nRST(reset),
    .CS(CS),
    .address_for_flash(address_for_flash)
);

endmodule