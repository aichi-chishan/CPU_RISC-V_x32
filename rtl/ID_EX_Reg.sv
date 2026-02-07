module id_ex_reg(
    input  wire clk,
    input  wire rst_n,
    
    // 控制信号
    input  wire flush,      // 冲刷 (用于控制冒险预测失败)

    // === 来自 ID 阶段的输入 ===
    // [WB 阶段控制]
    input  wire       id_reg_we,
    input  wire [1:0] id_wd_sel,
    // [MEM 阶段控制]
    input  wire       id_mem_we,
    input  wire       id_branch,
    input  wire       id_jump,
    // [EX 阶段控制]
    input  wire       id_alu_src,
    input  wire [3:0] id_alu_ctrl,
    
    // 数据路径
    input  wire [31:0] id_pc,
    input  wire [31:0] id_rdata1,
    input  wire [31:0] id_rdata2,
    input  wire [31:0] id_imm,
    
    // 寄存器地址 (用于 Forwarding 和 WB)
    input  wire [4:0]  id_rs1_addr,
    input  wire [4:0]  id_rs2_addr,
    input  wire [4:0]  id_rd_addr,

    // === 输出到 EX 阶段 ===
    // [WB 阶段控制]
    output reg        ex_reg_we,
    output reg  [1:0] ex_wd_sel,
    // [MEM 阶段控制]
    output reg        ex_mem_we,
    output reg        ex_branch,
    output reg        ex_jump,
    // [EX 阶段控制]
    output reg        ex_alu_src,
    output reg  [3:0] ex_alu_ctrl,
    
    // 数据路径
    output reg  [31:0] ex_pc,
    output reg  [31:0] ex_rdata1,
    output reg  [31:0] ex_rdata2,
    output reg  [31:0] ex_imm,
    
    // 寄存器地址
    output reg  [4:0]  ex_rs1_addr,
    output reg  [4:0]  ex_rs2_addr,
    output reg  [4:0]  ex_rd_addr
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // 复位或冲刷时，所有控制信号清零
            ex_reg_we   <= 1'b0;
            ex_mem_we   <= 1'b0;
            ex_branch   <= 1'b0;
            ex_jump     <= 1'b0;
            ex_wd_sel   <= 2'b00;
            ex_alu_src  <= 1'b0;
            ex_alu_ctrl <= 4'b0;
            
            // 数据部分清零 (可选，但建议清零)
            ex_pc       <= 32'b0;
            ex_rdata1   <= 32'b0;
            ex_rdata2   <= 32'b0;
            ex_imm      <= 32'b0;
            ex_rs1_addr <= 5'b0;
            ex_rs2_addr <= 5'b0;
            ex_rd_addr  <= 5'b0;
        end else begin
            // 正常传递
            ex_reg_we   <= id_reg_we;
            ex_wd_sel   <= id_wd_sel;
            ex_mem_we   <= id_mem_we;
            ex_branch   <= id_branch;
            ex_jump     <= id_jump;
            ex_alu_src  <= id_alu_src;
            ex_alu_ctrl <= id_alu_ctrl;
            
            ex_pc       <= id_pc;
            ex_rdata1   <= id_rdata1;
            ex_rdata2   <= id_rdata2;
            ex_imm      <= id_imm;
            
            ex_rs1_addr <= id_rs1_addr;
            ex_rs2_addr <= id_rs2_addr;
            ex_rd_addr  <= id_rd_addr;
        end
    end
endmodule