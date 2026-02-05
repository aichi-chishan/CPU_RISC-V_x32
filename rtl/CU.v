//control unit 控制单元 ID
module CU(
    input  wire [6:0] opcode,  // 指令[6:0]
    input  wire [2:0] funct3,  // 指令[14:12]
    input  wire [6:0] funct7,  // 指令[31:25]
    output reg        we,       // 寄存器写使能
    output reg        alu_src,  // ALU输入源选择 (0:寄存器, 1:立即数)
    output reg  [3:0] alu_ctrl  // 告诉ALU做什么运算 (加/减) 加0000 减0001
);
    always @(*) begin

        //AI说少了默认状态定义

        case(opcode)
            //R型
            7'b0110011:begin
                case(funct3)
                    //ADD和SUB
                    3'b000:begin
                        case(funct7)
                            //ADD
                            7'b0000000: begin
                                we = 1'b1;
                                alu_src = 1'b0;
                                alu_ctrl = 4'b0000;
                            end
                            //SUB
                            7'b0100000: begin
                                we = 1'b1;
                                alu_src = 1'b0;
                                alu_ctrl = 4'b0001;
                            end
                        endcase
                    end
                endcase
            end
            //I型
            7'b0010011:begin
                case(funct3)
                //ADDI
                    3'b000: begin
                        we = 1'b1;
                        alu_src = 1'b1;
                        alu_ctrl = 4'b0000;
                   end
                endcase
            end
        endcase
    end
endmodule

/*

module CU(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        we,       // reg 类型用于 always 块赋值
    output reg        alu_src,
    output reg  [3:0] alu_ctrl
);

    always @(*) begin
        // 1. 推荐：设置默认值，防止生成锁存器(Latch)
        we = 1'b0;
        alu_src = 1'b0;
        alu_ctrl = 4'b0000;

        case(opcode)
            // R型
            7'b0110011: begin
                case(funct3)
                    // ADD和SUB
                    3'b000: begin
                        case(funct7)
                            // ADD
                            7'b0000000: begin
                                we = 1'b1;
                                alu_src = 1'b0;
                                alu_ctrl = 4'b0000;
                            end
                            // SUB
                            7'b0100000: begin
                                we = 1'b1;
                                alu_src = 1'b0;
                                alu_ctrl = 4'b0001;
                            end
                        endcase
                    end
                endcase
            end
            
            // I型
            7'b0010011: begin  // <--- 修正了这里：添加了 'b'
                case(funct3)
                    // ADDI
                    3'b000: begin // <--- 修正了这里：由 7'b000 改为 3'b000
                        we = 1'b1;
                        alu_src = 1'b1; // <--- 修正了这里：ADDI 需要立即数，改为 1
                        alu_ctrl = 4'b0000;
                    end
                endcase
            end
        endcase
    end
endmodule

*/

 