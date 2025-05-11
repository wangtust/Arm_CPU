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