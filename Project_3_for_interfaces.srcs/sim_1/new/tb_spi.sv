`timescale 1ns / 1ps

parameter bits = 32;

module tb_spi();

logic sys_clk;
logic t_start;
logic [bits-1:0] d_in;
logic [bits-1:0] d_out;
logic [$clog2(bits):0] t_size;
logic cs;
logic rstn;
logic spi_clk;
logic miso;
logic mosi;

master_spi dut
(
	.sys_clk(sys_clk),
	.t_start(t_start),
	.d_in(d_in),
	.d_out(d_out),
	.t_size(t_size),
	.cs(cs),
	.rstn(rstn),
	.spi_clk(spi_clk),
	.miso(miso),
	.mosi(mosi)
);

assign miso = mosi;

always
	#2 sys_clk = !sys_clk;

initial begin
	sys_clk = 0;
	t_start = 0;
	d_in = 0;
    rstn = 0;
	t_size = bits;
	#4;
	rstn = 1;
end

integer i;
task transact_test;
    input [bits-1:0] data;
    begin
	   d_in = data[bits-1:0];
		#3 t_start = 1;
		#4 t_start = 0;
		for( i=0; i < bits; i++) begin
			#4;
		end
		#16;
	end
endtask	

//---------------------------------------
//MPU6000
//адрес в акселлерометр 116 (This register is used to read and write data from the FIFO buffer)
//считываем данные оттуда, которые задам в тб
logic [7:0] REGS [0:117];
initial begin
    int data_reg;
    parameter DATA_BITS_NUM = $bits(data_reg);
    for (int reg_num = 0; reg_num < 118; reg_num++) begin
        data_reg = $urandom();  //returns 32 bit random
        REGS[reg_num] = data_reg[7:0];
    end
end

logic [7:0] address_for_MPU_from_TB;
logic [7:0] address_for_MPU_from_fpga;
logic [7:0] result_MPU;
//---------------------------------------

//---------------------------------------
//74HC595
//(A..F) - индикаторы: 1 - горит, 0 - нет;
//CS(notOE) - зависит от объема данных (чтобы хватило сегментов)
//DS - данные - преобразуютс€ в cases в соответствующие числа
//не преобразовывал к дес€тичному формату (просто показ о выводе), т.е. 1=1, 0=0
//если у нас число 99 = 1001_1001, то он будет отображатьс€ на одном индикаторе как свечение каждого сегмента ѕќ ѕќ–яƒ ” (0..6 + точка)
//и уже пользователь переводит в уме в то, что он видит

logic notOE = 1'b1;
logic [2:0] addr = 3'b000;
logic [7:0] segments [0:7];

task out_segm_task;
    input [63:0] data;
    begin
        if (notOE) begin
        /*
            case (addr)
                3'b000: begin
                    //segments[0] <= (data[7:0] === 8'hxx) ? 8'b0 : data[7:0];
                    segments[0] <= data[7:0];
                    addr <= 3'b001;
                end
                3'b001: begin
                    //segments[1] <= (data[15:8] === 8'hxx) ? 8'b0 : data[15:8];
                    segments[1] <= data[15:8];
                    addr <= 3'b010;
                end
                3'b010: begin
                    //segments[2] <= (data[23:16] === 8'hxx) ? 8'b0 : data[23:16];
                    segments[2] <= data[23:16];
                    addr = 3'b011;
                end
                3'b011: begin
                    segments[3] <= data[31:24];
                    addr = 3'b100;
                end
                3'b100: begin
                    segments[4] <= data[39:32];
                    addr = 3'b101;
                end
                3'b101: begin
                    segments[5] <= data[47:40];
                    addr = 3'b110;
                end
                3'b110: begin
                    segments[6] <= data[55:48];
                    addr = 3'b111;
                end
                3'b111: begin
                    segments[7] <= data[63:56];
                    addr = 3'b000;
                end
                default: begin
                    segments[0] <= 8'b0;
                    segments[1] <= 8'b0;
                    segments[2] <= 8'b0;
                    segments[3] <= 8'b0;
                    segments[4] <= 8'b0;
                    segments[5] <= 8'b0;
                    segments[6] <= 8'b0;
                    segments[7] <= 8'b0;
                end
            endcase
            */
            segments[0] <= (data[7:0] === 8'hxx) ? 8'b0 : data[7:0];
            segments[1] <= (data[15:8] === 8'hxx) ? 8'b0 : data[15:8];
            segments[2] <= (data[23:16] === 8'hxx) ? 8'b0 : data[23:16];
            segments[3] <= (data[31:24] === 8'hxx) ? 8'b0 : data[31:24];
            segments[4] <= (data[39:32] === 8'hxx) ? 8'b0 : data[39:32];
            segments[5] <= (data[47:40] === 8'hxx) ? 8'b0 : data[47:40];
            segments[6] <= (data[55:48] === 8'hxx) ? 8'b0 : data[55:48];
            segments[7] <= (data[63:56] === 8'hxx) ? 8'b0 : data[63:56];
        end
    end
endtask
//---------------------------------------

//---------------------------------------
//W25Q16
//считывание данных
//адрес в акселлерометр 116 (This register is used to read and write data from the FIFO buffer)
//считываем данные оттуда, которые задам в тб
logic [31:0] FLASH [0:7];
initial begin
    int data_flash;
    parameter DATA_BITS_NUM = $bits(data_flash);
    for (int flash_page = 0; flash_page < 8; flash_page++) begin
      for (int flash_32_bit = 0; flash_32_bit < 32; flash_32_bit += DATA_BITS_NUM) begin
        data_flash = $urandom();  //returns 32 bit random
        FLASH[flash_page][flash_32_bit+:DATA_BITS_NUM] = data_flash;
      end
    end
end

logic [23:0] address_for_W25_from_TB;
logic [23:0] address_for_W25_from_fpga;
logic [31:0] result_W25;


logic [31:0] data_for_W25_from_TB;
logic [31:0] data_for_W25_from_fpga;
logic [31:0] result_W25_WR;
//---------------------------------------
initial begin
	#10;
	
	//MPU reading
	address_for_MPU_from_TB = 8'b0111_0100;
	transact_test( {2'b00, address_for_MPU_from_TB} );
	address_for_MPU_from_fpga = d_out[7:0];    //address from master
	result_MPU = REGS[address_for_MPU_from_fpga];  //data from register 116
	#100;
	//---------------------
	
	//out on segm_indicators
	out_segm_task( {2'b00, result_MPU} );
	#100;
	//---------------------
	
	//W25Q16 reading
	address_for_W25_from_TB = 24'b0000_0000_0000_0010;
	transact_test( {2'b01, address_for_W25_from_TB} );
	address_for_W25_from_fpga = d_out[23:0];    //address from master
	result_W25 = FLASH[address_for_W25_from_fpga];  //data from flash memory
	#100;
	//---------------------
	
	//out on segm_indicators
	out_segm_task( {2'b01, result_W25} );
	#100;
	//---------------------
	
	//W25Q16 writing
	address_for_W25_from_TB = 24'b0000_0000_0000_0101;
	transact_test( {2'b10, address_for_W25_from_TB} );
	address_for_W25_from_fpga = d_out[23:0];    //address from master
	//#10;
	data_for_W25_from_TB = 32'b1001_0000_0000_0000_0000_0000_0000_0110;
	transact_test( {2'b11, data_for_W25_from_TB} );
	data_for_W25_from_fpga = d_out[31:0];    //data from master
	FLASH[address_for_W25_from_fpga] = data_for_W25_from_fpga;  //data for flash memoty new
	result_W25_WR = FLASH[address_for_W25_from_fpga];  //data from flash memoty new
	#100;
	//---------------------
	
	//out on segm_indicators
	out_segm_task( {2'b10, result_W25_WR} );
	#100;
	//---------------------
	
	$finish;
end

endmodule