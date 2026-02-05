//寄存器堆 ID
module reg_file (
    input  wire clk,
    input  wire we,            // 写使能 (Write Enable)
    input  wire [4:0] raddr1,  // 读地址1 (rs1)
    input  wire [4:0] raddr2,  // 读地址2 (rs2)
    input  wire [4:0] waddr,   // 写地址 (rd)
    input  wire [31:0] wdata,  // 写数据
    output wire [31:0] rdata1, // 读数据1
    output wire [31:0] rdata2  // 读数据2
);
    reg [31:0] reg_file [0:31];
    assign rdata1 = reg_file[raddr1];
    assign rdata2 = reg_file[raddr2];

    always @(posedge clk) begin
        if(we && (waddr != 5'b00000)) begin
            reg_file[waddr] <= wdata;
        end
    end
endmodule