module grayscale_bram #(
    parameter DATA_WIDTH = 8,
    parameter FRAME_SIZE = 784 // 28x28
)
 (  

    // system signal
    input clk,
    input arstn,

    // from the grayscale
    input i_valid,
    input i_start_frame,
    input conv_working,
    input [DATA_WIDTH-1 : 0] i_data,

    // to the CNN
    output reg o_frame_ready,
    input [4:0] i_row_addr,
    input [4:0] i_col_addr,
    output wire [79 : 0] o_data

);

reg [DATA_WIDTH-1 : 0] bram [0 : FRAME_SIZE-1];
reg [9 : 0] counter;

reg [DATA_WIDTH-1 : 0] index_data0;
reg [DATA_WIDTH-1 : 0] index_data1;
reg [DATA_WIDTH-1 : 0] index_data2;
reg [DATA_WIDTH-1 : 0] index_data3;
reg [DATA_WIDTH-1 : 0] index_data4;

assign o_data = {8'h00, index_data4, 8'h00, index_data3, 8'h00, index_data2,  8'h00,index_data1, 8'h00, index_data0};


// counter logic
always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        counter <= 'd0;
        o_frame_ready <= 1'b0;
    end
    else begin
        if (i_start_frame == 1'b1) begin
            counter <= 'd0;
            o_frame_ready <= 1'b0;
        end
        else if (counter == 'd783) begin
            counter <= 'd0;
            o_frame_ready <= 1'b1;
        end
        else if (i_valid) begin
            counter <= counter + 1;
            o_frame_ready <= 1'b0;
        end
        else 
            o_frame_ready <= 1'b0;
    end
end

// storing grayscale logic
always @(posedge clk) begin
    if (i_valid) begin
        bram[counter] <= i_data;
    end
end

// output to CNN logic
always @(posedge clk or negedge arstn) begin
    if (!arstn) begin
        index_data0 <= 'd0;
        index_data1 <= 'd0;
        index_data2 <= 'd0;
        index_data3 <= 'd0;
        index_data4 <= 'd0;
    end
    else begin
    if (conv_working) begin 
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
end


endmodule