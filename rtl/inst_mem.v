//指令存储器 IF
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
    
//test