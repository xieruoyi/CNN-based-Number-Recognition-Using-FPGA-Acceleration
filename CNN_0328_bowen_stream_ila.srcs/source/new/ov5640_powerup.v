`timescale 1ns / 1ps


module ov5640_powerup(
    output o_reset,
    output o_pwdn
    );
    
    assign o_reset = 1'b1;
    assign o_pwdn = 1'b0;
    
endmodule
