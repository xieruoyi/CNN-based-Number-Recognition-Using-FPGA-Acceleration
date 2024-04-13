`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 03:40:33 PM
// Design Name: 
// Module Name: conv2_pu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module conv2_pu # (
    parameter DATA_WIDTH   = 16,
    parameter WEIGHT_WIDTH = 16,
    parameter KERNEL_SIZE  = 5,
    parameter KERNEL_INC   = 4,
    parameter KERNEL_OUTC  = 4
)(

    input clk,
    input reset,


    // data and param access

    input [5*DATA_WIDTH - 1 : 0] col_data_inC0,          // takes in one column of the data matching kernel size 
    input [5*DATA_WIDTH - 1 : 0] col_data_inC1,   
    input [5*DATA_WIDTH - 1 : 0] col_data_inC2,   
    input [5*DATA_WIDTH - 1 : 0] col_data_inC3,   

    // first layer weight bram length: 5 * 8 = 40 , 6 bit address
    input [5*WEIGHT_WIDTH - 1:0] col_weight_inC0,      // kernel data enter also per column basis
    input [5*WEIGHT_WIDTH - 1:0] col_weight_inC1, 
    input [5*WEIGHT_WIDTH - 1:0] col_weight_inC2, 
    input [5*WEIGHT_WIDTH - 1:0] col_weight_inC3,
     
    input [WEIGHT_WIDTH - 1 : 0] kernel_bias_inC,     // bias for the kernel, this should arrive at same time as 5th col of weight , thus no need to latch


    // control signals 
    input conv2_start,
    output reg conv_started,
    output [5:0] data_addr_col_out,
    output [4:0] data_addr_row_out,

    output [5:0] weight_addr_col_out,
    output [4:0] kernel_count_out,

    output [2*DATA_WIDTH - 1 + 7:0] output_data_act,
    output output_valid



    );
    ////////////////////////////////////////
    // wires and regs definition 
    ////////////////////////////////////////

    localparam inC_size = 12 ;
    localparam col_overhead = 1 + 5 + 4; 
    // start flag overhead + data read overhead + computation overhead
    localparam col_cycle_total = inC_size - KERNEL_SIZE + col_overhead; // dont forget to -1 in indexing


    integer i,j;
        // data addressing 
    reg [5:0] data_addr_col;
    reg [4:0] data_addr_row;

    // kernel col addressing 
    reg [3:0] kernel_count;
    reg [5:0] weight_addr_col;

        // kernel reg
    reg [5*WEIGHT_WIDTH - 1: 0 ] kernel_reg [KERNEL_INC-1:0][KERNEL_SIZE - 1:0];
    reg [WEIGHT_WIDTH -1 : 0 ] kernel_bias_reg [KERNEL_INC-1:0];

        // data pipeline column reg 
    reg [5*DATA_WIDTH - 1: 0] data_col_r0[KERNEL_INC-1:0];
    reg [5*DATA_WIDTH - 1: 0] data_col_r1[KERNEL_INC-1:0];
    reg [5*DATA_WIDTH - 1: 0] data_col_r2[KERNEL_INC-1:0];
    reg [5*DATA_WIDTH - 1: 0] data_col_r3[KERNEL_INC-1:0];
    reg [5*DATA_WIDTH - 1: 0] data_col_r4[KERNEL_INC-1:0];


    // output of in channels and final out data  (+7 because sum of 100 values)
    wire signed [2 * DATA_WIDTH - 1 + 5:0] output_data_inC[KERNEL_INC-1:0];
    reg signed [2 * DATA_WIDTH - 1 + 5:0] output_data_inC_reg[KERNEL_INC-1:0];
    reg signed [2 * DATA_WIDTH - 1 + 7:0] output_data_outC_reg;
    reg output_valid_reg;

     
    //////////////////////////////////////// 
    // logic starts here 
    ////////////////////////////////////////

 
    
    assign data_addr_col_out = data_addr_col;
    assign data_addr_row_out = data_addr_row;
    assign weight_addr_col_out = weight_addr_col;
    assign kernel_count_out = kernel_count;


    // raise working flag when conv starts
    always @(posedge clk ) begin 
        if ( reset ) begin 
            conv_started <= 'b0;
        end

        else begin 
            if (kernel_count == KERNEL_OUTC) begin 
                conv_started <= 'b0;
            end
            else if ( conv2_start) begin 
                conv_started <= 'b1;
            end

        end

        // also need to reset working flag once conv is done

    end


    // kernel count for number of convolutions done 

    always @(posedge clk ) begin 
        if (reset) begin 
            kernel_count <= 0;
        end

        else begin 
            if(conv_started == 'b0) begin 
                kernel_count <= 0;
            end
            // + 1 buffer cycle to wait last output to be ready
            else if ( conv_started && data_addr_col == col_cycle_total -1 + 1  
                && data_addr_row == inC_size - KERNEL_SIZE ) begin 
                kernel_count <= kernel_count + 1;
            end

        end
    end

    // enable address count 
    
    always @(posedge clk) begin 
        if (reset)
            data_addr_row <= 0;
        else begin 
            if (conv_started 
                && data_addr_row == inC_size - KERNEL_SIZE
                && data_addr_col == col_cycle_total - 1 + 1)
                data_addr_row <= 0;
                
            else if (conv_started 
                && data_addr_col == col_cycle_total - 1 + 1)
                data_addr_row <= data_addr_row + 1; 
        end
    
    
    end
    always @(posedge clk ) begin 
        if (reset) begin 
            data_addr_col <= 0;
        end

        else begin
            if ( conv_started && data_addr_col == col_cycle_total - 1 + 1 ) begin 
                data_addr_col <= 0;
            end
             
            else if (conv_started) begin 
                data_addr_col <= data_addr_col + 1;
            end
            else if (~conv_started) 
                data_addr_col <= 'b0;


        end

    end

        // data pipeline
    always @(posedge clk ) begin 
        if (reset) begin 
            for (i = 0; i < KERNEL_INC; i = i + 1) begin
                data_col_r0[i] <= 0;
                data_col_r1[i] <= 0;
                data_col_r2[i] <= 0;
                data_col_r3[i] <= 0;
                data_col_r4[i] <= 0;
            end
        end

        else begin 
            if (conv_started) begin 
            
                data_col_r4[0] <= col_data_inC0;
                data_col_r4[1] <= col_data_inC1;
                data_col_r4[2] <= col_data_inC2;
                data_col_r4[3] <= col_data_inC3;
                for (i = 0; i < KERNEL_INC; i = i + 1) begin
                    data_col_r3[i] <= data_col_r4[i];
                    data_col_r2[i] <= data_col_r3[i];
                    data_col_r1[i] <= data_col_r2[i];
                    data_col_r0[i] <= data_col_r1[i];
                end
            end
        end
    end

    // enable kernel address count
    always@(posedge clk ) begin 
        if (reset) begin 
            weight_addr_col <= 0;
        end

        else begin 
            if (kernel_count == KERNEL_OUTC) begin 
                weight_addr_col <= 0;
            end
            else if (conv_started && data_addr_col <=4 && data_addr_row == 0) begin       // use data_addr_col to see amount to extract
                weight_addr_col <= weight_addr_col + 1;                         // only increment for first few cycles of each kernel iteration 
            end          
        end
    end


    // load kernel param
    always@(posedge clk) begin 
        if (reset) begin 
            for (j = 0; j < KERNEL_INC; j = j + 1 ) begin
                for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
                    kernel_reg[j][i] <= 0;
                end
                kernel_bias_reg[j] <= 0;
            end
        end

        else begin 
            if (conv_started && data_addr_col >= 1 && data_addr_col <= 5 && data_addr_row == 0) begin //from sim needs 2 cycle to get data back in kernel reg 
                for (i = 0; i < KERNEL_SIZE; i = i + 1) begin 
                    // kernel_reg[i] <= {kernel_reg[i][4*weight_width - 1:0], col_weight[i*weight_width+:weight_width]};
                    kernel_reg[0][i] <= {col_weight_inC0[i*WEIGHT_WIDTH+:WEIGHT_WIDTH] ,kernel_reg[0][i][5*WEIGHT_WIDTH - 1:WEIGHT_WIDTH] };
                    kernel_reg[1][i] <= {col_weight_inC1[i*WEIGHT_WIDTH+:WEIGHT_WIDTH] ,kernel_reg[1][i][5*WEIGHT_WIDTH - 1:WEIGHT_WIDTH] };
                    kernel_reg[2][i] <= {col_weight_inC2[i*WEIGHT_WIDTH+:WEIGHT_WIDTH] ,kernel_reg[2][i][5*WEIGHT_WIDTH - 1:WEIGHT_WIDTH] };
                    kernel_reg[3][i] <= {col_weight_inC3[i*WEIGHT_WIDTH+:WEIGHT_WIDTH] ,kernel_reg[3][i][5*WEIGHT_WIDTH - 1:WEIGHT_WIDTH] };

                end
                kernel_bias_reg[0] <= kernel_bias_inC;
                kernel_bias_reg[1] <= 'b0;
                kernel_bias_reg[2] <= 'b0;
                kernel_bias_reg[3] <= 'b0;
                // only one bias per out-channel
                
            end
        end
    end

    genvar cnt;
    generate 
        for (cnt = 0 ; cnt < KERNEL_INC; cnt = cnt + 1) begin : kernel_mult
            kernel_l1_mult #(
                .data_width(DATA_WIDTH),
                .weight_width(WEIGHT_WIDTH)
            ) kernel_mult_inC (
                .clk(clk),
                .reset(reset),
                .col_data_0(data_col_r0[cnt]),
                .col_data_1(data_col_r1[cnt]),
                .col_data_2(data_col_r2[cnt]),
                .col_data_3(data_col_r3[cnt]),
                .col_data_4(data_col_r4[cnt]),
                .row_weights_0(kernel_reg[cnt][0]),
                .row_weights_1(kernel_reg[cnt][1]),
                .row_weights_2(kernel_reg[cnt][2]),
                .row_weights_3(kernel_reg[cnt][3]),
                .row_weights_4(kernel_reg[cnt][4]),
                .kernel_bias(kernel_bias_reg[cnt]),
                .out_data(output_data_inC[cnt]) // flawed, output is not registered internally
            );
        end
    endgenerate

    // output data register: need to be coupled with kernel_mult_inC module output
    // need to pipeline register the outputs outside of kernel module; 
    // sum the output of the inC
    always @(posedge clk) begin 
        if (reset) begin 
            for (i = 0; i < KERNEL_INC; i = i + 1) begin 
                output_data_inC_reg[i] <= 0;
            end
        end
        else begin 
            for (i = 0; i < KERNEL_INC; i = i + 1) begin 
                output_data_inC_reg[i] <= output_data_inC[i];
            end

        end
    end


    always @(posedge clk) begin 
        if (reset) begin 
            output_valid_reg <= 0;
            output_data_outC_reg <= 0;
        end
        else begin 
            if (conv_started && data_addr_col >= /*8*/col_overhead-1 && data_addr_col <= /*31*/col_cycle_total - 1) begin 
                // at posedge, col=5, last col enters register; col=6, kernel weights registered at mult entrance; 
                // col=7, per row kernel mult sum ready; col=8, per in-channel sum output ready; col=9, out-channel sum output ready
                // note for myself cuz im stupid: col_overhead-1 becuz indexing needs to start from 0
                output_data_outC_reg <= output_data_inC_reg[0] + output_data_inC_reg[1] + output_data_inC_reg[2] + output_data_inC_reg[3] ;
                output_valid_reg <= 'b1;

                // `ifndef SYNTHESIS
                // file = $fopen("C:/Users/2000c/ECE532/project/CNN_train/sim_conv1_only_out.csv", "a"); // Open file in append mode
                // if (file) begin
                //     sim_conv1_output_data = output_data_conv ;//>> (15+8-12); // the number after - is the target fractional bit
                //     $fwrite(file, "%d\n", sim_conv1_output_data);
                //     $fclose(file);
                // end

                // `endif 


            end
            else begin 
                output_data_outC_reg <= 'b0;
                output_valid_reg <= 'b0;
            end
        end

    end

    assign output_data_act = (output_data_outC_reg[2*DATA_WIDTH - 1+7] != 1) ? output_data_outC_reg : 0;
    assign output_valid = output_valid_reg;


endmodule
