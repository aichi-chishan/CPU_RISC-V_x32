module hazard_unit (
    // Load-Use 检测所需的输入
    input  [4:0] id_raddr1,       // 正在 ID 阶段解码的源寄存器 1
    input  [4:0] id_raddr2,       // 正在 ID 阶段解码的源寄存器 2
    input  [4:0] ex_rd_addr,        // 上一条指令（在 EX 阶段）的目标寄存器
    input        ex_mem_read,  // EX 阶段是否是 Load 指令 (读取内存)
    
    // 控制冒险检测所需的输入
    input        ex_pc_src,    // EX 阶段决定的跳转信号 (1表示跳转 Taken)
    
    // 输出控制信号
    output reg   stall_pc,     // 冻结 PC
    output reg   stall_if_id,  // 冻结 IF/ID 寄存器
    output reg   flush_if_id,  // 清空 IF/ID (用于跳转)
    output reg   flush_id_ex   // 清空 ID/EX (用于 Load-Use 气泡或跳转)
);

    always @(*) begin
        // --- 默认初始状态 (无冲突) ---
        stall_pc    = 1'b0;
        stall_if_id = 1'b0;
        flush_if_id = 1'b0;
        flush_id_ex = 1'b0;

        // --- 1. Load-Use Hazard (数据加载冒险) ---
        // 如果上一条指令是 Load，且它的目标是当前指令的源操作数
        if (ex_mem_read && ((ex_rd_addr == id_raddr1) || (ex_rd_addr == id_raddr2))) begin
            stall_pc = 1'b1; // 暂停 PC 更新
            stall_if_id = 1'b1; // 暂停 IF/ID 写入
            flush_id_ex = 1'b1; // 将进入 EX 阶段的控制信号清零 (插入 NOP)
        end
        
        // --- 2. Control Hazard (分支跳转冒险) ---
        // 如果 EX 阶段计算出需要跳转
        // 注意：分支的优先级通常覆盖 Load-Use，或者在你的架构中分支只在 EX 决断
        else if (ex_pc_src) begin
            flush_if_id = 1'b1; // 丢弃刚刚取到的指令 (IF 阶段的指令作废)
            flush_id_ex = 1'b1; // 丢弃正在解码的指令 (ID 阶段的指令作废)
        end
    end

endmodule