//control unit 控制单元 ID
/* 
    各类型指令集介绍CSDN
    https://blog.csdn.net/qq_70829439/article/details/129565365
    各指令名称讲解
    https://zhuanlan.zhihu.com/p/660618400
    opcade > funct3 > funct7
*/
import config_pkg::*;

module CU(
    input  wire [6:0] opcode,   // 指令[6:0]
    input  wire [2:0] funct3,   // 指令[14:12]
    input  wire [6:0] funct7,   // 指令[31:25]

    output reg        reg_we,   // 寄存器写使能
    output reg        mem_we,   // 内存写使能
    output reg        alu_src,  // ALU输入源选择
    
    output reg        branch,   // 分支信号
    output reg        jump,     // 跳转信号

    output reg  [3:0] alu_ctrl, // ALU运算方式
    output reg  [1:0] wd_sel    // 写入数据来自何方 write_data_select
    //wd_sel 的作用:wd_sel 控制的是写回数据多路选择器 (Write Back Mux)，决定了是把 ALU 的结果、内存的数据还是 PC+4 写回到目标寄存器 (rd) 中。
);


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

// R-type 寄存器指令
            // opcode = 0110011 
            7'b0110011:begin

                reg_we = 1'b1;
                alu_src = REG;
                wd_sel = ALU_result;

                case(funct3)                   
                    3'b000:begin
                        case(funct7)
                            7'b0000000: alu_ctrl = ADD;
                            7'b0100000: alu_ctrl = SUB;
                            default: alu_ctrl = ADD;
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
                            default: alu_ctrl = SRL;
                        endcase
                    end
                    3'b010: alu_ctrl = SLT; 
                    3'b011: alu_ctrl = SLTU;
                    default: alu_ctrl = ADD;
                endcase
            end


// I-type 立即数算术运算
            // opcode = 0010011 
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
                    default: alu_ctrl = ADD;
                endcase
            end


// S-type 存储到内存 Store
            // opcode = 0100011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            7'b0100011:begin

                mem_we = 1'b1; 
                alu_src = IMM; 
                alu_ctrl = ADD;

            end
          

// L-type 载入寄存器 Load
            // opcode = 0000011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            7'b0000011:begin
                
                reg_we = 1'b1;
                alu_src = IMM;
                alu_ctrl = ADD;
                wd_sel = MEM_result;

            end

// B-type 条件分支指令 Branch
            // opcode = 1100011 
            7'b1100011: begin
                branch = 1'b1; 
                alu_src = REG; 
                case(funct3)
                    3'b000: alu_ctrl = SUB;
                    3'b001: alu_ctrl = SUB;
                    3'b100: alu_ctrl = SLT;
                    3'b101: alu_ctrl = SLT;
                    3'b110: alu_ctrl = SLTU;
                    3'b111: alu_ctrl = SLTU;
                    default: alu_ctrl = SUB;
                endcase
            end

// JAL 
            // opcode = 1101111 
            7'b1101111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
                alu_src = IMM;
                wd_sel = PC_plus4;
            end

// JALR 
            // opcode = 1100111 
            7'b1100111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
                alu_src = IMM; 
                wd_sel = PC_plus4;
            end

// default 
            default:begin
                reg_we = 1'b0;
            end
        endcase
    end
endmodule



 