module seven_seg (
    input [3:0] i_number,
    output reg CA, // T10
    output reg CB, // R10
    output reg CC, // K16
    output reg CD, // K13
    output reg CE, // P15
    output reg CF, // T11
    output reg CG, // L18
    output wire DP // H15
);

assign DP = 1'b1;
always @(*) begin
    case (i_number)

    4'b0000 : begin
        CA = 0;
        CB = 0;
        CC = 0;
        CD = 0;
        CE = 0;
        CF = 0;
        CG = 1;
    end

    4'b0001 : begin
        CA = 1;
        CB = 0;
        CC = 0;
        CD = 1;
        CE = 1;
        CF = 1;
        CG = 1;
    end

    4'b0010 : begin
        CA = 0;
        CB = 0;
        CC = 1;
        CD = 0;
        CE = 0;
        CF = 1;
        CG = 0;
    end

    4'b0011 : begin
        CA = 0;
        CB = 0;
        CC = 0;
        CD = 0;
        CE = 1;
        CF = 1;
        CG = 0;
    end

    4'b0100 : begin
        CA = 1;
        CB = 0;
        CC = 0;
        CD = 1;
        CE = 1;
        CF = 0;
        CG = 0;
    end

    4'b0101 : begin
        CA = 0;
        CB = 1;
        CC = 0;
        CD = 0;
        CE = 1;
        CF = 0;
        CG = 0;
    end

    4'b0110 : begin
        CA = 0;
        CB = 1;
        CC = 0;
        CD = 0;
        CE = 0;
        CF = 0;
        CG = 0;
    end

    4'b0111 : begin
        CA = 0;
        CB = 0;
        CC = 0;
        CD = 1;
        CE = 1;
        CF = 1;
        CG = 1;
    end

    4'b1000 : begin
        CA = 0;
        CB = 0;
        CC = 0;
        CD = 0;
        CE = 0;
        CF = 0;
        CG = 0;
    end

    4'b1001 : begin
        CA = 0;
        CB = 0;
        CC = 0;
        CD = 1;
        CE = 1;
        CF = 0;
        CG = 0;
    end

    default : begin
        CA = 1;
        CB = 1;
        CC = 1;
        CD = 1;
        CE = 1;
        CF = 1;
        CG = 1;
    end

    endcase
end
    
endmodule