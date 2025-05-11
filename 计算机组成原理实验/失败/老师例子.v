
module ALU(
    input [31:0] dataA,
    input [31:0] dataB,
    input [4:0] opcode,    // opcode通过开关设置,22种指令
    output reg [31:0] result,  // 数值结果，要转换到LED灯上显示
    output con   // 判断B类指令,beg,blt,bltu
    );
    always @(*)
        case(opcode)
            //opcode=00000,add加法
            5'b00000:result=dataA+dataB;
            //opcode=00001,and按位与
            5'b00001:result=dataA&dataB;
            //00010,or按位或
            5'b00010:result=dataA|dataB;
            //00011,xor按位异或
            5'b00011:result=dataA^dataB;
            //00100,sll逻辑左移
            5'b00100:result=dataA<<dataB[4:0]; //低5位有效
            //00101,srl逻辑右移
            5'b00101:result=dataA>>dataB[4:0];
            //00110,sra算术右移
            5'b00110:result=$signed(dataA)>>>dataB[4:0];  //应当把dataA当作有符号数来处理
            //00111，sub减法
            5'b00111:result=dataA-dataB;
            //01000,lw 基址+偏移地址
            5'b01000:result=dataA+dataB;  // 用加法模拟，实际应该是基址加偏移地址
            //01001,beg相等
            5'b01001:result=(dataA==dataB)? 1:0;
            //01010,blt 小于（有符号）
            5'b01010:result=($signed(dataA)<$signed(dataB))?1:0; 
            //01011,addi 立即数加法
            5'b01011:result=dataA+32'h00000001;   // 立即数取1
            //01100,andi 按位与立即数
            5'b01100:result=dataA & 32'h00000001;
            //ori 按位或立即数
            5'b01101:result=dataA | 32'h00000001;
            //xori 按位异或立即数
            5'b01110:result=dataA ^ 32'h00000001;
            //slli 逻辑左移立即数
            5'b01111:result=dataA << dataB[4:0];  // 立即数也取低五位
            //srli 逻辑右移立即数
            5'b10000:result=dataA >> dataB[4:0];
            //srai 算术右移立即数
            5'b10001:result=$signed(dataA)>>> dataB[4:0];
            //jal 在ALU里无操作
            5'b10010:result=32'b0;
            //lui 加载高立即数   （20位立即数左移12位至高位）
            5'b10011:result=dataA<<12;   // 注意是10进制含义下的12
            //sw  存字，加法模拟，实际上是基址+偏移地址
            5'b10100:result=dataA+dataB;
            //bltu 无符号数小于比较
            5'b10101:result=(dataA<dataB)?1:0;
                    
            default: result=32'b0;            
        endcase
    assign con = (|result);   //result为1，则con输出为1(仅在B类指令上有意义)
    
    
endmodule

module DataRAM(
    input [5:0] addr,
    output [31:0] mdata,
    input [31:0] wdata,
    input we,
    input clk
    );
    reg [31:0] mem[0:63];
   assign mdata=mem[addr];
    always @(posedge clk)
        if(we)
            mem[addr]<=wdata;
endmodule

module InsROM(
    input [5:0] addr,
    output [31:0] ins
    );
    reg [31:0] ins_rom[63:0];
    initial 
    $readmemh("../../../../rom.txt",ins_rom);
    assign ins=ins_rom[addr];
endmodule

module PC(
    input clk,
    input rst,
    input [31:0] nextaddr,
    output reg [31:0] curraddr
    );
always @(posedge clk )
    if(rst)
        curraddr<=32'h00400000;
    else
        curraddr<=nextaddr;
endmodule

module RegFile(
  input [4:0]raddr1,
  input [4:0]raddr2,
  output [31:0]rdata1,
  output [31:0]rdata2,
  input [4:0]waddr,
  input [31:0]wdata,
  input we,
  input clk 
  );
    reg [31:0] regs[1:31];
    assign rdata1=(raddr1==5'b0)? 32'b0:regs[raddr1];
    assign rdata2=(raddr2==5'b0)? 32'b0:regs[raddr2];
    always @(posedge clk)
        if(we&(waddr!=5'b0))
            regs[waddr]<=wdata;
endmodule







module scpu(
    input clk,
    input rst,
    output [31:0] result,
);

wire [31:0] naddr,caddr;
assign naddr=(caddr<32'h00400008)?caddr+32'h4:caddr ;

PC mypc(
    .clk(clk),
    .rst(rst),
    .nextaddr(naddr),
    .curraddr(caddr)
);
wire [31:0] ins;

InsROM ir(
    .addr(caddr[7:2]),
    .ins(ins)
); 

wire [4:0] ra1,ra2,wa;
wire [31:0] rd1,rd2,dataB,f,madata,wd;
wire[1:0]op;
reg rwe,mwe,isMem;
reg sel = 1'b1;
reg [11:0]imm;
reg [4:0]aluop; 

assign ra1=ins[19:15];
assign ra2=ins[24:20];
assign wa=ins[11:7];
assign op=ins[5:4];
always @(*)
    case(op)
       2'b00:   //lw
       begin
         rwe=1'b1;
         imm=ins[31:20];
         aluop=5'b0;
         mwe=1'b0; 
         isMem=1'b1;
       end;  
       2'b01:   //ori
        begin
              rwe=1'b1;
              imm=ins[31:20];
              aluop=5'b0011;
              mwe=1'b0;
              isMem=1'b0;
            end;
            2'b10:   //sw
            begin
              rwe=1'b0;
              imm={ins[31:25],ins[11:7]};
              aluop=5'b0;
              mwe=1'b1;
              isMem=1'b0;
            end;

      
    endcase 
assign wd=(isMem)?madata:f;

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
assign dataB=(sel)?{{20{imm[11]}},imm}:rd2; 

ALU myalu(
    .dataA(rd1),
    .dataB(dataB),
    .opcode(aluop),
    .result(f), 
    .con(con)
);
DataRAM dr(
    .addr(f[7:2]),
    .mdata(mdata),
    .wdata(rd2),
    .we(mwe),
    .clk(clk)
);
module top(
    input clk,
    input rst,
    output [31:0] result
); 
scpu sc(
    .clk(clk),
    .rst(rst),
    .result(result)
);
endmodule


module sim(

);
reg clk=1'b0;
always #10 
     clk=~clk;
reg rst=1'b1;
initial
  #11 rst=1'b0;
  wire[31:0]result; 
top t(
    .clk(clk),
    .rst(rst),
    .result(result)
);
endmodule