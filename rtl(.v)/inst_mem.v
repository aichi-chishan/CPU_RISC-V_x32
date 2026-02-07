//指令存储器 IF
module inst_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    // 1. 定义存储器数组：1024个位置，每个位置32位宽
    reg [31:0] imem_array [0:1023];

    // 2. 初始化：加载外部文件
    initial begin
        // "code.hex" 是文件名
        // imem_array 是目标数组
        $readmemh("code.hex", imem_array);
    end

    // 3. 读取逻辑
    // 关键点：PC地址是字节寻址 (0, 4, 8, 12...)
    // 但数组索引是 (0, 1, 2, 3...)
    // 所以由于 4字节=1字，我们需要将地址除以4 (即右移2位)
    assign instr = imem_array[addr[31:2]];

endmodule
/*
module inst_mem(
    input wire [31:0] addr,//from PC
    output reg [31:0] instr //32位机器码
);

    always @(*) begin
        case(addr)
            // 地址 0：第一条指令 (ADDI x1, x0, 10)
            32'h00000000: instr = 32'h00a00093;
            // 地址 4：第二条指令 (ADDI x2, x0, 20)
            32'h00000004: instr = 32'h01400113;
            // 地址 8：第三条指令 (ADD x3, x1, x2)
            32'h00000008: instr = 32'h002081b3;
            // 如果PC跑到了其他地址，输出0（空指令NOP），防止乱码
            default:      instr = 32'h00000000;
        endcase
    end
endmodule
*/    