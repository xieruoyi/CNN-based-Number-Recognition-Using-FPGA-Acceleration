module choose_output(
    input clk,
    input [159:0] prob_in,
    input i_valid,
    output reg [3:0] out_num
);

reg signed [15:0] prob [0:9];
reg signed [15:0] prob_stage1 [0:3];
reg signed [15:0] stage1_8, stage1_9;
reg [3:0] stage1 [0:3];

reg signed [15:0] prob_stage2 [0:1];
reg signed [15:0] stage2_8, stage2_9;
reg [3:0] stage2 [0:1];

reg signed [15:0] prob_stage3 [0:1];
reg [3:0] stage3 [0:1];

always @(posedge clk) begin
    // latch inputs
    if (i_valid) begin
        prob[0] <= prob_in[15:0];
        prob[1] <= prob_in[31:16];
        prob[2] <= prob_in[47:32];
        prob[3] <= prob_in[63:48];
        prob[4] <= prob_in[79:64];
        prob[5] <= prob_in[95:80];
        prob[6] <= prob_in[111:96];
        prob[7] <= prob_in[127:112];
        prob[8] <= prob_in[143:128];
        prob[9] <= prob_in[159:144];
    end

    // first stage logic
    if (prob[0] > prob[1]) begin
        prob_stage1[0] <= prob[0];
        stage1[0] <= 4'b0000;
    end
    else begin
        prob_stage1[0] <= prob[1];
        stage1[0] <= 4'b0001;
    end

    if (prob[2] > prob[3]) begin
        prob_stage1[1] <= prob[2];
        stage1[1] <= 4'b0010;
    end
    else begin
        prob_stage1[1] <= prob[3];
        stage1[1] <= 4'b0011;
    end

    if (prob[4] > prob[5]) begin
        prob_stage1[2] <= prob[4];
        stage1[2] <= 4'b0100;
    end
    else begin
        prob_stage1[2] <= prob[5];
        stage1[2] <= 4'b0101;
    end

    if (prob[6] > prob[7]) begin
        prob_stage1[3] <= prob[6];
        stage1[3] <= 4'b0110;
    end
    else begin
        prob_stage1[3] <= prob[7];
        stage1[3] <= 4'b0111;
    end

    stage1_8 <= prob[8];
    stage1_9 <= prob[9];



    // second stage logic
    if (prob_stage1[0] > prob_stage1[1]) begin
        prob_stage2[0] <= prob_stage1[0];
        stage2[0] <= stage1[0];
    end
    else begin
        prob_stage2[0] <= prob_stage1[1];
        stage2[0] <= stage1[1];
    end

    if (prob_stage1[2] > prob_stage1[3]) begin
        prob_stage2[1] <= prob_stage1[2];
        stage2[1] <= stage1[2];
    end
    else begin
        prob_stage2[1] <= prob_stage1[3];
        stage2[1] <= stage1[3];
    end

    stage2_8 <= stage1_8;
    stage2_9 <= stage1_9;

    // third stage logic
    if (prob_stage2[0] > prob_stage2[1]) begin
        prob_stage3[0] <= prob_stage2[0];
        stage3[0] <= stage2[0];
    end
    else begin
        prob_stage3[0] <= prob_stage2[1];
        stage3[0] <= stage2[1];
    end

    if (stage2_8 > stage2_9) begin
        prob_stage3[1] <= stage2_8;
        stage3[1] <= 4'b1000;
    end
    else begin
        prob_stage3[1] <= stage2_9;
        stage3[1] <= 4'b1001;
    end



    // forth stage logic
    if (prob_stage3[0] > prob_stage3[1]) begin
    
        if (prob_stage3[0][15] == 0)
            out_num <= stage3[0];
        else 
            out_num = 4'b1111;
    end
    else begin
        if (prob_stage3[1][15] == 0)
            out_num <= stage3[1];
        else 
            out_num = 4'b1111;

    end
end

endmodule