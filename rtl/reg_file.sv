//寄存器堆 ID
module reg_file (
    //一次写只能写一个，读可以读两个
    input  wire clk,
    input  wire we,            // 写使能 (Write Enable)
    input  wire [4:0] raddr1,  // 读地址1 (rs1)，地址的数据从底下的output出去
    input  wire [4:0] raddr2,  // 读地址2 (rs2)，地址的数据从底下的output出去
    input  wire [4:0] waddr,   // 写地址 (rd)
    input  wire [31:0] wdata,  // 写数据
    output wire [31:0] rdata1, // 读数据1
    output wire [31:0] rdata2  // 读数据2
);
    reg [31:0] regs [0:31];

    // RISC-V 规范：x0 寄存器必须恒为 0
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : regs[raddr2];

    always @(posedge clk) begin
        if(we && (waddr != 5'b00000)) begin
            regs[waddr] <= wdata;
        end
    end
endmodule