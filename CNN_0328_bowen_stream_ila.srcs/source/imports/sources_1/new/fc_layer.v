`timescale 1ns / 1ps



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2024 11:20:46 PM
// Design Name: 
// Module Name: fc_layer
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

//aiming for 40 dsps
module fc_layer#(

    DATA_WIDTH = 16,
    WEIGHT_WIDTH = 16,  
    DATA_M = 10,
    WEIGHT_M = 15,
    OUT_M = 10
    
    )
    (
    input clk,
    input reset,
    input signed [DATA_WIDTH-1:0] in_data_0,
    input signed [DATA_WIDTH-1:0] in_data_1,
    input signed [DATA_WIDTH-1:0] in_data_2,
    input signed [DATA_WIDTH-1:0] in_data_3,

    input fc_start,
    output reg fc_working,
    output [5:0] data_addr_out,
    output out_valid,
    output [10 * DATA_WIDTH-1:0] out_data

    );

    localparam WIDTH_P = 2 * DATA_WIDTH + 5;
    localparam ENDING_ADDR = 21;
    integer i,j,k;

    localparam REFORMAT_SHIFT = DATA_M + WEIGHT_M - OUT_M;

    //////////////////////////////////////////////////
    // Signal declarations
    //////////////////////////////////////////////////

    // weight and bias is Q1.15
    (* ram_style = "block" *) 
    reg [WEIGHT_WIDTH-1:0] weight_rom [639:0];
    
    (* ram_style = "block" *)
     reg [WEIGHT_WIDTH-1:0] weight_rom_bias [9:0];
    initial begin 
//        for (i = 0; i < 10; i = i + 1) begin 
//            for (j = 0; j < 4; j = j + 1) begin 
//                for (k = 0; k < 16; k = k + 1) begin 
//                    weight_rom[k + j * 16 + i * 64] = (k+1); 
//                end
//            end
//        end      
        
//        for (i = 0; i < 10 ; i = i + 1) begin 
//            weight_rom_bias[i] = 0;
//        end  
        $readmemb("fc_weight_bram0.mem", weight_rom); 
//        $readmemb("C:/Users/2000c/ECE532/project/CNN_hw/layers_hw/layers_hw.srcs/sources_1/imports/memory_initializations/fc_weight_bram0.mem", weight_rom);
//        $readmemb("../../../../memory_initializations/fc_weight_bram0.mem", weight_rom); // working one

        $readmemb("fc_weight_bram_bias0.mem", weight_rom_bias);
//        $readmemb("../../../../memory_initializations/fc_weight_bram_bias0.mem", weight_rom_bias); // working one

    end

    reg [5:0] data_addr_out_reg;
    assign data_addr_out = data_addr_out_reg;
    reg signed [WEIGHT_WIDTH-1:0] weight_in_reg [9:0][3:0];


    // Q1.15 * Q6.10 = Q7.25 ==> sum of 16 --> Q11.25 ==> sum of 4 --> Q14.25 ==> reformat to Q6.10
    reg signed [2 * DATA_WIDTH - 1:0] product_reg[9:0][3:0]; 
    wire signed [2 * DATA_WIDTH-1+5:0] partial_sum_reg[9:0][3:0]; // total 36 bts 
    reg signed [2 * DATA_WIDTH-1+5+3:0] sum_reg[9:0]; // total 39 bits 
    reg signed [2 * DATA_WIDTH-1+5+3:0] sum_reformating_reg[9:0]; // total 39 bits 

    reg signed [DATA_WIDTH-1:0] sum_reformatted_reg[9:0];

    reg [10 * DATA_WIDTH-1:0] out_data_reg;
    reg out_valid_reg;

    //////////////////////////////////////////////////
    // Internal logic
    //////////////////////////////////////////////////
    // note: data (from outside ) and weight access are done in 1 cycle 
    // weight rom access 

    always@(posedge clk) begin 
        for (i = 0; i < 10; i = i + 1) begin 
            for (j = 0; j < 4; j = j + 1) begin 
                if (data_addr_out_reg < 16)
                    weight_in_reg[i][j] <= weight_rom[i * 64 + j*16 + data_addr_out_reg]; 
                else 
                    weight_in_reg[i][j] <= 0;
            end
        end
    end

    //working signal 
    always@(posedge clk) begin 

        if (reset) begin 
            fc_working <= 0;
        end

        else begin 
            if (data_addr_out_reg == ENDING_ADDR) 
                fc_working <= 0;
            else if (fc_start) 
                fc_working <= 1;
        end
    end

    // data address count 

    always@(posedge clk) begin 

        if (reset) begin 
            data_addr_out_reg <= 0;
        end
        else begin 
            if (fc_working) begin 
                if (data_addr_out_reg == ENDING_ADDR) begin 
                    data_addr_out_reg <= 0;
                end
                else begin 
                    data_addr_out_reg <= data_addr_out_reg + 1;
                end
            end
        end
    end

    // MAC operation
    reg signed [DATA_WIDTH-1:0] in_data_reg [3:0]; 
    
    always@(*) begin
        for (i = 0; i < 10; i = i + 1) begin
            in_data_reg[0] = in_data_0;
            in_data_reg[1] = in_data_1;
            in_data_reg[2] = in_data_2;
            in_data_reg[3] = in_data_3;
        end
    end


    genvar ii, jj;

    generate
        for (ii = 0; ii < 10; ii = ii + 1) begin: gen_output_nodes
            for (jj = 0; jj < 4; jj = jj + 1) begin: gen_macc_instances // 4 parallel MACCs per output node
                MACC_MACRO #(
                    .DEVICE("7SERIES"),
                    .LATENCY(3),
                    .WIDTH_A(DATA_WIDTH),
                    .WIDTH_B(WEIGHT_WIDTH),
                    .WIDTH_P(WIDTH_P)
                ) macc_inst (
                    .P( partial_sum_reg[ii][jj] ),
                    .A( in_data_reg[jj] ), // Simplified addressing, adjust based on actual input-weight pairing
                    .ADDSUB(1'b1), // Add operation
                    .B( weight_in_reg[ii][jj] ),
                    .CARRYIN(1'b0),
                    .CE(1'b1), // Enable operation
                    .CLK(clk),
                    .LOAD(1'b0),
                    .LOAD_DATA(37'b0), // Not used in this context
                    .RST(reset | out_valid_reg)
                );
            end
        end
    endgenerate

    always@(posedge clk) begin 
        if (reset) begin 
            // for (i = 0; i < 10; i = i + 1) begin 
            //     for (j = 0; j < 4; j = j + 1) begin 
            //         partial_sum_reg[i][j] <= 0;
            //         product_reg[i][j] <= 0;
            //     end
            // end
            for (i = 0; i < 10; i = i + 1) begin 
                // from Q1.15 --> Q14.25
                sum_reg[i] <= {{13{weight_rom_bias[i][0]}},{weight_rom_bias[i]<<10}};
            end
        end
        else begin 
            if (fc_working) begin               
                for (i = 0; i < 10; i = i + 1) begin 
                    if (data_addr_out_reg == 0) begin 
                        sum_reg[i] <= 'b0;
                    end
                    else if (data_addr_out_reg == 20) begin 
                        sum_reg[i] <= partial_sum_reg[i][0] + partial_sum_reg[i][1] + partial_sum_reg[i][2] + partial_sum_reg[i][3] + sum_reg[i];
                    end
                end
            end
        end
    end 
    

    // reformatting
    always@(*) begin 
        for (i = 0; i < 10; i = i + 1) begin 
            sum_reformating_reg[i] = sum_reg[i] >>> REFORMAT_SHIFT;

            // detect if the sign extension part is indicating overflow 
            if (sum_reformating_reg[i][2*DATA_WIDTH-1+5+3] == 0 && sum_reformating_reg[i][2*DATA_WIDTH-1+5+3:15] != 0) begin 
                sum_reformatted_reg[i] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
            end
            else if (sum_reformating_reg[i][2*DATA_WIDTH-1+5+3] == 1 && sum_reformating_reg[i][2*DATA_WIDTH-1+5+3:15] != 25'h1ffffff) begin 
                sum_reformatted_reg[i] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
            end
            else begin 
                sum_reformatted_reg[i] = {sum_reformating_reg[i][2*DATA_WIDTH-1+5+3],sum_reformating_reg[i][DATA_WIDTH-2:0]};
            end
        end

    end

    always@(posedge clk) begin 
        if (reset) begin 
            out_valid_reg <= 0;
            out_data_reg <= 0;
        end
        else begin 
            if (fc_working && data_addr_out_reg == ENDING_ADDR) begin 
                out_valid_reg <= 1;
                out_data_reg <= {sum_reformatted_reg[9],sum_reformatted_reg[8],sum_reformatted_reg[7],sum_reformatted_reg[6],sum_reformatted_reg[5],sum_reformatted_reg[4],sum_reformatted_reg[3],sum_reformatted_reg[2],sum_reformatted_reg[1],sum_reformatted_reg[0]};
            end
            else begin 
                out_valid_reg <= 0;
            end
        end
    end

    assign out_valid = out_valid_reg;
    assign out_data = out_data_reg;
    

endmodule

// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date: 03/15/2024 11:20:46 PM
// // Design Name: 
// // Module Name: fc_layer
// // Project Name: 
// // Target Devices: 
// // Tool Versions: 
// // Description: 
// // 
// // Dependencies: 
// // 
// // Revision:
// // Revision 0.01 - File Createda
// // Additional Comments:
// // 
// //////////////////////////////////////////////////////////////////////////////////

// //aiming for 40 dsps
// module fc_layer#(

//     DATA_WIDTH = 16,
//     WEIGHT_WIDTH = 16,  
//     DATA_M = 10,
//     WEIGHT_M = 15,
//     OUT_M = 10
    
//     )
//     (
//     input clk,
//     input reset,
//     input signed [DATA_WIDTH-1:0] in_data_0,
//     input signed [DATA_WIDTH-1:0] in_data_1,
//     input signed [DATA_WIDTH-1:0] in_data_2,
//     input signed [DATA_WIDTH-1:0] in_data_3,

//     input fc_start,
//     output reg fc_working,
//     output [5:0] data_addr_out,
//     output out_valid,
//     output [10 * DATA_WIDTH-1:0] out_data

//     );

//     localparam ENDING_ADDR = 19;
//     integer i,j;

//     localparam REFORMAT_SHIFT = DATA_M + WEIGHT_M - OUT_M;

//     //////////////////////////////////////////////////
//     // Signal declarations
//     //////////////////////////////////////////////////

//     // weight and bias is Q1.15
//     (* ram_style = "block" *) 
//     reg [WEIGHT_WIDTH-1:0] weight_rom [9:0][3:0][15:0];
    
//     (* ram_style = "block" *)
//      reg [WEIGHT_WIDTH-1:0] weight_rom_bias [9:0];
//     initial begin 
//         $readmemb("../../../../memory_initializations/fc_weight_bram0.mem", weight_rom);
//         $readmemb("../../../../memory_initializations/fc_weight_bram_bias0.mem", weight_rom_bias);
//     end

//     reg [5:0] data_addr_out_reg;
//     assign data_addr_out = data_addr_out_reg;
//     reg signed [WEIGHT_WIDTH-1:0] weight_in_reg [9:0][3:0];


//     // Q1.15 * Q6.10 = Q7.25 ==> sum of 16 --> Q11.25 ==> sum of 4 --> Q14.25 ==> reformat to Q6.10
//     reg signed [2 * DATA_WIDTH - 1:0] product_reg[9:0][3:0]; 
//     reg signed [2 * DATA_WIDTH-1+5:0] partial_sum_reg[9:0][3:0]; // total 36 bts 
//     reg signed [2 * DATA_WIDTH-1+5+3:0] sum_reg[9:0]; // total 39 bits 
//     reg signed [2 * DATA_WIDTH-1+5+3:0] sum_reformating_reg[9:0]; // total 39 bits 

//     reg signed [DATA_WIDTH-1:0] sum_reformatted_reg[9:0];

//     reg [10 * DATA_WIDTH-1:0] out_data_reg;
//     reg out_valid_reg;

//     //////////////////////////////////////////////////
//     // Internal logic
//     //////////////////////////////////////////////////
//     // note: data (from outside ) and weight access are done in 1 cycle 
//     // weight rom access 

//     always@(posedge clk) begin 
//         for (i = 0; i < 10; i = i + 1) begin 
//             for (j = 0; j < 4; j = j + 1) begin 
//                 if (data_addr_out_reg < 16)
//                     weight_in_reg[i][j] <= weight_rom[i][j][data_addr_out_reg]; 
//                 else 
//                     weight_in_reg[i][j] <= 0;
//             end
//         end
//     end

//     //working signal 
//     always@(posedge clk) begin 

//         if (reset) begin 
//             fc_working <= 0;
//         end

//         else begin 
//             if (data_addr_out_reg == ENDING_ADDR) 
//                 fc_working <= 0;
//             else if (fc_start) 
//                 fc_working <= 1;
//         end
//     end

//     // data address count 

//     always@(posedge clk) begin 

//         if (reset) begin 
//             data_addr_out_reg <= 0;
//         end
//         else begin 
//             if (fc_working) begin 
//                 if (data_addr_out_reg == ENDING_ADDR) begin 
//                     data_addr_out_reg <= 0;
//                 end
//                 else begin 
//                     data_addr_out_reg <= data_addr_out_reg + 1;
//                 end
//             end
//         end
//     end

//     // MAC operation

//     always@(posedge clk) begin 
//         if (reset) begin 
//             for (i = 0; i < 10; i = i + 1) begin 
//                 for (j = 0; j < 4; j = j + 1) begin 
//                     partial_sum_reg[i][j] <= 0;
//                     product_reg[i][j] <= 0;
//                 end
//             end
//             for (i = 0; i < 10; i = i + 1) begin 
//                 // from Q1.15 --> Q14.25
//                 sum_reg[i] <= {{13{weight_rom_bias[i][0]}},{weight_rom_bias[i]<<10}};
//             end
//         end
//         else begin 
//             if (fc_working) begin 
//                 if ( data_addr_out_reg == 0) begin 
//                     for (i = 0; i < 10; i = i + 1) begin 
//                         for (j = 0; j < 4; j = j + 1) begin 
//                             partial_sum_reg[i][j] <= 0;
//                             product_reg[i][j] <= 0;
//                         end
//                     end
//                     for (i = 0; i < 10; i = i + 1) begin 
//                         sum_reg[i] <= 0;
//                     end
//                 end
//                 else  begin 
//                     for (i = 0; i < 10; i = i + 1) begin
//                         (* USE_DSP = "yes" *)    product_reg[i][0] <= in_data_0 * weight_in_reg[i][0];
//                         (* USE_DSP = "yes" *)    product_reg[i][1] <= in_data_1 * weight_in_reg[i][1];
//                         (* USE_DSP = "yes" *)    product_reg[i][2] <= in_data_2 * weight_in_reg[i][2];
//                         (* USE_DSP = "yes" *)    product_reg[i][3] <= in_data_3 * weight_in_reg[i][3];
//                         for (j = 0; j < 4; j = j + 1) begin
//                         (* USE_DSP = "yes" *)    partial_sum_reg[i][j] <= partial_sum_reg[i][j] + product_reg[i][j];
//                         end
//                     end
//                 end

//                 if (data_addr_out_reg == 18) begin 
//                     for (i = 0; i < 10; i = i + 1) begin 
//                         sum_reg[i] <= partial_sum_reg[i][0] + partial_sum_reg[i][1] + partial_sum_reg[i][2] + partial_sum_reg[i][3] + sum_reg[i];
//                     end
//                 end
//             end
//         end
//     end 
    

//     // reformatting
//     always@(*) begin 
//         for (i = 0; i < 10; i = i + 1) begin 
//             sum_reformating_reg[i] = sum_reg[i] >>> REFORMAT_SHIFT;

//             // detect if the sign extension part is indicating overflow 
//             if (sum_reformating_reg[i][2*DATA_WIDTH-1+5+3] == 0 && sum_reformating_reg[i][2*DATA_WIDTH-1+5+3:15] != 0) begin 
//                 sum_reformatted_reg[i] = {1'b0,{(DATA_WIDTH-1){1'b1}}};
//             end
//             else if (sum_reformating_reg[i][2*DATA_WIDTH-1+5+3] == 1 && sum_reformating_reg[i][2*DATA_WIDTH-1+5+3:15] != -1) begin 
//                 sum_reformatted_reg[i] = {1'b1,{(DATA_WIDTH-1){1'b0}}};
//             end
//             else begin 
//                 sum_reformatted_reg[i] = {sum_reformating_reg[i][2*DATA_WIDTH-1+5+3],sum_reformating_reg[i][DATA_WIDTH-2:0]};
//             end
//         end

//     end

//     always@(posedge clk) begin 
//         if (reset) begin 
//             out_valid_reg <= 0;
//             out_data_reg <= 0;
//         end
//         else begin 
//             if (fc_working && data_addr_out_reg == ENDING_ADDR) begin 
//                 out_valid_reg <= 1;
//                 out_data_reg <= {sum_reformatted_reg[9],sum_reformatted_reg[8],sum_reformatted_reg[7],sum_reformatted_reg[6],sum_reformatted_reg[5],sum_reformatted_reg[4],sum_reformatted_reg[3],sum_reformatted_reg[2],sum_reformatted_reg[1],sum_reformatted_reg[0]};
//             end
//             else begin 
//                 out_valid_reg <= 0;
//             end
//         end
//     end

//     assign out_valid = out_valid_reg;
//     assign out_data = out_data_reg;
    

// endmodule
