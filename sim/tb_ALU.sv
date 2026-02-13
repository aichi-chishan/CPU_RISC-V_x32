`timescale 1ns / 1ps


module tb_ALU;
// 导入配置包以使用 ADD, SUB 等参数
import config_pkg::*;

    // 信号定义
    reg  [31:0] src_a;
    reg  [31:0] src_b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    // 实例化 ALU 模块
    ALU u_ALU (
        .src_a(src_a),
        .src_b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    // 辅助任务：打印测试结果
    task check_result;
        input [31:0] expected_val;
        input        expected_zero;
        input string test_name;
        begin
            if (result !== expected_val || zero !== expected_zero) begin
                $display("[FAIL] %s: Output = %h, Zero = %b | Expected = %h, Zero = %b", 
                         test_name, result, zero, expected_val, expected_zero);
            end else begin
                $display("[PASS] %s: Output = %h, Zero = %b", test_name, result, zero);
            end
        end
    endtask

    initial begin
        // 初始化
        src_a = 0;
        src_b = 0;
        alu_ctrl = 0;
        #10;

        $display("=== ALU Simulation Start ===");

        // 1. 测试 ADD (加法)
        // 10 + 20 = 30
        src_a = 32'd10; src_b = 32'd20; alu_ctrl = ADD;
        #10; check_result(32'd30, 1'b0, "ADD (10+20)");

        // 2. 测试 SUB (减法) & Zero 信号
        // 15 - 15 = 0 (Zero 应该变高)
        src_a = 32'd15; src_b = 32'd15; alu_ctrl = SUB;
        #10; check_result(32'd0, 1'b1, "SUB (15-15) Zero Check");

        // 3. 测试 AND (按位与)
        // 0xFFFF0000 & 0x0000FFFF = 0
        src_a = 32'hFFFF0000; src_b = 32'h0000FFFF; alu_ctrl = AND;
        #10; check_result(32'h0, 1'b1, "AND (Mask Check)");

        // 4. 测试 OR (按位或)
        // 0xAAAA0000 | 0x00005555 = 0xAAAA5555
        src_a = 32'hAAAA0000; src_b = 32'h00005555; alu_ctrl = OR;
        #10; check_result(32'hAAAA5555, 1'b0, "OR");

        // 5. 测试 XOR (按位异或)
        // 0xA5A5A5A5 ^ 0xFFFFFFFF = 0x5A5A5A5A (按位取反)
        src_a = 32'hA5A5A5A5; src_b = 32'hFFFFFFFF; alu_ctrl = XOR;
        #10; check_result(32'h5A5A5A5A, 1'b0, "XOR (Invert)");

        // 6. 测试 SLL (逻辑左移)
        // 1 << 4 = 16
        src_a = 32'd1; src_b = 32'd4; alu_ctrl = SLL;
        #10; check_result(32'd16, 1'b0, "SLL (1<<4)");

        // 7. 测试 SRL (逻辑右移)
        // 0xF0000000 >> 4 = 0x0F000000 (高位补0)
        src_a = 32'hF0000000; src_b = 32'd4; alu_ctrl = SRL;
        #10; check_result(32'h0F000000, 1'b0, "SRL (Logical Right)");

        // 8. 测试 SRA (算术右移)
        // 0xF0000000 (-268435456) >>> 4 = 0xFF000000 (高位补符号位1)
        src_a = 32'hF0000000; src_b = 32'd4; alu_ctrl = SRA;
        #10; check_result(32'hFF000000, 1'b0, "SRA (Arithmetic Right)");

        // 9. 测试 SLT (有符号比较)
        // -10 < 10 ? 结果应为 1
        src_a = -32'd10; src_b = 32'd10; alu_ctrl = SLT;
        #10; check_result(32'd1, 1'b0, "SLT (-10 < 10)");

        // 10. 测试 SLTU (无符号比较)
        // -1 (0xFFFFFFFF) < 10 ? 无符号看 -1 是最大值，所以结果应为 0
        src_a = -32'd1; src_b = 32'd10; alu_ctrl = SLTU;
        #10; check_result(32'd0, 1'b1, "SLTU (MaxU < 10)");

        $display("=== ALU Simulation End ===");
        $stop;
    end

endmodule
