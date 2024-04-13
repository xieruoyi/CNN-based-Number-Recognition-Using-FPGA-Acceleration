`timescale 1ns/1ps
module grayscale_bram_freeze #(
    parameter DATA_WIDTH = 8,
    parameter FRAME_SIZE = 784 // 28x28
)
 (  

    // system signal
    input clk,
    input arstn,
//    input i_en,

    // from the grayscale
    input i_valid,
    input i_start_frame,
    input [DATA_WIDTH-1 : 0] i_data,

    // to the CNN
    output reg o_frame_ready,
    input [4:0] i_row_addr,
    input [4:0] i_col_addr,
    input i_conv_working,
    output wire [79 : 0] o_data

);

reg [DATA_WIDTH-1 : 0] bram [0 : FRAME_SIZE-1];
reg [9 : 0] counter, next_cnt;
reg [DATA_WIDTH-1 : 0] index_data0;
reg [DATA_WIDTH-1 : 0] index_data1;
reg [DATA_WIDTH-1 : 0] index_data2;
reg [DATA_WIDTH-1 : 0] index_data3;
reg [DATA_WIDTH-1 : 0] index_data4;

// allows new pixel to store
reg store_en;

// enable posedge capture
//reg en_reg;
//wire en_posedge;
//always @ (posedge clk or negedge arstn) begin
//    if (!arstn)
//        en_reg <= 1'b0;
//    else
//        en_reg <= i_en;
//end
//assign en_posedge = ~i_en & en_reg;

// state machine
//localparam s_IDLE = 2'b00;
localparam s_ACTIVE = 2'b00;
localparam s_STORING = 2'b01;
localparam s_END = 2'b10;

reg [1:0] current_state, next_state;
always @(posedge clk or negedge arstn) begin
    if (!arstn)
        current_state <= s_ACTIVE;
    else 
        current_state <= next_state;
end

always @(*) begin
    case (current_state)
    
//    s_IDLE : begin
//        store_en = 1'b0;
//        o_frame_ready = 1'b0;
//        next_cnt = 'd0;
//        if (en_posedge)
//            next_state = s_ACTIVE;
//        else
//            next_state = s_IDLE;
//    end

    s_ACTIVE : begin
        store_en = 1'b0;
        o_frame_ready = 1'b0;
        if (i_start_frame) begin
            next_cnt = 'd0;
            next_state = s_STORING;
        end
        else begin
            next_cnt = counter;
            next_state = s_ACTIVE;
        end
    end

    s_STORING : begin
        
        o_frame_ready = 1'b0;
        if (counter == 'd784) begin
            next_state = s_END;
            next_cnt = 'd0;
            store_en = 1'b0;
        end
        else if (i_valid) begin
            store_en = 1'b1;
            next_state = s_STORING;
            next_cnt = counter + 1;
        end
        else begin
            store_en = 1'b0;
            next_state = s_STORING;
            next_cnt = counter;
        end
    end

    s_END : begin
        o_frame_ready = 1'b1;
        next_cnt = 'd0;
        store_en = 1'b0;
//        if (en_posedge)
        next_state = s_ACTIVE;
//        else
//            next_state = s_END;
    end
    
    default : begin
        o_frame_ready = 1'b0;
        next_cnt = 'd0;
        store_en = 1'b0;
        next_state = s_ACTIVE;
    end

    endcase
end

// storing grayscale logic
always @(posedge clk) begin
    if (i_valid && store_en) begin
        bram[counter] <= i_data;
    end
end

always @(posedge clk or negedge arstn) begin
    if (!arstn)
        counter <= 'd0;
    else 
        counter <= next_cnt;
end

assign o_data = {8'h00, index_data4, 8'h00, index_data3, 8'h00, index_data2, 8'h00, index_data1, 8'h00, index_data0};

// output to CNN logic
always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        index_data0 <= 'd0;
        index_data1 <= 'd0;
        index_data2 <= 'd0;
        index_data3 <= 'd0;
        index_data4 <= 'd0;
    end
    else if (i_conv_working) begin
        if (i_row_addr < 'd24 && i_col_addr < 'd28) begin
            index_data0 <= bram[i_row_addr*28 + i_col_addr];
            index_data1 <= bram[(i_row_addr+1)*28 + i_col_addr];
            index_data2 <= bram[(i_row_addr+2)*28 + i_col_addr];
            index_data3 <= bram[(i_row_addr+3)*28 + i_col_addr];
            index_data4 <= bram[(i_row_addr+4)*28 + i_col_addr];
        end
        else begin
            index_data0 <= 'd0;
            index_data1 <= 'd0;
            index_data2 <= 'd0;
            index_data3 <= 'd0;
            index_data4 <= 'd0;
        end
    end
end
endmodule