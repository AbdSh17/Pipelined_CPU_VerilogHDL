module ALU_CU (OP, stall, ALU_OP);

    input  wire [5:0] OP;
    input  wire stall;
    output reg [1:0] ALU_OP;

    always @(*) begin
        if (stall) begin
            ALU_OP = 2'b00;  
        end else begin
            case (OP)
                5'd0, 5'd4:                        
                    ALU_OP = 2'b00;
                5'd1, 5'd5, 5'd6, 5'd7, 5'd8, 5'd9: 
                    ALU_OP = 2'b01;
                5'd3, 5'd10, 5'd11, 5'd12:          
                    ALU_OP = 2'b10;
                5'd2:                               
                    ALU_OP = 2'b11;
                default:
                    ALU_OP = 2'b00;                
            endcase
        end
    end

endmodule