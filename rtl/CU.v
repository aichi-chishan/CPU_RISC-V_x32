//control unit 控制单元 ID
/* 
    各类型指令集介绍CSDN
    https://blog.csdn.net/qq_70829439/article/details/129565365
    各指令名称讲解
    https://zhuanlan.zhihu.com/p/660618400
    opcade > funct3 > funct7
*/
module CU(
    input  wire [6:0] opcode,   // 指令[6:0]
    input  wire [2:0] funct3,   // 指令[14:12]
    input  wire [6:0] funct7,   // 指令[31:25]

    output reg        reg_we,   // 寄存器写使能
    output reg        mem_we,   // 内存写使能
    output reg        alu_src,  // ALU输入源选择
    
    output reg        branch,
    output reg        jump,

    output reg  [3:0] alu_ctrl  // ALU运算方式
);
    //ALU运算选择
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
    parameter PASS = 4'd10;
    //ALU输入源选择
    parameter REG = 1'b0;
    parameter IMM = 1'b1;

    //=========================
    // Control logic
    //=========================

    always @(*) begin
        //默认状态定义
        reg_we   = 1'b0;
        mem_we   = 1'b0;
        alu_src  = REG;
        branch   = 1'b0;
        jump     = 1'b0;
        alu_ctrl = ADD;

        case(opcode)

            //========================= 
            // R-type 寄存器指令
            // opcode = 0110011 
            //=========================

            7'b0110011:begin

                reg_we = 1'b1;
                alu_src = REG;

                case(funct3)
                    
                    3'b000:begin
                        case(funct7)
                            7'b0000000: alu_ctrl = ADD;
                            7'b0100000: alu_ctrl = SUB;
                        endcase
                    end
                    3'b111: alu_ctrl = AND; 
                    3'b110: alu_ctrl = OR; 
                    3'b100: alu_ctrl = XOR; 
                    3'b001: alu_ctrl = SLL;
                    3'b101:begin
                        case(funct7)
                            7'b0000000: alu_ctrl = SRL;
                            7'b0100000: alu_ctrl = SRA;
                        endcase
                    end
                    3'b010: alu_ctrl = SLT; 
                    3'b011: alu_ctrl = SLTU;

                endcase
            end

            //========================= 
            // I-type 立即数算术运算
            // opcode = 0010011 
            //=========================

            7'b0010011:begin

                reg_we = 1'b1; 
                alu_src = IMM;

                case(funct3)
                    3'b000: alu_ctrl = ADD;  // ADDI 
                    3'b111: alu_ctrl = AND;  // ANDI 
                    3'b110: alu_ctrl = OR;   // ORI 
                    3'b100: alu_ctrl = XOR;  // XORI 
                    3'b010: alu_ctrl = SLT;  // SLTI 
                    3'b011: alu_ctrl = SLTU; // SLTIU 
                    3'b001: alu_ctrl = SLL;  // SLLI

                    3'b101: case(funct7) 
                        7'b0000000: alu_ctrl = SRL; // SRLI 
                        7'b0100000: alu_ctrl = SRA; // SRAI
                    endcase
                endcase
            end

            //========================= 
            // S-type 存储到内存 Store
            // opcode = 0100011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            //=========================

            7'b0100011:begin

                mem_we = 1'b1; 
                alu_src = IMM; 
                alu_ctrl = ADD;

            end

                /*
                case(funct3)
                    //SW Store Word 存储字
                    3'b010:begin
                        reg_we = 1'b0;
                        mem_we = 1'b1;
                        alu_src = 1'b1;
                        alu_ctrl = 4'b0000;//ADD
                    end
                    //SH Store Halfword 存储半字
                    3'b001:begin

                    end
                    //SB Store Byte 存储字节
                    3'b000:begin

                    end
                */

                endcase
            end
            //========================= 
            // L-type 载入寄存器 Load
            // opcode = 0000011 
            // 对内存的读写只能通过LOAD 和 STORE 指令实现
            //=========================

            7'b0000011:begin
                
                reg_we = 1'b1;
                alu_src = IMM;
                alu_ctrl = ADD;

                /*
                case(func3)
                    //LW Load Word 加载字（32位）
                    3'b010:begin
                        reg_we = 1'b1;
                        mem_we = 1'b0;
                        alu_src = 1'b1;
                        alu_ctrl = 4'b0000;//ADD
                    end
                    //LH Load Halfword 加载半字（有符号扩展）

                    //LB Load Byte  加载字节（有符号扩展）
                endcase
                */
            end
//B型还得细分
            //========================= 
            // B-type 条件分支指令 Branch
            // opcode = 1100011 
            //=========================

            7'b1100011: begin
                branch = 1'b1; 
                alu_src = REG; 
                alu_ctrl = SUB;
            end
//PC模块可能得改
            //========================= 
            // JAL 
            // opcode = 1101111 
            //=========================

            7'b1101111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
            end

            //========================= 
            // JALR 
            // opcode = 1100111 
            //========================= 
            7'b1100111: begin 
                reg_we = 1'b1; 
                jump = 1'b1; 
                alu_src = IMM; 
                alu_ctrl = ADD; 
            end

            //B型
            7'b1100011

            //deafult
            deafult:
        endcase
    end
endmodule



 