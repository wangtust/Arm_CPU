module rom(
    input [7:0] addr,
    output [31:0] data
    );
    reg[31:0] insData[0:63];
    initial
        $readmemh("../../../../insData.txt",insData);
    assign data=insData[addr];
endmodule