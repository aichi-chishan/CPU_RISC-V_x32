import config_pkg::*;
module mem_wb_reg(
    input  wire clk,
    input  wire rst_n,

    // === 来自 MEM 阶段的输入 ===
    // [WB 阶段控制]
    input  wire       mem_reg_we,
    input  wire [1:0] mem_wd_sel,
    
    // 数据路径
    input  wire [31:0] mem_alu_result, // ALU 计算结果
    input  wire [31:0] mem_dmem_data,  // 从内存读出的数据 (Load Data)
    input  wire [31:0] mem_pc_plus4,   // PC+4
    
    // 目标寄存器
    input  wire [4:0]  mem_rd_addr,

    // === 输出到 WB 阶段 ===
    // [WB 阶段控制]
    output reg        wb_reg_we,
    output reg  [1:0] wb_wd_sel,
    
    // 数据路径
    output reg  [31:0] wb_alu_result,
    output reg  [31:0] wb_dmem_data,
    output reg  [31:0] wb_pc_plus4,
    
    // 目标寄存器
    output reg  [4:0]  wb_rd_addr
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_reg_we     <= 1'b0;
            wb_wd_sel     <= ALU_result;
            wb_alu_result <= 32'b0;
            wb_dmem_data  <= 32'b0;
            wb_pc_plus4   <= 32'b0;
            wb_rd_addr    <= 5'b0;
        end else begin
            wb_reg_we     <= mem_reg_we;
            wb_wd_sel     <= mem_wd_sel;
            wb_alu_result <= mem_alu_result;
            wb_dmem_data  <= mem_dmem_data;
            wb_pc_plus4   <= mem_pc_plus4;
            wb_rd_addr    <= mem_rd_addr;
        end
    end
endmodule