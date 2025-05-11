module top(
    input clk,
    input rst
    );
    
    wire[31:0] addr,insdata;
    CPU mycpu(
        .clk(clk),
        .rst(rst),
        .pcAddr(addr),
        .insData(insdata)
    );
    
    //实例化ROM
    rom insrom(
        .addr(addr[9:2]),
        .data(insdata)
     );
     
     //TODO:
endmodule



module CPU(
    input clk,
    input rst,
    output [31:0] pcAddr,    //pc指示当前地址
    input [31:0] insData    //从rom中获取的指令
    );
    //声明wire总线，用来连接各个模块
    wire [31:0] curraddr, addr4, rdata1, rdata2, a, b, f, mdata, imm12_exp, imm20_exp;
    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode;
    wire [2:0] func;
    wire [1:0] pcsource;
    wire dis, con, rwe, mwe, isimm, isfpc, isfm, ispc4, isimm20;
    wire [11:0] imm12;
    wire [19:0] imm20;
    wire [3:0] aluop;
    reg [31:0] rwdata; // 声明为reg可以在always块中赋值
    reg [31:0] nextaddr; // 声明为reg类型

    //实例化PC
    pc mypc(
        .rst(rst),
        .clk(clk),
        .nextaddr(nextaddr),
        .addr(curraddr)
    ); 
    assign pcAddr=curraddr;
    assign addr4 = curraddr + 4;
    //实例化ID
      // 实例化ID
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
          .bIs20bImm(isimm20),
          .regDataIsFromMem(isfm),
          .regDataIsFromPC4(ispc4)
      );
  
      // 实例化寄存器堆
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
  
      // 实例化ALU
      assign a = rdata1;
      assign imm12_exp = {{20{imm12[11]}}, imm12};
      assign imm20_exp = {{12{imm20[19]}}, imm20};
      assign b = isimm ? (isimm20 ? imm20_exp : imm12_exp) : rdata2;
  
      alu myalu(
          .dataA(a),
      .dataB(b),
      .opcode(aluop),
      .result(f),
      .con(con)
      );
  
          // 实例化DataRAM
      DataRAM myram(
          .addr(f[7:2]),
          .mdata(mdata),
          .wdata(rdata2),
          .we(mwe),
          .clk(clk)
      );
  
      // rwdata 选择逻辑
      always @(*) begin
          if (isfm) begin
              rwdata = mdata;
          end else if (ispc4) begin
              rwdata = addr4;
          end else begin
              rwdata = f;
          end
      end
  
      // 计算下条指令地址
      always @(*) begin
          if (pcsource[1]) begin
              if (pcsource[0]) begin
                  nextaddr = {f[31:1], 1'b0};
              end else begin
                  nextaddr = f + curraddr;
              end
          end else begin
              if (pcsource[0]) begin
                  nextaddr = (imm12_exp << 1) + curraddr;
              end else begin
                  nextaddr = addr4;
              end
          end
      end
  endmodule

  //PASS
module pc(
    input clk,
    input rst,
    input[31:0] nextaddr,
    output reg [31:0] addr
    );
      always @(posedge clk)
         if (rst==1'b1)
             addr <= 32'h00400000;
         else
             addr <= nextaddr;
    
endmodule

module ID(
    input [31:0] ins,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [6:0] opcode,
    output [11:0] imm12,
    output [2:0] funct3,
    output [19:0] imm20,
    output funct7   //指令第三十位，区分码
);
    assign opcode = ins[6:0];
    assign rd = ins[11:7];
    assign funct3 = ins[14:12];
    assign rs1 = ins[19:15];
    assign rs2 = ins[24:20];
    assign funct7 = ins[30];
    
    wire I_type, S_type, B_type, J_type, U_type;
    //00x0011 I类
    assign I_type = ~ins[6] & ~ins[5] & ~ins[3] & ~ins[2] & ins[1] & ins[0];
    //1100011 B类
    assign B_type = (&ins[6:5]) & ~(|ins[4:2]) & (&ins[1:0]);
    //0100011 S类
    assign S_type = ~ins[6] & ins[5] & ~(|ins[4:2]) & (&ins[1:0]);
    //0x10111 U类
    assign U_type = ~ins[6] & ins[4] & ~ins[3] & (&ins[2:0]);
    //1101111 J类
    assign J_type = (&ins[6:5]) & ~ins[4] & (&ins[3:0]);

    assign imm12 = {12{I_type}} & ins[31:20] |
                   {12{B_type}} & {ins[31], ins[7], ins[30:25], ins[11:8]} |
                   {12{S_type}} & {ins[31:25], ins[11:7]};
    assign imm20 = {20{U_type}} & ins[31:12] | {20{J_type}} & {ins[31], ins[19:12], ins[20], ins[30:21]};         
endmodule

module ControlUnit(
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7,
    input condition,            //是否满足B类指令的跳转条件 =1  满足
    output reg [1:0] pcSourceCode,  //下一条指令地址来源方式   =00 顺序执行   =01 有条件跳转   =10  jal    =11  jalr
    output reg regWe,         //寄存器写使能端   =1
    output reg memWe,         //RAM写使能端      =1
    output reg [3:0] aluOpCode, //ALU运算类型
    output reg bIsImm,      //b是否是立即数
    output reg bIs20bImm,       //b是否是20位的立即数
    output reg regDataIsFromMem,       //rwdata是否来源于mem
    output reg regDataIsFromPC4       //rwdata是否来源于pc+4
);

always @(*) begin
    // 默认值
    pcSourceCode = 2'b00;
    regWe = 1'b0;
    memWe = 1'b0;
    aluOpCode = 4'b0000;
    bIsImm = 1'b0;
    bIs20bImm = 1'b0;
    regDataIsFromMem = 1'b0;
    regDataIsFromPC4 = 1'b0;

    case (opcode)
        7'b0110011: begin // R-type instructions
            regWe = 1'b1;
            case (funct3)
                3'b000: aluOpCode = funct7 ? 4'b0111 : 4'b0000; // sub or add
                3'b111: aluOpCode = 4'b0001; // and
                3'b110: aluOpCode = 4'b0010; // or
                3'b100: aluOpCode = 4'b0011; // xor
                3'b001: aluOpCode = 4'b0100; // sll
                3'b101: aluOpCode = funct7 ? 4'b0110 : 4'b0101; // sra or srl
            endcase
        end
        7'b0010011: begin // I-type instructions
            regWe = 1'b1;
            bIsImm = 1'b1;
            case (funct3)
                3'b000: aluOpCode = 4'b0000; // addi
                3'b111: aluOpCode = 4'b0001; // andi
                3'b110: aluOpCode = 4'b0010; // ori
                3'b100: aluOpCode = 4'b0011; // xori
                3'b001: aluOpCode = 4'b0100; // slli
                3'b101: aluOpCode = funct7 ? 4'b0110 : 4'b0101; // srai or srli
            endcase
        end
        7'b0000011: begin // lw
            regWe = 1'b1;
            bIsImm = 1'b1;
            aluOpCode = 4'b0000;
            regDataIsFromMem = 1'b1;
        end
        7'b0100011: begin // sw
            memWe = 1'b1;
            bIsImm = 1'b1;
            aluOpCode = 4'b0000;
        end
        7'b0110111: begin // lui
            regWe = 1'b1;
            bIsImm = 1'b1;
            bIs20bImm = 1'b1;
            aluOpCode = 4'b1011;
        end
        7'b1100011: begin // Branch instructions
            case (funct3)
                3'b000: begin // beq
                    pcSourceCode = condition ? 2'b01 : 2'b00;
                    aluOpCode = 4'b1000;
                end
                3'b100: begin // blt
                    pcSourceCode = condition ? 2'b01 : 2'b00;
                    aluOpCode = 4'b1001;
                end
                3'b110: begin // bltu
                    pcSourceCode = condition ? 2'b01 : 2'b00;
                    aluOpCode = 4'b1100;
                end
            endcase
        end
        7'b1101111: begin // jal
            pcSourceCode = 2'b10;
            regWe = 1'b1;
            bIsImm = 1'b1;
            bIs20bImm = 1'b1;
            aluOpCode = 4'b1010;
            regDataIsFromPC4 = 1'b1; 
        end
    endcase
end

endmodule


module RegFiles(
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
    integer i;
    initial 
       for (i=1;i<32;i=i+1) regs[i]=32'b0;
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];
    assign x2 = regs[2];  // 输出regs[2]的值
    always @(posedge clk)
        if (we && (waddr != 5'b0))
            regs[waddr] <= wdata;
endmodule


module alu(
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
        4'b1010:result=(dataB<<1)+dataA;//修改符合jal指令功能
        
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


module rom(
    input [7:0] addr,
    output [31:0] data
    );
    reg[31:0] insData[0:63];
    initial
        $readmemh("D:/OneDrive/rom12.txt",insData);
    assign data=insData[addr];
endmodule
