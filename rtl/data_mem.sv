//内存模块
module data_mem (
    input wire clk,
    input wire we,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] ram [0:1023];
    assign rdata = ram[addr[31:2]];
    always @(posedge clk)begin
        if (we) begin
            ram[addr[31:2]] <= wdata;
        end
    end
endmodule