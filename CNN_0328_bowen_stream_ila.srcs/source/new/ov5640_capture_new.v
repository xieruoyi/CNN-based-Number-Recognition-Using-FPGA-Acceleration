`timescale 1ns / 1ps

module ov5640_capture_new(
    // signals from camera
    input pclk,
    input arstn,
    input i_vsync,
    input i_href,
    input [7:0] i_data,

    // interface with VDMA
    output [31:0] o_tdata,
    output [3:0] o_tkeep,
    output o_tlast,
    input i_tready,
    output o_tuser,
    output o_tvalid
    );
    
    reg [23:0] data_reg;
    reg [1:0] cnt;
    reg href_reg;
    reg we_reg, we_reg2; // write enable
    
    // Create a 'last' pulse on the falling edge of href
    assign o_tlast = ({i_href, href_reg} == 2'b01) ? 1'b1 : 1'b0;
    // Create a 'valid' pulse on the rising edge of write enable
    assign o_tvalid = ({we_reg, we_reg2} == 2'b10) ? 1'b1 : 1'b0;
    assign o_tdata = {8'h00, data_reg};
    assign o_tkeep = 4'b1111;
    assign o_tuser = 1'b1;
    
    always @(posedge pclk or negedge arstn) begin
        if (!arstn) begin
            cnt <= 2'b00;
            data_reg <= 24'd0;
            href_reg <= 1'b0;
            we_reg <= 1'b0;
            we_reg2 <= 1'b0;
        end
        else begin
            href_reg <= i_href;
            we_reg2 <= we_reg;
            
            if (i_vsync) begin
                cnt <= 2'b00;
                we_reg <= 1'b0;
            end
            
            else begin
                if (i_href) begin
                    if (cnt == 2'b10) begin
                        cnt <= 2'b00;
                        we_reg <= 1'b1;
                    end
                    else begin
                        cnt <= cnt + 'd1;
                        we_reg <= 1'b0;
                    end 
                end
                case (cnt)
                    1 : data_reg[23:16] <= i_data;
                    2 : data_reg[15:8] <= i_data;
                    0 : data_reg[7:0] <= i_data;
                endcase
            end
        end 
    end
    
endmodule
