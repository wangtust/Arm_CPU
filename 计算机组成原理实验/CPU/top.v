
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
    InsROM myrom(
        .addr(addr[9:2]),
        .data(insdata)
     );
     
     //TODO:
endmodule