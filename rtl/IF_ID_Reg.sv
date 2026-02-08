module if_id_reg(
    input  wire clk,
    input  wire rst_n,
    
    // 控制信号
    input  wire stall,      // 暂停：保持输出不变 (用于 Load-Use Hazard)
    input  wire flush,      // 冲刷：清空输出 (用于 Branch/Jump)
    
    // 来自 IF 阶段的输入
    input  wire [31:0] if_pc,
    input  wire [31:0] if_instr,
    
    // 输出到 ID 阶段
    output reg  [31:0] id_pc,
    output reg  [31:0] id_instr
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc    <= 32'b0;
            id_instr <= 32'b0; // 0x00000000 是 NOP 指令 (addi x0, x0, 0)
            /*更严谨是 
            id_instr <= 32'h00000013;
            */
        end
        else if (flush) begin
            // 冲刷：将指令变为 NOP，PC 清零或保持
            id_pc    <= 32'b0; 
            id_instr <= 32'b0; 
        end
        else if (stall) begin
            // 暂停：保持当前值不变（相当于不采样新数据）
            id_pc    <= id_pc;
            id_instr <= id_instr;
        end
        else begin
            // 正常流动
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end

endmodule