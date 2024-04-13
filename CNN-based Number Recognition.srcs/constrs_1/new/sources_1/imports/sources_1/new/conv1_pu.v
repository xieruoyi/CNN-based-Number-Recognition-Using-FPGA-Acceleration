`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/10/2024 02:03:32 PM
// Design Name: 
// Module Name: conv1_pu
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


module conv1_pu # (
    parameter data_width = 16,
    parameter weight_width =16,
    parameter kernel_size = 5,
    parameter kernel_total_count = 4
)
(
    
    input clk,
    input reset,
    
    
    // data and param access
 
    input [5*data_width - 1 : 0] col_data,          // takes in one column of the data matching kernel size 
    
    
    // first layer weight bram length: 5 * 8 = 40 , 6 bit address
    input [5*weight_width - 1:0] col_weight,      // kernel data enter also per column basis

    input [weight_width - 1 : 0] kernel_bias,     // bias for the kernel, this should arrive at same time as 5th col of weight , thus no need to latch

    // control signals 
    input conv1_start,
    output reg conv_started,
    output [5:0] data_addr_col_out,
    output [4:0] data_addr_row_out,
    
    output [4:0] weight_addr_col_out,
    output [1:0] kernel_count_out,

    output [2*data_width - 1 + 5:0] output_data_act,
    output output_valid
    
    

    );
    ////////////////////////////////////////
    // wires and regs definition 
    ////////////////////////////////////////
    `ifndef SYNTHESIS
        integer file;
    `endif
    // conv starts --> moved to output
//    reg conv_started;


    // data addressing 
    reg [5:0] data_addr_col;
    reg [4:0] data_addr_row;

    // kernel col addressing 
    reg [3:0] kernel_count;
    reg [4:0] weight_addr_col;


    // kernel reg
    reg [5*weight_width - 1: 0 ] kernel_reg [kernel_size - 1:0];
    reg [weight_width -1 : 0 ] kernel_bias_reg;

    // data pipeline column reg 
    reg [5*data_width - 1: 0] data_col_r0;
    reg [5*data_width - 1: 0] data_col_r1;
    reg [5*data_width - 1: 0] data_col_r2;
    reg [5*data_width - 1: 0] data_col_r3;
    reg [5*data_width - 1: 0] data_col_r4;


    // output data reg

    reg [2*data_width - 1 + 5:0] output_data_reg;
    reg output_valid_reg;
    wire [2 * data_width - 1 + 5:0] output_data_conv;

    
    //////////////////////////////////////// 
    // logic starts here 
    ////////////////////////////////////////
    
    assign data_addr_col_out = data_addr_col;
    assign data_addr_row_out = data_addr_row;
    assign weight_addr_col_out = weight_addr_col;
    assign kernel_count_out = kernel_count[1:0];




    // first 5 cycles will be used to load data 
    // 
    always @(posedge clk ) begin 
        if ( reset ) begin 
            conv_started <= 'b0;
        end

        else begin 
            if (kernel_count == kernel_total_count) begin 
                conv_started <= 'b0;
            end
            else if ( conv1_start) begin 
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
            else if ( conv_started && data_addr_col == 'd32 && data_addr_row == 'd23 ) begin 
                kernel_count <= kernel_count + 1;
            end

        end
    end

    // enable address count 
    
    always @(posedge clk) begin 
        if (reset)
            data_addr_row <= 0;
        else begin 
            if (conv_started && data_addr_row == 'd23 && data_addr_col == 'd32)
                data_addr_row <= 0;
                
            else if (conv_started && data_addr_col == 'd32)
                data_addr_row <= data_addr_row + 1; 
        end
    
    
    end
    always @(posedge clk ) begin 
        if (reset) begin 
            data_addr_col <= 0;
        end

        else begin
            if ( conv_started && data_addr_col == 'd32 ) begin 
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
            data_col_r0 <= 0;
            data_col_r1 <= 0;
            data_col_r2 <= 0;
            data_col_r3 <= 0;
            data_col_r4 <= 0;
        end

        else begin 
            if (conv_started) begin 
                data_col_r4 <= col_data;
                data_col_r3 <= data_col_r4;
                data_col_r2 <= data_col_r3;
                data_col_r1 <= data_col_r2;
                data_col_r0 <= data_col_r1;

            end
        end
    end


    // enable kernel address count
    always@(posedge clk ) begin 
        if (reset) begin 
            weight_addr_col <= 0;
        end

        else begin 
            if (kernel_count == kernel_total_count || weight_addr_col == 20) begin 
                weight_addr_col <= 0;
            end
            else if (conv_started && data_addr_col <=4 && data_addr_row == 0) begin       // use data_addr_col to see amount to extract
                weight_addr_col <= weight_addr_col + 1;                         // only increment for first few cycles of each kernel iteration 
            end          
        end
    end

    // load kernel param
    integer i;
    always@(posedge clk) begin 
        if (reset) begin 
            for (i = 0; i < kernel_size; i = i + 1) begin 
                kernel_reg[i] <= 0;
            end
            kernel_bias_reg <= 0;
        end

        else begin 
            if (conv_started && data_addr_col >= 1 && data_addr_col <= 5 && data_addr_row == 0) begin //from sim needs 2 cycle to get data back in kernel reg 
                for (i = 0; i < kernel_size; i = i + 1) begin 
                    // kernel_reg[i] <= {kernel_reg[i][4*weight_width - 1:0], col_weight[i*weight_width+:weight_width]};
                    kernel_reg[i] <= {col_weight[i*weight_width+:weight_width] ,kernel_reg[i][5*weight_width - 1:weight_width] };

                end
                kernel_bias_reg <= kernel_bias;
            end
        end
    end
    
    kernel_l1_mult kernel_mult_instance (
        .clk(clk),
        .reset(reset),
        .col_data_0(data_col_r0),
        .col_data_1(data_col_r1),
        .col_data_2(data_col_r2),
        .col_data_3(data_col_r3),
        .col_data_4(data_col_r4),
        .row_weights_0(kernel_reg[0]),
        .row_weights_1(kernel_reg[1]),
        .row_weights_2(kernel_reg[2]),
        .row_weights_3(kernel_reg[3]),
        .row_weights_4(kernel_reg[4]),
        .kernel_bias(kernel_bias_reg),
        .out_data(output_data_conv)
    );

    reg signed [2*data_width - 1 + 5:0] sim_conv1_output_data;

    `ifdef SYNTHESIS
    // always@(*) begin 
    //     sim_conv1_output_data = output_data_conv >>> (15+8-12); // the number after - is the target fractional bit
    // end
    
    // initial begin
    //     file = $fopen("C:/Users/2000c/ECE532/project/CNN_train/sim_conv1_only_out.csv", "w"); // refresh file
    //     if (file) begin
    //         $fclose(file);
    //     end
    // end

    `endif

    always@(posedge clk) begin 
        if (reset) begin 
            output_data_reg <= 0;
            output_valid_reg <= 0;
        end
        else begin 
            if (conv_started && data_addr_col >= /*7*/8 && data_addr_col <= /*30*/31) begin 
                // at posedge, col=5, last col enters register; col=6, kernel weights registered at mult entrance; 
                // col=7, per row kernel mult sum ready; col=8, per in-channel sum output ready;
                output_data_reg <= output_data_conv;
                output_valid_reg <= 'b1;

                `ifndef SYNTHESIS
                file = $fopen("C:/Users/2000c/ECE532/project/CNN_train/sim_conv1_only_out.csv", "a"); // Open file in append mode
                if (file) begin
                    sim_conv1_output_data = output_data_conv ;//>> (15+8-12); // the number after - is the target fractional bit
                    $fwrite(file, "%d\n", sim_conv1_output_data);
                    $fclose(file);
                end

                `endif 


            end
            else begin 
                output_data_reg <= 'b0;
                output_valid_reg <= 'b0;
            end
        end
    end

    // relu 
    assign output_data_act = (output_data_reg[2*data_width - 1+5] != 1) ? output_data_reg : 0;
    // output ready
    assign output_valid = output_valid_reg;

    

    
endmodule
