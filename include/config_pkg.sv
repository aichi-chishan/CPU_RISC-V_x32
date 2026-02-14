package config_pkg;
/*
import config_pkg::*;
*/
    //ALU运算选择 alu_ctrl
    typedef enum logic [3:0] { 
        ADD ,
        SUB ,
        AND ,
        OR  ,
        XOR , // 按位异或
        SLL ,
        SRL ,
        SRA ,
        SLT ,
        SLTU,
        PASS
     } alu_ctrl_t;

    //ALU输入源选择 alu_src
    typedef enum logic { 
        REG ,
        IMM
    } alu_src_t;

    //写入数据选择 wd_sel
    typedef enum logic [1:0] { 
        ALU_result ,
        MEM_result ,
        PC_plus4 
    } wd_sel_t;

endpackage
