`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/19 16:21:34
// Design Name: 
// Module Name: ALU
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

module ALU(
    input [31:0] dataA,
    input [31:0] dataB,
    input [3:0] opcode,    // opcode通过开关设置,22种指令
    output reg [31:0] result,  // 数值结果，要转换到LED灯上显示
    output con   // 判断B类指令,beg,blt,bltu
    );
    always @(*)
        case(opcode)
            //opcode=0000
            //add,加法
            //addi, 立即数就用dataB，在其他设备上进行逻辑选择（使用寄存器还是立即数）
            //sw  存字，加法模拟，实际上是基址+偏移地址
            //lw 基址+偏移地址
            4'b0000:result=dataA+dataB;
            
            //opcode=0001,
            //and按位与
            //andi 按位与立即数
            4'b0001:result=dataA&dataB;
            
            //0010,
            //or按位或
            //ori 按位或立即数
            4'b0010:result=dataA|dataB;
            
            //0011,
            //xor按位异或
            //xori 按位异或立即数
            4'b0011:result=dataA^dataB;
            
            //0100,
            //sll逻辑左移
            //slli, 逻辑左移立即数
            4'b0100:result=dataA<<dataB[4:0]; //低5位有效
            
            //0101
            //srl逻辑右移
            //srli 逻辑右移立即数
            4'b0101:result=dataA>>dataB[4:0];
            
            //0110,
            //sra算术右移
            //srai, 算术右移立即数
            4'b0110:result=$signed(dataA)>>>dataB[4:0];  //应当把dataA当作有符号数来处理
            
            //0111，sub减法
            4'b0111:result=dataA-dataB;
            
            //1000,beg相等
            4'b1000:result=(dataA==dataB)? 1:0;
            
            //1001,blt 小于（有符号）
            4'b1001:result=($signed(dataA)<$signed(dataB))?1:0; 

            //1010,jal 在ALU里无操作
            4'b1010:result=32'b0;
            
            //1011,lui 加载高立即数   （20位立即数左移12位至高位）
            4'b1011:result=dataB<<12;   // 注意是10进制含义下的12,注意是dataB
            

            //1100,bltu 无符号数小于比较
            4'b1100:result=(dataA<dataB)?1:0;
                    
            default: result=32'b0;            
        endcase
    assign con = (|result);   //result为1，则con输出为1(仅在B类指令上有意义)
    
    
endmodule




module segment(
    input [31:0] data,
    input clk,
    output reg [6:0] a2g,
    output reg [7:0] an
    );
    reg[2:0] status=3'b000;
    reg[3:0] digit;
    always @(posedge clk)
            status<=status+1'b1;
    
    always @(*)
    case(status)
        3'b000:begin digit=data[31:28]; an=8'b01111111;end
        3'b001:begin digit=data[27:24]; an=8'b10111111;end
        3'b010:begin digit=data[23:20]; an=8'b11011111;end
        3'b011:begin digit=data[19:16]; an=8'b11101111;end
        3'b100:begin digit=data[15:12]; an=8'b11110111;end
        3'b101:begin digit=data[11:8];  an=8'b11111011;end
        3'b110:begin digit=data[7:4];   an=8'b11111101;end
        3'b111:begin digit=data[3:0];   an=8'b11111110;end
        default:begin digit=data[31:28]; an=8'b11111111;end
    endcase
    always @(*)
    case(digit)
        4'h0:a2g=~7'b1111110;
        4'h1:a2g=~7'b0110000;
        4'h2:a2g=~7'b1101101;
        4'h3:a2g=~7'b1111001;
        4'h4:a2g=~7'b0110011;
        4'h5:a2g=~7'b1011011;
        4'h6:a2g=~7'b1011111;
        4'h7:a2g=~7'b1110000;
        4'h8:a2g=~7'b1111111;
        4'h9:a2g=~7'b1111011;
        4'hA:a2g=~7'b1110111;
        4'hB:a2g=~7'b0011111;
        4'hC:a2g=~7'b1001110;
        4'hD:a2g=~7'b0111101;
        4'hE:a2g=~7'b1001111;
        4'hF:a2g=~7'b1000111;
        default:a2g=~7'b1111110;
    endcase

    initial
        $monitor($time,,"seg:digit=%h,an=%b",digit,an);
   
    initial
        $monitor($time,,"seg:a2g=%b",a2g);
    
    
endmodule


module clkdiv(
    input clk,
    output newclk
    );
    reg[15:0] data=25'b0;
    always@(posedge clk)
        data<=data+1'b1;
    assign newclk=data[15];
endmodule


module top(
    input clk,
    input [3:0] opcode,    // 22种指令
    // 板卡下部一共24个LED灯，其中result使用20个(从右往左数，每4位LED（二进制）是一位十六机制（数码管上的数字）)，con使用最左边那一个(标识0和1)
    output [19:0] result,  
    output con,
    output [7:0] an,
    output [6:0] a2g
    );
    wire newclk;
    clkdiv cd(     // 时钟分频
        .clk(clk),
        .newclk(newclk)
    );
    
    wire [31:0] a = 32'habc12789;    // 数据固定
    wire [31:0] b = 32'h78900005;
    wire [31:0] tmp;
    ALU myalu(      // 实例化
        .dataA(a),
        .dataB(b),
        .opcode(opcode),
        .result(tmp),    // 计算结果连出
        .con(con)
     );
     segment sg(
        .data(tmp),     // 计算结果连入，用于显示
        .clk(newclk),   
        .an(an),
        .a2g(a2g)
      );
     assign result = tmp[19:0];
endmodule