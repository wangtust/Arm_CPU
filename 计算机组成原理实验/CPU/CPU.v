module CPU(
    input clk,
    input rst,
    output [31:0] pcAddr,    //pc指示当前地址
    input [31:0] insData    //从rom中获取的指令
    );
    //声明wire总线，用来连接各个模块
    wire[31:0]nextaddr,curraddr,addr4,rdata1,rdata2,rwdata,a,b,f,mdata,imm12_exp,imm20_exp,addr_branch,addr_jal,addr_jalr,out;
    wire[4:0] rs1,rs2,rd;
    wire[6:0] opcode;
    wire[2:0] func;
    wire[1:0] pcsource;
    wire dis,con,rwe,mwe,isimm,isfpc,isfm,ispc4;
    wire[11:0] imm12;
    wire[19:0] imm20;
    wire[3:0] aluop;
    //实例化PC
    pc mypc(
        .rst(rst),
        .clk(clk),
        .nextaddr(nextaddr),
        .addr(curraddr)
    ); 
    assign pcAddr=curraddr;
    
    //实例化ID
    ID myid(
        .ins(insData),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .funct3(func),
        .funct7(dis),
        .imm12(imm12),
        .imm20(imm20)
    );
    
    //实例化控制单元
    ControlUnit mycu(
        .opcode(opcode),
        .funct3(func),
        .funct7(dis),
        .condition(con),
        .pcSourceCode(pcsource),
        .regWe(rwe),
        .memWe(mwe),
        .aluOpCode(aluop),
        .bIsImm(isimm),
        .bIs20bImm(imm20),
        .regDataIsFromMem(isfm),
        .regDataIsFromPC4(ispc4)
    );
    
    //实例化寄存器堆
    //TODO:选择rwdata，来源于alu运算结果
    assign rwdata=f;
    RegFiles myrf(
        .raddr1(rs1),
        .rdata1(rdata1),
        .raddr2(rs2),
        .rdata2(rdata2),
        .waddr(rd),
        .wdata(rwdata),
        .we(rwe),
        .clk(clk)
    );
    
   
    //实例化ALU
    //获取a的数据 来源于rdata1
    assign a=rdata1;
    //将12位立即数符号扩展位32位
    assign imm12_exp={{20{imm12[11]}},imm12};
    //TODO:根据实际情况修改b的值
    assign b=imm12_exp;
    //实例化ALU
    alu myalu(
        .dataA(a),
        .dataB(b),
        .opcode(aluop),
        .result(f),
        .con(con)
    );
    
    //TODO:只有顺序指令的地址，其他指令自己修改
    assign nextaddr=curraddr+4;

        
endmodule