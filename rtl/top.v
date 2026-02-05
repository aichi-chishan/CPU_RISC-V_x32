//top模块
module top(
    input wire clk,
    input wire rst_n
);

    // ====================================================
    // 1. 定义内部连接导线 (Wires)
    // ====================================================
    
    // IF (取指) 阶段信号
    wire [31:0] current_pc;    // 当前 PC 地址
    wire [31:0] instr;         // 当前指令机器码

    // ID (译码) 阶段信号
    wire        we;            // 控制信号: 是否写寄存器
    wire        alu_src;       // 控制信号: ALU输入源选择
    wire [3:0]  alu_ctrl;      // 控制信号: ALU运算类型
    wire [31:0] rdata1;        // 寄存器读出数据 1 (rs1)
    wire [31:0] rdata2;        // 寄存器读出数据 2 (rs2)
    wire [31:0] imm_ext;       // 扩展后的立即数

    // EX (执行) 阶段信号
    wire [31:0] alu_src_b;     // ALU 的 B 输入 (经过 MUX 选择后)
    wire [31:0] alu_result;    // ALU 运算结果
    wire        zero_flag;     // ALU 零标志 (暂时不用，悬空)

    // ====================================================
    // 2. 模块实例化 (连线)
    // ====================================================

    // --- [IF 阶段]: PC 和 指令存储器 ---
    
    PC u_PC (
        .clk    (clk),
        .rst_n  (rst_n),
        .pc_out (current_pc)   // 输出 PC 给 IMem
    );

    inst_mem u_inst_mem (
        .addr   (current_pc),  // 输入地址
        .instr  (instr)        // 输出指令给 ID 阶段
    );

    // --- [ID 阶段]: 控制单元、寄存器堆、立即数生成 ---

    CU u_CU (
        .opcode    (instr[6:0]),   // 指令的低7位
        .funct3    (instr[14:12]), // 指令的 func3
        .funct7    (instr[31:25]), // 指令的 func7
        .we        (we),    // 输出给 RegFile
        .alu_src   (alu_src),      // 输出给 MUX
        .alu_ctrl  (alu_ctrl)      // 输出给 ALU
    );

    reg_file u_reg_file (
        .clk    (clk),
        .we     (we),       // 写使能
        .raddr1 (instr[19:15]),    // rs1 索引
        .raddr2 (instr[24:20]),    // rs2 索引
        .waddr  (instr[11:7]),     // rd (写回目标) 索引
        .wdata  (alu_result),      // 【回环】将计算结果写回寄存器
        .rdata1 (rdata1),          // 输出到 ALU SrcA
        .rdata2 (rdata2)           // 输出到 MUX
    );

    imm_gen u_imm_gen (
        .instr   (instr),
        .imm_out (imm_ext)         // 输出扩展立即数到 MUX
    );

    // --- [EX 阶段]: MUX 和 ALU ---

    // 【关键胶水逻辑】: 二选一 MUX
    // 如果 alu_src 为 1 (ADDI指令)，选立即数；否则选寄存器数据 (ADD/SUB指令)
    assign alu_src_b = (alu_src == 1'b1) ? imm_ext : rdata2;

    ALU u_ALU (
        .src_a    (rdata1),        // 永远来自 rs1
        .src_b    (alu_src_b),     // 来自 MUX 的结果
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),    // 结果输出，并连回 RegFile
        .zero     (zero_flag)      // 暂时不处理分支，留空
    );

endmodule