module ID(
      input  [31:0] ins,
      output [4:0] rs1,
      output [4:0] rs2,
      output [4:0] rd,
      output [6:0] opcode,
      output [11:0] imm12,
      output [2:0] funct3,
      output [19:0] imm20,
      output funct7   //指令第三十位，区分码
    );
    assign opcode=ins[6:0];
    assign rd=ins[11:7];
    assign funct3=ins[14:12];
    assign rs1=ins[19:15];
    assign rs2=ins[24:20];
    assign funct7=ins[30];
    
    wire I_type,S_type,B_type,J_type,U_type;
    //00x0011 I类
    assign I_type=~ins[6]&~ins[5]&~ins[3]&~ins[2]&ins[1]&ins[0];
    //1100011 B类
    //assign B_type=ins[6]&ins[5]&~ins[3]&~ins[2]&ins[1]&ins[0];//可以试下这样写对吗
    assign B_type=(&ins[6:5])&~(|ins[4:2])&(&ins[1:0]);
    //0100011 S类
    assign S_type=~ins[6]&ins[5]&~(|ins[4:2])&(&ins[1:0]);
    //0x10111 U类
    assign U_type=~ins[6]&ins[4]&~ins[3]&(&ins[2:0]);
    //1101111 J类
    assign J_type=(&ins[6:5])&~ins[4]&(&ins[3:0]);

    assign imm12={12{I_type}}&ins[31:20]|
                 {12{B_type}}&{ins[31],ins[7],ins[30:25],ins[11:8]}|
                 {12{S_type}}&{ins[31:25],ins[11:7]};
    assign imm20={20{U_type}}&ins[31:12]|{20{J_type}}&{ins[31],ins[19:12],ins[20],ins[30:21]};         
endmodule