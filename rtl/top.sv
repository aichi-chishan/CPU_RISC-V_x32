import config_pkg::*;
module top (
    input wire clk,
    input wire rst_n
);
//IF阶段

    wire [31:0] current_pc; // 当前 PC 值

    PC u_PC (
        .clk(clk),
        .rst_n(rst_n),
        .branch_target(ex_branch_target), // 来自 EX 阶段的跳转目标地址
        .pc_src(ex_pc_src), // 来自 EX 阶段的跳转控制信号
        .stall(stall_pc), // 来自 Hazard Unit 的流水线暂停信号
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
        .stall(stall_if_id), // 来自 Hazard Unit 的流水线暂停信号
        .flush(flush_if_id), // 来自 Hazard Unit 的冲刷信号 (包含跳转冲刷)
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
    wire id_alu_src;

    wire id_branch;
    wire id_jump;

    wire [3:0] id_alu_ctrl;
    wire [1:0] id_wd_sel;

    CU u_CU (
        //inputs
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        //outputs
        .reg_we(id_reg_we),
        .mem_we(id_mem_we),
        .alu_src(id_alu_src),

        .branch(id_branch),
        .jump(id_jump),

        .alu_ctrl(id_alu_ctrl),
        .wd_sel(id_wd_sel)
    );

    wire [4:0] id_raddr1;
    wire [4:0] id_raddr2;
    assign id_raddr1 = id_instr[19:15];
    assign id_raddr2 = id_instr[24:20];

    wire [31:0] id_rdata1;
    wire [31:0] id_rdata2;

    reg_file u_reg_file (
        //inputs
        .clk(clk),
        .we(wb_reg_we), // 来自 WB 阶段的寄存器写使能
        .raddr1(id_raddr1), // rs1 地址来自 ID 阶段指令
        .raddr2(id_raddr2), // rs2 地址来自 ID
        .waddr(wb_waddr), // rd 地址来自 WB 阶段
        .wdata(wb_wdata), // 写入数据来自 WB 阶段
        //outputs
        .rdata1(id_rdata1), // rs1 数据输出到 ID 阶段
        .rdata2(id_rdata2) // rs2 数据输出到 ID 阶段
    );

    wire [31:0] id_imm;

    imm_gen u_imm_gen (
        .instr(id_instr), // 来自 ID 阶段的指令
        .imm_out(id_imm) // 输出立即数，连接到 ID/EX 寄存器
    );

    wire [4:0] id_rd_addr; // 明确声明位宽，防止被默认为 1 位
    assign id_rd_addr = id_instr[11:7];

    id_ex_reg u_id_ex_reg (
        //inputs
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_id_ex), // 来自 Hazard Unit 的冲刷信号 (包含Load-Use气泡和跳转冲刷)
        //WB 控制信号
        .id_reg_we(id_reg_we),
        .id_wd_sel(id_wd_sel),
        //MEM 控制信号
        .id_mem_we(id_mem_we),
        .id_branch(id_branch),
        .id_jump(id_jump),
        //EX 控制信号
        .id_alu_src(id_alu_src),
        .id_alu_ctrl(id_alu_ctrl),
        //数据路径
        .id_pc(id_pc),
        .id_rdata1(id_rdata1),
        .id_rdata2(id_rdata2),
        .id_imm(id_imm),
        .id_instr(id_instr),
        //寄存器地址
        .id_raddr1(id_raddr1),
        .id_raddr2(id_raddr2),
        .id_rd_addr(id_rd_addr),
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
        .ex_instr(ex_instr),
        //寄存器地址输出
        .ex_raddr1(ex_raddr1), // 连接到 5 位 wire
        .ex_raddr2(ex_raddr2), 
        .ex_rd_addr(ex_rd_addr)
    );

//EX阶段
    // 生成 ex_mem_read 信号：如果 EX 阶段的写回选择是 MEM_result，说明是 Load 指令
    //wire ex_mem_read;
    //assign ex_mem_read = (ex_wd_sel == MEM_result);
    //以上三行在Hazrd unit写了

    wire [4:0] ex_raddr1; // 修正：寄存器地址应为 5 位
    wire [4:0] ex_raddr2; // 修正：寄存器地址应为 5 位
    wire [4:0] ex_rd_addr; // 修正：寄存器地址应为 5 位
    wire [1:0] ex_forward_a;
    wire [1:0] ex_forward_b;

    forwarding_unit u_forwarding_unit (
        //inputs
        .rs1_ex(ex_raddr1), // 使用统一命名的 5 位地址
        .rs2_ex(ex_raddr2), 

        .rd_mem(mem_rd_addr), // 来自 MEM 阶段的 rd 地址
        .reg_write_mem(mem_reg_we), // 来自 MEM 阶段的寄存器写使能
        .rd_wb(wb_rd_addr), // 来自 WB 阶段的 rd 地址
        .reg_write_wb(wb_reg_we), // 来自 WB 阶段的寄存器写使能
        //outputs
        .forward_a(ex_forward_a), // 转发控制信号 A，连接到 EX 阶段 ALU 输入 Mux
        .forward_b(ex_forward_b)  // 转发控制信号 B，连接到 EX 阶段 ALU 输入 Mux
    );

    wire [31:0] ex_src_a; // ALU 输入 A，经过转发选择
    wire [31:0] ex_forward_rs2_val; // 经过转发的 rs2 值 (用于 Store Data 和 ALU 输入备选)
    wire [31:0] ex_src_b; // 最终 ALU 输入 B (可能是 rs2 或 立即数)

    assign ex_src_a = (ex_forward_a == 2'b00) ? ex_rdata1 :
                      (ex_forward_a == 2'b01) ? wb_wdata :
                      (ex_forward_a == 2'b10) ? mem_alu_result : ex_rdata1;
    
    // 1. 先处理 rs2 的转发 (Store 指令的数据来源)
    assign ex_forward_rs2_val = (ex_forward_b == 2'b00) ? ex_rdata2 :
                                (ex_forward_b == 2'b01) ? wb_wdata :
                                (ex_forward_b == 2'b10) ? mem_alu_result : ex_rdata2;

    // 2. 再根据 alu_src 选择 ALU 的第二个操作数 (寄存器/转发值 还是 立即数)
    assign ex_src_b = (ex_alu_src == 1'b1) ? ex_imm : ex_forward_rs2_val;

    wire [31:0] ex_alu_result; 
    wire ex_zero; 

    ALU u_ALU (
        //inputs
        .src_a(ex_src_a), // 来自 EX 阶段的 ALU 输入 A
        .src_b(ex_src_b), // 来自 EX 阶段的 ALU 输入 B
        .alu_ctrl(ex_alu_ctrl), // 来自 EX 阶段的 ALU 控制信号
        //outputs
        .result(ex_alu_result), // 输出 ALU 结果，连接到 EX/MEM 寄存器
        .zero(ex_zero) // 结果是否为0 (分支指令用，当前可留空)
    );
    
    wire [31:0] ex_branch_target; // 来自 EX 阶段的跳转目标地址
    wire ex_pc_src; // 来自 EX 阶段的跳转控制信号
    assign ex_branch_target = ex_pc + ex_imm;
    
    // 考虑到未来支持 BNE, 这里可以根据 funct3 进一步细化逻辑
    // 假设 id_instr[14:12] 是 funct3
    wire [31:0] ex_instr;
    assign ex_funct3 = ex_instr[14:12];
    wire ex_branch_cond_met = (ex_funct3 == 3'b000) ? ex_zero :  // BEQ
                           (ex_funct3 == 3'b001) ? !ex_zero : // BNE
                           1'b0;
    assign ex_pc_src = ex_jump || (ex_branch && ex_branch_cond_met);

    wire ex_reg_we;
    wire ex_wd_sel;

    wire ex_mem_we;
    wire ex_branch;
    wire ex_jump;

    ex_mem_reg u_ex_mem_reg (
        //inputs
        .clk(clk),
        .rst_n(rst_n),
        //EX 阶段控制信号
        .ex_reg_we(ex_reg_we),
        .ex_wd_sel(ex_wd_sel),
        .ex_mem_we(ex_mem_we),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        //EX 阶段数据路径
        .ex_alu_result(ex_alu_result),
        .ex_rs2_data(ex_forward_rs2_val), // 修正：必须使用经过转发的 rs2 数据，否则 Store 指令无法拿到最新值
        .ex_pc_plus4(ex_pc + 32'h00000004), // PC+4 用于 JAL/JALR 写回
        .ex_zero(ex_zero), // ALU 零标志，用于分支判断
        //EX 阶段寄存器地址
        .ex_rd_addr(ex_rd_addr),
        //outputs
        //MEM 阶段控制信号
        .mem_reg_we(mem_reg_we),
        .mem_wd_sel(mem_wd_sel),
        .mem_mem_we(mem_mem_we),
        .mem_branch(mem_branch),
        .mem_jump(mem_jump),
        //MEM 阶段数据路径
        .mem_alu_result(mem_alu_result),
        .mem_wdata(mem_wdata), // 写给 Data Memory 的数据
        .mem_pc_plus4(mem_pc_plus4), // PC+4 用于 JAL/JALR 写回
        .mem_zero(mem_zero), // ALU 零标志，透传到 MEM 阶段（可能用于后续调试或高级预测）
        //MEM 阶段寄存器地址
        .mem_rd_addr(mem_rd_addr)
    );

//MEM阶段
    wire mem_reg_we;
    wire [1:0] mem_wd_sel;
    wire mem_mem_we;
    wire mem_branch;
    wire mem_jump;

    wire [31:0] mem_alu_result;
    wire [31:0] mem_wdata;
    wire [31:0] mem_pc_plus4;
    wire mem_zero;

    wire [4:0] mem_rd_addr;

    wire [31:0] mem_rdata; // 从内存读取的数据

    data_mem u_data_mem (
        .clk(clk),
        //inputs
        .we(mem_mem_we), // 来自 MEM 阶段的内存写使能
        .addr(mem_alu_result), // 来自 MEM 阶段的 ALU 结果，作为内存地址
        .wdata(mem_wdata), // 来自 MEM 阶段的写数据，连接到 Data Memory 的写数据输入
        //outputs
        .rdata(mem_rdata) // 从内存读取的数据，连接到 MEM/WB 寄存器
     );

    mem_wb_reg u_mem_wb_reg (
        //inputs
        .clk(clk),
        .rst_n(rst_n),
        //MEM 阶段控制信号
        .mem_reg_we(mem_reg_we),
        .mem_wd_sel(mem_wd_sel),
        //MEM 阶段数据路径
        .mem_alu_result(mem_alu_result),
        .mem_dmem_data(mem_rdata), // 从内存读出的数据 (Load Data)
        .mem_pc_plus4(mem_pc_plus4), // PC+4 用于 JAL/JALR 写回
        //MEM 阶段寄存器地址
        .mem_rd_addr(mem_rd_addr),
        //outputs
        //WB 阶段控制信号
        .wb_reg_we(wb_reg_we),
        .wb_wd_sel(wb_wd_sel),
        //WB 阶段数据路径
        .wb_alu_result(wb_alu_result),
        .wb_dmem_data(wb_dmem_data),
        .wb_pc_plus4(wb_pc_plus4),
        //WB 阶段寄存器地址
        .wb_rd_addr(wb_rd_addr)
    );
     
//WB阶段
    wire wb_reg_we;
    wire [1:0] wb_wd_sel;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_dmem_data;
    wire [31:0] wb_pc_plus4;
    wire [4:0] wb_rd_addr;

    wire [31:0] wb_final_data;
    
    // WB 阶段数据多路选择器 (MUX)
    // 根据 wb_wd_sel 选择写入寄存器的数据来源：ALU结果、内存数据 或 PC+4
    assign wb_final_data = (wb_wd_sel == ALU_result) ? wb_alu_result :
                           (wb_wd_sel == MEM_result) ? wb_dmem_data :
                           (wb_wd_sel == PC_plus4  ) ? wb_pc_plus4 : wb_alu_result;
    
    wire [4:0]  wb_waddr;
    wire [31:0] wb_wdata;
    assign wb_wdata = wb_final_data; // 连接到 RegFile 的写数据端口
    assign wb_waddr = wb_rd_addr;    // 连接到 RegFile 的写地址端口

//Hazard unit 冒险单元

    wire stall_pc;     // 冻结 PC
    wire stall_if_id;  // 冻结 IF/ID
    wire flush_if_id;  // 冲刷 IF/ID
    wire flush_id_ex;  // 冲刷 ID/EX
    
    // 生成 ex_mem_read 信号：如果 EX 阶段的写回选择是 MEM_result，说明是 Load 指令
    wire ex_mem_read;
    assign ex_mem_read = (ex_wd_sel == MEM_result);

    hazard_unit u_hazard_unit (
        // Load-Use 检测输入
        .id_raddr1(id_raddr1),
        .id_raddr2(id_raddr2),
        .ex_rd_addr(ex_rd_addr),
        .ex_mem_read(ex_mem_read), // 刚刚生成的信号
        // 控制冒险检测输入
        .ex_pc_src(ex_pc_src),
        // 输出控制信号
        .stall_pc(stall_pc),
        .stall_if_id(stall_if_id),
        .flush_if_id(flush_if_id),
        .flush_id_ex(flush_id_ex)
    );

endmodule