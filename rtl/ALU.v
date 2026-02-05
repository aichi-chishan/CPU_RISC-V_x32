//ALU EX
module ALU (
    input  wire [31:0] src_a,   // 操作数 A
    input  wire [31:0] src_b,   // 操作数 B
    input  wire [3:0]  alu_ctrl,// 运算控制信号
    output reg  [31:0] result,  // 运算结果
    output wire        zero     // 结果是否为0 (分支指令用，当前可留空)
);
    always @(*) begin
        case(alu_ctrl)
            4'b0000:begin
                result = src_a + src_b;
            end
            4'b0001:begin
                result = src_a - src_b;
            end
            //更多功能待补充
            default: begin
                result = 32'b0;  // 默认值
            end
        endcase
    end
    assign zero = (result == 32'b0);
endmodule
