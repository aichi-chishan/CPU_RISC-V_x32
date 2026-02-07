module CU(
    input  wire [6:0] opcode,   // 指令[6:0]
    input  wire [2:0] funct3,   // 指令[14:12]
    input  wire [6:0] funct7,   // 指令[31:25]

    output reg        reg_we,   // 寄存器写使能
    output reg        mem_we,   // 内存写使能
    output reg        alu_src,  // ALU输入源选择
    
    output reg        branch,   // 分支信号
    output reg        jump,     // 跳转信号

    output reg  [3:0] alu_ctrl  // ALU运算方式
    output reg  [1:0] wd_sel    // 写入数据来自何方 write_data_select
    //wd_sel 的作用:wd_sel 控制的是写回数据多路选择器 (Write Back Mux)，决定了是把 ALU 的结果、内存的数据还是 PC+4 写回到目标寄存器 (rd) 中。
);

    //=========================
    // Control logic
    //=========================

    always @(*) begin
        //默认状态定义
        reg_we   = 1'b0;
        mem_we   = 1'b0;
        alu_src  = REG;
        branch   = 1'b0;
        jump     = 1'b0;
        alu_ctrl = ADD;
        wd_sel   = ALU_result;

        case(opcode)

            //========================= 
            // R-type 寄存器指令
            // opcode = 0110011 
            //=========================

            7'b0110011:begin

                reg_we = 1'b1;
                alu_src = REG;
                wd_sel = ALU_result;

                case(funct3)                   
                    3'b000:begin
                        case(funct7)
                            7'b0000000: alu_ctrl = ADD;
                            7'b0100000: alu_ctrl = SUB;
                            default: ADD;
                        endcase
                    end
                    3'b111: alu_ctrl = AND; 
                    3'b110: alu_ctrl = OR; 
                    3'b100: alu_ctrl = XOR; 
                    3'b001: alu_ctrl = SLL;
                    3'b101:begin
                        case(funct7)
                            7'b0000000: alu_ctrl = SRL;
                            7'b0100000: alu_ctrl = SRA;
                            default: SRL;
                        endcase
                    end
                    3'b010: alu_ctrl = SLT; 
                    3'b011: alu_ctrl = SLTU;
                    default: alu_ctrl = ADD;
                endcase
            end

            //========================= 
            // I-type 立即数算术运算
            // opcode = 0010011 
            //=========================

            7'b0010011:begin

                reg_we = 1'b1; 
                alu_src = IMM;
                wd_sel = ALU_result;

                case(funct3)
                    3'b000: alu_ctrl = ADD;  // ADDI 
                    3'b111: alu_ctrl = AND;  // ANDI 
                    3'b110: alu_ctrl = OR;   // ORI 
                    3'b100: alu_ctrl = XOR;  // XORI 
                    3'b010: alu_ctrl = SLT;  // SLTI 
                    3'b011: alu_ctrl = SLTU; // SLTIU 
                    3'b001: alu_ctrl = SLL;  // SLLI

                    3'b101: case(funct7) 
                        7'b0000000: alu_ctrl = SRL; // SRLI 
                        7'b0100000: alu_ctrl = SRA; // SRAI
                        default:    alu_ctrl = SRL;
                    endcase
                    default: ADD;
                endcase
            end

            //========================= 
            // S-type 存储到内存 Store
            // opcode = 0100011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            //=========================

            7'b0100011:begin

                mem_we = 1'b1; 
                alu_src = IMM; 
                alu_ctrl = ADD;

            end
          
            //========================= 
            // L-type 载入寄存器 Load
            // opcode = 0000011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            //=========================

            7'b0000011:begin
                
                reg_we = 1'b1;
                alu_src = IMM;
                alu_ctrl = ADD;
                wd_sel = MEM_result;

            end
//B型还得细分
            //========================= 
            // B-type 条件分支指令 Branch
            // BEQ等于转移，BNE不等于跳转
            // opcode = 1100011 
            //=========================

            7'b1100011: begin
                branch = 1'b1; 
                alu_src = REG; 
                alu_ctrl = SUB;
            end
//PC模块可能得改
            //========================= 
            // JAL 
            // opcode = 1101111 
            //=========================

            7'b1101111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
                wd_sel = PC_plus4;
            end

            //========================= 
            // JALR 
            // opcode = 1100111 
            //========================= 
            7'b1100111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
                alu_src = IMM; 
                wd_sel = PC_plsu4;
            end

            //========================= 
            // default 
            //========================= 
            default:begin
                reg_we = 1'b0;
            end
        endcase
    end
endmodule

module PC( 
    input  wire clk,
    input  wire rst_n,
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire branch,
    input  wire jump,
    input  wire [31:0] imm,
    input  wire [31:0] alu_result,
    input  wire zero,
    output reg  [31:0] pc_out 
);
    reg [31:0] next_pc;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc_out <= 32'h00000000;    
        end else begin
            pc <= next_pc;
        end
    end
    
    always @(*) begin
        // 1. 默认情况：顺序执行
        next_pc = pc+4;

        // 2. 处理 JUMP (JAL, JALR)
        if (jump) begin
            if (opcode == 7'b1100111) begin
                // JALR: 目标地址 = rs1 + imm
                // 你的 CU 中 JALR 配置了 alu_src=IMM, alu_ctrl=ADD
                // 所以 ALU_Result 就是目标地址
                // RISC-V 规范要求 JALR 最低位设为0
                next_pc = alu_result & 32'hFFFFFFFE; 
            end
            else begin
                // JAL: 目标地址 = PC + imm
                next_pc = pc + imm;
            end
        end

        // 3. 处理 Branch (BEQ, BNE)
        else if (branch) begin
            case (funct3)
                3'b000: begin // BEQ
                    if (zero) // 如果相等 (ALU结果为0)
                        next_pc = pc + imm;
                end
                3'b001: begin // BNE
                    if (!zero) // 如果不相等 (ALU结果不为0)
                        next_pc = pc + imm;
                end
                default: begin
                    // 其他分支指令暂未实现，保持 PC+4
                    next_pc = pc + 4;
                end
            endcase
        end
    end


endmodule

module ALU (
    input  wire [31:0] src_a,   // 操作数 A
    input  wire [31:0] src_b,   // 操作数 B
    input  wire [3:0]  alu_ctrl,// 运算控制信号
    output reg  [31:0] result,  // 运算结果
    output wire        zero     // 结果是否为0 (分支指令用，当前可留空)
);
    parameter ADD  = 4'd0;
    parameter SUB  = 4'd1; 
    parameter AND  = 4'd2;
    parameter OR   = 4'd3;
    parameter XOR  = 4'd4; // 按位异或
    parameter SLL  = 4'd5;
    parameter SRL  = 4'd6;
    parameter SRA  = 4'd7;
    parameter SLT  = 4'd8;
    parameter SLTU = 4'd9;

    always @(*) begin
        case(alu_ctrl)
            //算术运算
            ADD:result = src_a + src_b;
            SUB:result = src_a - src_b;
            AND:result = src_a & src_b;
            OR: result = src_a | src_b;
            XOR:result = src_a ^ src_b;
            //位移指令
            SLL:result = src_a << src_b[4:0];
            SRL:result = src_a >> src_b[4:0];
            SRA:result = $signed(src_a) >>> src_b[4:0];  
            //比较指令
            SLT: result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;
            SLTU:result = (src_a < src_b) ? 32'd1 : 32'd0;
            default: begin
                result = 32'b0;  // 默认值
            end
        endcase
    end
    assign zero = (result == 32'b0);
endmodule

//内存模块
module data_mem (
    input wire clk,
    input wire we,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] ram [0:1023];
    assign rdata = ram[addr[31:2]];
    always @(posedge clk)begin
        if (we) begin
            ram[addr[31:2]] <= wdata;
        end
    end
endmodule

//Immediate Generator 立即数生成器,扩展功能 ID
module imm_gen (
    input wire [31:0] instr, //Instruction 指令
    output reg [31:0] imm_out
);
    always @(*) begin
        case(instr[6:0])
            //ADDI指令
            7'b0010011: begin
                imm_out = {{20{instr[31]}}, instr[31:20]};
            //其他指令待补充
            end
        endcase
    end
endmodule

//指令存储器 IF
module inst_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    // 1. 定义存储器数组：1024个位置，每个位置32位宽
    reg [31:0] imem_array [0:1023];

    // 2. 初始化：加载外部文件
    initial begin
        // "code.hex" 是文件名
        // imem_array 是目标数组
        $readmemh("code.hex", imem_array);
    end

    // 3. 读取逻辑
    // 关键点：PC地址是字节寻址 (0, 4, 8, 12...)
    // 但数组索引是 (0, 1, 2, 3...)
    // 所以由于 4字节=1字，我们需要将地址除以4 (即右移2位)
    assign instr = imem_array[addr[31:2]];

endmodule

//寄存器堆 ID
module reg_file (
    input  wire clk,
    input  wire we,            // 写使能 (Write Enable)
    input  wire [4:0] raddr1,  // 读地址1 (rs1)
    input  wire [4:0] raddr2,  // 读地址2 (rs2)
    input  wire [4:0] waddr,   // 写地址 (rd)
    input  wire [31:0] wdata,  // 写数据
    output wire [31:0] rdata1, // 读数据1
    output wire [31:0] rdata2  // 读数据2
);
    reg [31:0] reg_file [0:31];
    assign rdata1 = reg_file[raddr1];
    assign rdata2 = reg_file[raddr2];

    always @(posedge clk) begin
        if(we && (waddr != 5'b00000)) begin
            reg_file[waddr] <= wdata;
        end
    end
endmodule

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

    // MEM (访存) 阶段信号
    wire [31:0] dmem_rdata

    // WB (写回) 阶段信号
    wire  [31:0] final_wdata;  // 最终写回寄存器的数据

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
        .wdata  (final_wdata),     // 连接MUX输出
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

    // --- [MEM 阶段]: 数据存储器 ---

    data_mem u_data_mem (
        .clk   (clk),
        .we    (mem_write),     // 新增控制信号：是否写内存
        .addr  (alu_result),    // 内存地址来自 ALU 计算结果 (例如 0(x1))
        .wdata (rdata2),        // 要写入的数据来自 rs2
        .rdata (dmem_rdata)     // 读出的数据
    );

    // --- [WB 阶段]: 写回 MUX ---
    // 如果是 LW 指令(mem_to_reg=1)，选内存数据；否则(ADD/ADDI)选 ALU 结果
    assign final_wdata = (mem_to_reg) ? dmem_rdata : alu_result;

endmodule

package config_pkg;
//ALU运算选择
    parameter ADD  = 4'd0;
    parameter SUB  = 4'd1; 
    parameter AND  = 4'd2;
    parameter OR   = 4'd3;
    parameter XOR  = 4'd4; // 按位异或
    parameter SLL  = 4'd5;
    parameter SRL  = 4'd6;
    parameter SRA  = 4'd7;
    parameter SLT  = 4'd8;
    parameter SLTU = 4'd9;
    parameter PASS = 4'd10;
    //ALU输入源选择
    parameter REG = 1'b0;
    parameter IMM = 1'b1;
    //写入数据选择
    parameter ALU_result = 2'b00;
    parameter MEM_result = 2'b01;
    parameter PC_plus4   = 2'b10;
endpackage