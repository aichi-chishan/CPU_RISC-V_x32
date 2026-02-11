//程序计数器 IF
module PC( 
    input wire clk,
    input wire rst_n,
    input wire [31:0] branch_target, // 来自 EX 阶段的跳转目标地址
    input wire pc_src, // 来自 EX 阶段的跳转控制信号
    input wire stall, // 来自 Hazard Unit 的流水线暂停信号
    output reg [31:0] current_pc_out // 输出当前 PC 值
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_pc_out <= 32'h00000000;    
        end else if(stall) begin
            current_pc_out <= current_pc_out; // 保持当前 PC 不变
        end else if(pc_src) begin
            current_pc_out <= branch_target; // 跳转到目标地址
        end else begin
            current_pc_out <= current_pc_out + 32'h00000004;
        end
    end
    
    
endmodule