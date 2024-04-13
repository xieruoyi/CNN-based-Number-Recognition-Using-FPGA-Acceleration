`timescale 1ns / 1ps

module capture_to_vdma(

    // input from the capture
    input [23:0] i_data,
    input i_valid,
    input i_last,
//    input i_href,
//    input i_vsync,
    
    // interface with VDMA
    output [31:0] o_tdata,
    output [3:0] o_tkeep,
    output o_tlast,
//    input i_tready,
    output o_tuser,
    output o_tvalid
    );
    
    assign o_tdata = {8'b0, i_data};
    assign o_tkeep = 4'b1111;
    assign o_tuser = 1'b1;
    assign o_tlast = i_last;
    assign o_tvalid = i_valid;
    
endmodule
