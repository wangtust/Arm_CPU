module top(
    input clk,
    input rst,
    output [6:0] a2g,
    output [7:0] an
);
    // 实例化 SCPU 模块
    SCPU myscpu(
        .clk(clk),
        .rst(rst),
        .a2g(a2g),
        .an(an)
    );
endmodule

// SCPU模块
module SCPU(
    input clk,
    input rst,
    output [6:0] a2g,
    output [7:0] an
);
    wire [31:0] result;
    wire [31:0] naddr, caddr, ins, rd1, rd2, f, mdata, wd;
    wire [4:0] ra1, ra2, wa;
    wire [6:0] op;  // 修改为7位宽
    reg rwe, mwe, isMem;
    reg sel = 1'b1;
    reg [19:0] imm;  // 修改为20位
    reg [3:0] aluop;
    wire [31:0] x2;  // 新增寄存器x2

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
        .clk(clk),
        .x2(x2)  // 新增输出端口
    );

    assign result = x2;  // 输出到数码管的值
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
Endmodule
module ALU(
    input [31:0] dataA,
    input [31:0] dataB,
    input [3:0] opcode,
    output reg [31:0] result,
    output con
);
    always @(*) begin
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
        4'b1011:result=dataB<<12;   // 注意是10进制含义下的12

        //1100,bltu 无符号数小于比较
        4'b1100:result=(dataA<dataB)?1:0;
                
        default: result=32'b0;  
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
    input clk,
    output [31:0] x2  // 新增输出端口
);
    reg [31:0] regs[1:31];
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];
    assign x2 = regs[2];  // 输出regs[2]的值
    always @(posedge clk)
        if (we && (waddr != 5'b0))
            regs[waddr] <= wdata;
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
