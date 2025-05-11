`timescale 1ns / 1ps

module sim;

    // 仿真时钟和复位信号
    reg clk;
    reg rst;

    // 实例化待测试的top模块
    top uut (
        .clk(clk),
        .rst(rst)
    );

    // 时钟生成
    always #5 clk = ~clk; // 10ns周期的时钟

    initial begin
        // 初始化信号
        clk = 0;
        rst = 1;

        // 复位信号保持一段时间
        #20;
        rst = 0;

        // 运行一段时间以观察行为
        #1000;

        // 结束仿真
        $stop;
    end

endmodule