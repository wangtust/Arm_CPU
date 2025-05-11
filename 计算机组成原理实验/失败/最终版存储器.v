`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/10 19:02:58
// Design Name: 
// Module Name: reg1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created

module ALU(
    input [31:0] dataA,
    input [31:0] dataB,
    input [4:0] opcode,
    output reg [31:0] result,
    output con
);
    always @(*) begin
        case(opcode)
            5'b00000: result = dataA + dataB;       // add
            5'b00011: result = dataA - dataB;       // sub
            5'b00001: result = dataA & dataB;       // and
            5'b00010: result = dataA | dataB;       // or
            5'b00100: result = dataA << dataB[4:0]; // sll
            5'b00101: result = dataA >> dataB[4:0]; // srl
            5'b00110: result = $signed(dataA) >>> dataB[4:0]; // sra
            5'b10011: result = dataB << 12;         // lui (学号左移12位)
            default: result = 32'b0;
        endcase
    end
    assign con = (|result);
endmodule

// 数据RAM模块
module DataRAM(
    input [5:0] addr,
    output [31:0] mdata,
    input [31:0] wdata,
    input we,
    input clk
);
    reg [31:0] mem[0:63];
    assign mdata = mem[addr];
    always @(posedge clk)
        if (we)
            mem[addr] <= wdata;
endmodule

// 指令ROM模块
module InsROM(
    input [5:0] addr,
    output [31:0] ins
);
    reg [31:0] ins_rom[63:0];
    initial $readmemh("D:/OneDrive/rom12.txt", ins_rom);  // 预加载汇编指令的机器码
    assign ins = ins_rom[addr];
endmodule

// 程序计数器模块
module PC(
    input clk,
    input rst,
    input [31:0] nextaddr,
    output reg [31:0] curraddr
);
    always @(posedge clk)
        if (rst)
            curraddr <= 32'h00400000;
        else
            curraddr <= nextaddr;
endmodule

// 寄存器文件模块
module RegFile(
    input [4:0] raddr1,
    input [4:0] raddr2,
    output [31:0] rdata1,
    output [31:0] rdata2,
    input [4:0] waddr,
    input [31:0] wdata,
    input we,
    input clk
);
    reg [31:0] regs[1:31];
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];
    always @(posedge clk)
        if (we && (waddr != 5'b0))
            regs[waddr] <= wdata;
endmodule

// SCPU模块
module SCPU(
    input clk,
    input rst,
    output [31:0] result,
    output [6:0] a2g,
    output [7:0] an
);
    wire [31:0] naddr, caddr, ins, rd1, rd2, f, mdata, wd;
    wire [4:0] ra1, ra2, wa;
    wire [6:0] op;  // 修改为7位宽
    reg rwe, mwe, isMem;
    reg sel = 1'b1;
    reg [19:0] imm;  // 修改为20位
    reg [4:0] aluop;

    // 程序计数器
    assign naddr = (caddr < 32'h0040000c)? caddr + 32'h4 : caddr;
    PC mypc(
        .clk(clk),
        .rst(rst),
        .nextaddr(naddr),
        .curraddr(caddr)
    );

    // 指令ROM
    InsROM ir(
        .addr(caddr[7:2]),
        .ins(ins)
    );

    // 寄存器分配
    assign ra1 = ins[19:15];
    assign ra2 = ins[24:20];
    assign wa = ins[11:7];
    assign op = ins[6:0];  // 修改为7位宽

    // 指令解码
    always @(*) begin
        case(op)
            7'b0000011: begin  // lw
                rwe = 1'b1;
                imm = ins[31:20];
                aluop = 5'b00000;
                mwe = 1'b0;
                isMem = 1'b1;
            end
            7'b0100011: begin  // sw
                rwe = 1'b0;
                imm = {ins[31:25], ins[11:7]};
                aluop = 5'b00000;
                mwe = 1'b1;
                isMem = 1'b0;
            end
            7'b0110111: begin  // lui
                rwe = 1'b1;
                imm = ins[31:12];  // 修改为高20位
                aluop = 5'b10011;  // lui指令
                mwe = 1'b0;
                isMem = 1'b0;
            end
            default: begin
                rwe = 1'b0;
                imm = 20'b0;
                aluop = 5'b00000;
                mwe = 1'b0;
                isMem = 1'b0;
            end
        endcase
    end

    assign wd = (isMem) ? mdata : f;

    // 寄存器文件
    RegFile myrf(
        .raddr1(ra1),
        .raddr2(ra2),
        .rdata1(rd1),
        .rdata2(rd2),
        .waddr(wa),
        .wdata(wd),
        .we(rwe),
        .clk(clk)
    );

    assign result = wd;  // 输出到数码管的值
    wire [31:0] dataB = (sel) ? {{12{imm[19]}}, imm} : rd2;  // 修改为高20位

    // ALU
    ALU myalu(
        .dataA(rd1),
        .dataB(dataB),
        .opcode(aluop),
        .result(f),
        .con()
    );

    // 数据RAM
    DataRAM dr(
        .addr(f[7:2]),
        .mdata(mdata),
        .wdata(rd2),
        .we(mwe),
        .clk(clk)
    );

    // 时钟分频
    wire newclk;
    clkdiv clk_divider(
        .clk(clk),
        .newclk(newclk)
    );

    // 数码管显示
    segment seg_display(
        .data(result),
        .clk(newclk),
        .a2g(a2g),
        .an(an)
    );
endmodule

// 时钟分频模块
module clkdiv(
    input clk,
    output newclk
);
    reg [15:0] data = 16'b0;
    always @(posedge clk)
        data <= data + 1'b1;
    assign newclk = data[15];
endmodule

// 数码管显示模块
module segment(
    input [31:0] data,
    input clk,
    output reg [6:0] a2g,
    output reg [7:0] an
);
    reg [2:0] status = 3'b000;
    reg [3:0] digit;
    always @(posedge clk)
        status <= status + 1'b1;
    
    always @(*) begin
        case(status)
            3'b000: begin digit = data[31:28]; an = 8'b01111111; end
            3'b001: begin digit = data[27:24]; an = 8'b10111111; end
            3'b010: begin digit = data[23:20]; an = 8'b11011111; end
            3'b011: begin digit = data[19:16]; an = 8'b11101111; end
            3'b100: begin digit = data[15:12]; an = 8'b11110111; end
            3'b101: begin digit = data[11:8];  an = 8'b11111011; end
            3'b110: begin digit = data[7:4];   an = 8'b11111101; end
            3'b111: begin digit = data[3:0];   an = 8'b11111110; end
            default: begin digit = data[31:28]; an = 8'b11111111; end
        endcase
    end
    
    always @(*) begin
        case(digit)
            4'h0: a2g = ~7'b1111110;
            4'h1: a2g = ~7'b0110000;
            4'h2: a2g = ~7'b1101101;
            4'h3: a2g = ~7'b1111001;
            4'h4: a2g = ~7'b0110011;
            4'h5: a2g = ~7'b1011011;
            4'h6: a2g = ~7'b1011111;
            4'h7: a2g = ~7'b1110000;
            4'h8: a2g = ~7'b1111111;
            4'h9: a2g = ~7'b1111011;
            4'ha: a2g = ~7'b1110111;
            4'hb: a2g = ~7'b0011111;
            4'hc: a2g = ~7'b1001110;
            4'hd: a2g = ~7'b0111101;
            4'he: a2g = ~7'b1001111;
            4'hf: a2g = ~7'b1000111;
            default: a2g = 7'b0000000;
        endcase
    end
endmodule