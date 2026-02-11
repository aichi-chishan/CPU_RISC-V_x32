module top (
    input wire clk,
    input wire rst_n
);
    wire [31:0] branch_target_ex; // 来自 EX 阶段的跳转目标地址
    wire pc_src; // 来自 EX 阶段的跳转控制信号
    wire stall; // 来自 Hazard Unit 的流水线暂停信号
    wire [31:0] current_pc; // 当前 PC 值
    
    PC u_PC (
        .clk(clk),
        .rst_n(rst_n),
        .branch_target(branch_target_ex), // 来自 EX 阶段的跳转目标地址
        .pc_src(pc_src), // 来自 EX 阶段的跳转控制信号
        .stall(stall), // 来自 Hazard Unit 的流水线暂停信号
        .current_pc_out(current_pc) // 输出当前 PC 值
    );

    

endmodule