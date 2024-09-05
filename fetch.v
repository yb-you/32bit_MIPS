module adder_32bit(
	input wire [31:0] A,
	input wire [31:0] B,
	output wire [31:0] O
);
	assign O = A + B;
endmodule

module pc_reg(
	input wire CLK,
	input wire RST,
	input wire [31:0] PC_NEXT,	
	output reg [31:0] PC		//32bit PC	
);
	always @(posedge CLK, posedge RST)begin
		if(RST) begin PC <= 32'b0; end
		else begin
			PC <= PC_NEXT;
		end
	end

endmodule

module instruction_memory(
	input wire [31:0]ADDRESS,		//32bit address
	output wire [31:0] INSTRUCTION	//32bit instruction
);

	reg [31:0] rom[0:63];			//64*32bit memory
	initial begin
		$readmemb("instruction_memory.dat", rom);	//read "instruction_memory.data"
	end

	assign INSTRUCTION = rom[ADDRESS[7:2]];		//ADDRESS: 32'bxxx..x00

endmodule

