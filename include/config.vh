package config_pkg;
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
    //写入数据选择
    parameter ALU_result = 2'b00;
    parameter MEM_result = 2'b01;
    parameter PC_plus4   = 2'b10;
endpackage