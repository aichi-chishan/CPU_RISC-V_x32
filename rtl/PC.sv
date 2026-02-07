//程序计数器 IF
import config_pkg::*;

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
/*
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
*/
    end


endmodule