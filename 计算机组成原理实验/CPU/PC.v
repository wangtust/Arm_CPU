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