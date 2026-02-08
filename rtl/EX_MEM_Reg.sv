import config_pkg::*;
module ex_mem_reg(
    input  wire clk,
    input  wire rst_n,

    // === 来自 EX 阶段的输入 ===
    // [WB 阶段控制]
    input  wire       ex_reg_we,
    input  wire [1:0] ex_wd_sel,
    // [MEM 阶段控制]
    input  wire       ex_mem_we,
    input  wire       ex_branch,  // 可能用于后续调试或高级预测
    input  wire       ex_jump,
    
    // 数据路径
    input  wire [31:0] ex_alu_result, // ALU计算结果 或 内存地址
    input  wire [31:0] ex_rs2_data,   // 存储指令(SW)要写入内存的数据 (Store Data)
    input  wire [31:0] ex_pc_plus4,   // PC+4 (用于JAL/JALR写回)
    input  wire        ex_zero,       // ALU 零标志 (用于分支判断)
    
    // 目标寄存器
    input  wire [4:0]  ex_rd_addr,    // 结果要写入哪个寄存器

    // === 输出到 MEM 阶段 ===
    // [WB 阶段控制]
    output reg        mem_reg_we,
    output reg  [1:0] mem_wd_sel,
    // [MEM 阶段控制]
    output reg        mem_mem_we,
    output reg        mem_branch,
    output reg        mem_jump,
    
    // 数据路径
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_wdata,     // 写给 Data Memory 的数据
    output reg  [31:0] mem_pc_plus4,
    output reg         mem_zero,
    
    // 目标寄存器
    output reg  [4:0]  mem_rd_addr
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_reg_we     <= 1'b0;
            mem_mem_we     <= 1'b0;
            mem_wd_sel     <= ALU_result;
            mem_branch     <= 1'b0;
            mem_jump       <= 1'b0;
            mem_alu_result <= 32'b0;
            mem_wdata      <= 32'b0;
            mem_pc_plus4   <= 32'b0;
            mem_zero       <= 1'b0;
            mem_rd_addr    <= 5'b0;
        end else begin
            mem_reg_we     <= ex_reg_we;
            mem_mem_we     <= ex_mem_we;
            mem_wd_sel     <= ex_wd_sel;
            mem_branch     <= ex_branch;
            mem_jump       <= ex_jump;
            mem_alu_result <= ex_alu_result;
            mem_wdata      <= ex_rs2_data; // 注意这里透传的是 rs2 的原始数据
            mem_pc_plus4   <= ex_pc_plus4;
            mem_zero       <= ex_zero;
            mem_rd_addr    <= ex_rd_addr;
        end
    end
endmodule