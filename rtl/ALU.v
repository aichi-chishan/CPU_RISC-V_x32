//ALU EX
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
