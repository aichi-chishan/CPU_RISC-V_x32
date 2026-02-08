module forwarding_unit (
    // 输入：当前 EX 阶段正在使用的寄存器索引
    input  [4:0] rs1_ex,
    input  [4:0] rs2_ex,
    
    // 输入：流水线后方传回来的写回信息
    input  [4:0] rd_mem,      // MEM 阶段的目标寄存器
    input        reg_write_mem, // MEM 阶段是否写寄存器
    input  [4:0] rd_wb,       // WB 阶段的目标寄存器
    input        reg_write_wb,  // WB 阶段是否写寄存器
    
    // 输出：控制 ALU 输入 Mux 的信号
    // 00: 原值, 10: 来自MEM转发, 01: 来自WB转发
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    // 组合逻辑块
    always @(*) begin
        // ----------------- Forward A (ALU src1) -----------------
        // 默认情况：不转发，使用 ID/EX 寄存器传过来的值
        forward_a = 2'b00;

        // 优先级 1 (最高)：MEM 阶段的最新结果 (EX hazard)
        // 必须满足：正在写寄存器 AND 不是x0寄存器 AND 寄存器号匹配
        if (reg_write_mem && (rd_mem != 5'd0) && (rd_mem == rs1_ex)) begin
            forward_a = 2'b10;
        end
        // 优先级 2：WB 阶段的结果 (MEM hazard)
        // 只有当 MEM 阶段没转发时，才考虑 WB 阶段 (避免双重冲突时用了旧数据)
        else if (reg_write_wb && (rd_wb != 5'd0) && (rd_wb == rs1_ex)) begin
            forward_a = 2'b01;
        end

        // ----------------- Forward B (ALU src2) -----------------
        // 逻辑同上，针对 RS2
        forward_b = 2'b00;

        if (reg_write_mem && (rd_mem != 5'd0) && (rd_mem == rs2_ex)) begin
            forward_b = 2'b10;
        end
        else if (reg_write_wb && (rd_wb != 5'd0) && (rd_wb == rs2_ex)) begin
            forward_b = 2'b01;
        end
    end

endmodule