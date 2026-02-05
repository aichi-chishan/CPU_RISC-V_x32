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

