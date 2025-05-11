`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/31 20:54:13
// Design Name: 
// Module Name: InsROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// 指令ROM模块
module InsROM(
    input [5:0] addr,
    output [31:0] ins
);
    reg [31:0] ins_rom[63:0];
    initial $readmemh("D:/OneDrive/rom12.txt", ins_rom);  // 预加载汇编指令的机器码
    assign ins = ins_rom[addr];
endmodule
