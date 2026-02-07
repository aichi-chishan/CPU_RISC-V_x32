//程序计数器 IF
module PC( 
    input  wire clk,
    input  wire rst_n,
    input  wire [1:0] wd_sel,
    output reg  [31:0] pc_out,
);

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc_out <= 32'b0;    
        end else begin
            case(wd_sel)begin
                
            end
        end
    end

endmodule