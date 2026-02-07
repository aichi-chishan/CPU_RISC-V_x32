module id_ex_reg(
    input wire clk, reset,
    // 数据输入
    input wire [31:0] id_pc, id_rdata1, id_rdata2, id_imm,
    input wire [4:0]  id_rd,
    // 控制信号输入
    input wire id_reg_we, id_mem_we, id_alu_src, 
    input wire [3:0] id_alu_ctrl,
    // ... 其他信号

    // 输出到 EX 阶段
    output reg [31:0] ex_pc, ex_rdata1, ex_rdata2, ex_imm,
    output reg [4:0]  ex_rd,
    output reg ex_reg_we, ex_mem_we, ex_alu_src,
    output reg [3:0] ex_alu_ctrl
);
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // 清零所有输出
            ex_pc <= 0; ex_reg_we <= 0; /*...*/
        end else begin
            // 传递数据
            ex_pc <= id_pc;
            ex_rdata1 <= id_rdata1;
            // ...
        end
    end
endmodule