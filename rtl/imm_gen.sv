//Immediate Generator 立即数生成器,扩展功能 ID
module imm_gen (
    input wire [31:0] instr, //Instruction 指令
    output reg [31:0] imm_out
);
    always @(*) begin
        case(instr[6:0])
            // I-type (ADDI, LW, JALR)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end
            // SW指令
            7'b0100011: begin
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end
            // B-type (BEQ, BNE)
            7'b1100011: begin
                  imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            // J-type (JAL)
            7'b1101111: begin
                imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            end
            // default
            default: begin
                imm_out = 32'b0;
            end
        endcase
    end
endmodule

