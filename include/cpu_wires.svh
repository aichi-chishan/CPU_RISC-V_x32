// cpu_wires.svh

//IF阶段
    wire [31:0] current_pc; // 当前 PC 值
    wire [31:0] if_instr; // 从指令存储器读取的指令

//ID阶段
    wire [31:0] id_instr;
    wire [31:0] id_pc;

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire id_reg_we;
    wire id_mem_we;
    wire id_alu_src;

    wire id_branch;
    wire id_jump;

    wire [3:0] id_alu_ctrl;
    wire [1:0] id_wd_sel;

    wire [4:0] id_raddr1;
    wire [4:0] id_raddr2;  
    wire [31:0] id_rdata1;
    wire [31:0] id_rdata2;  

    wire [31:0] id_imm;

    wire [4:0] id_rd_addr; // 明确声明位宽，防止被默认为 1 位

//EX阶段
    wire [4:0] ex_raddr1; // 修正：寄存器地址应为 5 位
    wire [4:0] ex_raddr2; // 修正：寄存器地址应为 5 位
    wire [4:0] ex_rd_addr; // 修正：寄存器地址应为 5 位
    wire [1:0] ex_forward_a;
    wire [1:0] ex_forward_b;
    
    wire [31:0] ex_src_a; // ALU 输入 A，经过转发选择
    wire [31:0] ex_forward_rs2_val; // 经过转发的 rs2 值 (用于 Store Data 和 ALU 输入备选)
    wire [31:0] ex_src_b; // 最终 ALU 输入 B (可能是 rs2 或 立即数)
    
    wire [31:0] ex_alu_result; 
    wire ex_zero; 

    wire [31:0] ex_branch_target; // 来自 EX 阶段的跳转目标地址
    wire ex_pc_src; // 来自 EX 阶段的跳转控制信号

    wire [31:0] ex_instr;

    wire ex_branch_cond_met;

    wire ex_reg_we;
    wire [1:0] ex_wd_sel;

    wire ex_mem_we;
    wire ex_branch;
    wire ex_jump;
    //漏掉的声明
    wire [3:0] ex_alu_ctrl;
    wire [31:0] ex_pc;
    wire [31:0] ex_rdata1;
    wire [31:0] ex_rdata2;
    wire [31:0] ex_imm;
    wire ex_alu_src;
    wire [2:0] ex_funct3;

    logic branch_cond_met; //B型指令的中间变量

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

//WB阶段
    wire wb_reg_we;
    wire [1:0] wb_wd_sel;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_dmem_data;
    wire [31:0] wb_pc_plus4;
    wire [4:0] wb_rd_addr;

    wire [31:0] wb_final_data;

    wire [4:0]  wb_waddr;
    wire [31:0] wb_wdata;

    
//Hazard unit 冒险单元
    wire ex_mem_read;

    wire stall_pc;     // 冻结 PC
    wire stall_if_id;  // 冻结 IF/ID
    wire flush_if_id;  // 冲刷 IF/ID
    wire flush_id_ex;  // 冲刷 ID/EX