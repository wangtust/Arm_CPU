`timescale 1ns / 1ps

module tb_SCPU;

    // 参数定义
    reg clk;
    reg rst;
    wire [31:0] result;
    wire [6:0] a2g;
    wire [7:0] an;

    // 实例化SCPU模块
    SCPU mycpu (
        .clk(clk),
        .rst(rst),
        .result(result),
        .a2g(a2g),
        .an(an)
    );

    // 生成时钟信号
    always begin
        #5 clk = ~clk; // 每5时间单位翻转时钟信号
    end

    // 初始化信号
    initial begin
        // 初始化信号
        clk = 0;
        rst = 1; // 复位信号高

        // 等待一段时间后释放复位
        #10;
        rst = 0; // 释放复位
        
        // 运行一段时间，观察输出
        #1000; // 运行1000时间单位
        $finish; // 结束仿真
    end

    // 监控输出
    initial begin
        $monitor("Time: %0t | Result: %h | a2g: %b | an: %b", $time, result, a2g, an);
    end

endmodule
