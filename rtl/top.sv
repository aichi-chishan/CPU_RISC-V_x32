import config_pkg::*;
module top (
    input wire clk,
    input wire rst_n
);
    //IF阶段
    wire [31:0] branch_target_ex; // 来自 EX 阶段的跳转目标地址
    wire pc_src; // 来自 EX 阶段的跳转控制信号
    wire stall; // 来自 Hazard Unit 的流水线暂停信号
    wire [31:0] current_pc; // 当前 PC 值


    PC u_PC (
        .clk(clk),
        .rst_n(rst_n),
        .branch_target(branch_target_ex), // 来自 EX 阶段的跳转目标地址
        .pc_src(pc_src), // 来自 EX 阶段的跳转控制信号
        .stall(stall), // 来自 Hazard Unit 的流水线暂停信号
        .current_pc_out(current_pc) // 输出当前 PC 值
    );

    wire [31:0] if_instr; // 从指令存储器读取的指令
    inst_mem u_inst_mem (
        .addr(current_pc), // 来自 PC 模块的当前 PC 值
        .instr(if_instr) // 输出指令，连接到 IF/ID 寄存器
    );

    if_id_reg u_if_id_reg (
        .clk(clk),
        .rst_n(rst_n),
        //inputs
        .stall(stall), // 来自 Hazard Unit 的流水线暂停信号
        .flush(pc_src), // 来自 EX 阶段的跳转控制信号，作为冲刷信号
        .if_pc(current_pc), // 来自 PC 模块的当前 PC 值
        .if_instr(if_instr), // 来自指令存储器的指令
        //outputs
        .id_pc(id_pc), // 输出到 ID 阶段的 PC 值
        .id_instr(id_instr) // 输出到 ID 阶段的指令
    );

    //ID阶段
    wire [31:0] id_instr;
    wire [31:0] id_pc;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = id_instr[6:0];
    assign funct3 = id_instr[14:12];
    assign funct7 = id_instr[31:25];

    wire id_reg_we;
    wire id_mem_we;
    wire id_alu_ctrl;
    wire id_wd_sel;

    wire id_branch;
    wire id_jumop;
    wire id_alu_ctrl;
    wire id_wd_sel;

    CU u_CU (
        //inputs
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        //outputs
        .reg_we(id_reg_we),
        .mem_we(id_mem_we),
        .branch(id_branch),
        .jump(id_jump),
        .alu_ctrl(id_alu_ctrl),
        .wd_sel(id_wd_sel)
    )

    wire wb_reg_we;
    wire [4:0]  wb_waddr;
    wire [31:0] wb_wdata;
    wire [31:0] id_rdata1;
    wire [31:0] id_rdata2;

    reg_file u_reg_file (
        //inputs
        .clk(clk),
        .we(wb_reg_we), // 来自 WB 阶段的寄存器写使能
        .raddr1(id_instr[19:15]), // rs1 地址来自 ID 阶段指令
        .raddr2(id_instr[24:20]), // rs2 地址来自 ID
        .waddr(wb_waddr), // rd 地址来自 WB 阶段
        .wdata(wb_wdata) // 写入数据来自 WB 阶段
        //outputs
        .rdata1(id_rdata1), // rs1 数据输出到 ID 阶段
        .rdata2(id_rdata2) // rs2 数据输出到 ID 阶段
    )

    wire [31:0] id_imm;

    imm_gen u_imm_gen (
        .instr(id_instr), // 来自 ID 阶段的指令
        .imm_out(id_imm) // 输出立即数，连接到 ID/EX 寄存器
    );

    id_ex_reg u_id_ex_reg (
        //inputs
        .clk(clk),
        .rst_n(rst_n),
        .flush(pc_src), // 来自 EX 阶段的跳转控制信号，作为冲刷信号
        //WB 控制信号
        .id_reg_we(wb_reg_we),
        .id_wd_sel(wb_wd_sel),
        //MEM 控制信号
        .id_mem_we(mem_mem_we),
        .id_branch(mem_branch),
        .id_jump(mem_jump),
        //EX 控制信号
        .id_alu_src(ex_alu_src),
        .id_alu_ctrl(ex_alu_ctrl),
        //数据路径
        .id_pc(id_pc),
        .id_rdata1(id_rdata1),
        .id_rdata2(id_rdata2),
        .id_imm(id_imm),
        //寄存器地址
        .id_rs1_addr(id_instr[19:15]),
        .id_rs2_addr(id_instr[24:20]),
        .id_rd_addr(id_instr[11:7]),
        //outputs
        //WB 控制信号
        .ex_reg_we(ex_reg_we),
        .ex_wd_sel(ex_wd_sel),
        //MEM 控制信号
        .ex_mem_we(ex_mem_we),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        //EX 控制信号
        .ex_alu_src(ex_alu_src),
        .ex_alu_ctrl(ex_alu_ctrl),
        //数据路径
        .ex_pc(ex_pc),
        .ex_rdata1(ex_rdata1),
        .ex_rdata2(ex_rdata2),
        .ex_imm(ex_imm),
        //寄存器地址
        .ex_rs1_addr(ex_rs1_addr),
        .ex_rs2_addr(ex_rs2_addr),
        .ex_rd_addr(ex_rd_addr)
    )

    //EX阶段
    
endmodule