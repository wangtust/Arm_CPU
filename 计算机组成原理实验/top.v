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
