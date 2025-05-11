module ControlUnit(
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7,
    input condition,
    output reg [1:0] pcSourceCode,
    output reg regWe,
    output reg memWe,
    output reg [3:0] aluOpCode,
    output reg bIsImm,
    output reg bIs20bImm,
    output reg regDataIsFromMem,
    output reg regDataIsFromPC4
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