module ALU(
	input wire [31:0] IN1,
	input wire [31:0] IN2,
	input wire [3:0] ALU_OPERATION,

	output reg ZERO,
	output reg [31:0] RESULT
);
	always @(*) begin
		case (ALU_OPERATION)
			4'b0000: RESULT = IN1 & IN2;		//AND
			4'b0001: RESULT = IN1 | IN2;		//OR
			4'b0010: RESULT = IN1 + IN2;		//Load, Store, add
			4'b0011: ;
			4'b0100: ;
			4'b0101: ;
			4'b0110: RESULT = IN1 - IN2;		//Branch, subtract
			4'b0111: ;
	
			4'b1000: ;
			4'b1001: ;	
			4'b1010: ;
			4'b1011: ;
			4'b1100: RESULT = ~(IN1 | IN2);		//NOR
			4'b1101: ;
			4'b1110: ;
			4'b1111: ;
		endcase
		if (!RESULT) ZERO = 1'b1;
		else	ZERO = 1'b0;
	end 
endmodule

module data_memory(
	input wire CLK,
	input wire [31:0] ADDRESS,
	input wire [31:0] WRITE_DATA,
	input wire MEM_WRITE,
	input wire MEM_READ,

	output wire [31:0] READ_DATA
);
	reg [31:0] ram[0:63];
	initial begin
		$readmemh("data_memory.dat", ram);		//read "data_memory.data"
	end

	assign READ_DATA = MEM_READ ? ram[ADDRESS[5:0]] : 32'hx;

	always @(posedge CLK) begin
		if(MEM_WRITE) begin ram[ADDRESS[5:0]] = WRITE_DATA;
								$writememh("data_memory_out.dat",ram);end
	end
endmodule
