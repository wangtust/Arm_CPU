`timescale 1ns / 1ps

module SCPU_tb;

    // 输入信号
    reg clk;
    reg rst;

    // 输出信号
    wire [6:0] a2g;
    wire [7:0] an;

    // 实例化被测模块
    SCPU uut (
        .clk(clk),
        .rst(rst),
        .a2g(a2g),
        .an(an)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns 时钟周期
    end

    // 仿真过程
    initial begin
        // 初始化输入信号
        rst = 1;

        // 等待一段时间后释放复位
        #20;
        rst = 0;

        // 运行一段时间以观察输出
        #1000;

        // 结束仿真
        $stop;
    end

endmodule