`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company		: 
// Engineer		: 特权 franchises3
// Create Date	: 2009.05.07
// Design Name	: 
// Module Name	: sdcard_ctrl
// Project Name	: sdrsvgaprj
// Target Device: Cyclone EP1C3T144C8 
// Tool versions: Quartus II 8.1
// Description	: 
//				
// Revision		: V1.0
// Additional Comments	:  
// 
////////////////////////////////////////////////////////////////////////////////
module sdcard_ctrl(
			clk,rst_n,
			spi_miso,spi_mosi,spi_clk,spi_cs_n,
			sd_dout,sd_fifowr,sdwrad_clr
			);

input clk;		//FPAG输入时钟信号25MHz
input rst_n;	//FPGA输入复位信号

input spi_miso;		//SPI主机输入从机输出数据信号
output spi_mosi;	//SPI主机输出从机输入数据信号
output spi_clk;		//SPI时钟信号，由主机产生
output spi_cs_n;	//SPI从设备使能信号，由主设备控制

output[7:0] sd_dout;	//从SD读出的待放入FIFO数据
output sd_fifowr;		//sd读出数据写入FIFO使能信号，高有效
output sdwrad_clr;		//SDRAM写控制相关信号清零复位信号，高有效

//output[3:0] led;	//调试使用

//----------------------------------------------------------------
wire spi_tx_en;		//SPI数据发送使能信号，高有效
wire spi_tx_rdy;		//SPI数据发送完成标志位，高有效
wire spi_rx_en;		//SPI数据接收使能信号，高有效
wire spi_rx_rdy;		//SPI数据接收完成标志位，高有效
wire[7:0] spi_tx_db;	//SPI数据发送寄存器
wire[7:0] spi_rx_db;	//SPI数据接收寄存器


//----------------------------------------------------------------
//例化SPI传输控制模块
spi_ctrl		uut_spictrl(
					.clk(clk),
					.rst_n(rst_n),
					.spi_miso(spi_miso),
					.spi_mosi(spi_mosi),
					.spi_clk(spi_clk),
					.spi_tx_en(spi_tx_en),
					.spi_tx_rdy(spi_tx_rdy),
					.spi_rx_en(spi_rx_en),
					.spi_rx_rdy(spi_rx_rdy),
					.spi_tx_db(spi_tx_db),
					.spi_rx_db(spi_rx_db)
				);

//例化SD命令控制模块
sd_ctrl			uut_sdctrl(
					.clk(clk),
					.rst_n(rst_n),
					.spi_cs_n(spi_cs_n),
					.spi_tx_en(spi_tx_en),
					.spi_tx_rdy(spi_tx_rdy),
					.spi_rx_en(spi_rx_en),
					.spi_rx_rdy(spi_rx_rdy),
					.spi_tx_db(spi_tx_db),
					.spi_rx_db(spi_rx_db),
					.sd_dout(sd_dout),
					.sd_fifowr(sd_fifowr),
					.sdwrad_clr(sdwrad_clr)
				);

endmodule
