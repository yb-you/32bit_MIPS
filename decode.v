module CU(
	input wire [5:0]INSTRUCTION,

	output wire REGDST,
	output wire JUMP,
	output wire BRANCH,
	output wire MEM_READ,
	output wire MEM_TO_REG,
	output wire [1:0] ALU_OP,
	output wire MEM_WRITE,
	output wire ALU_SRC,
	output wire REG_WRITE
);
	reg [9:0] cu_sig;	
	initial begin
		cu_sig = 10'b0;
	end

	parameter R_type 		= 	6'b000000;
	parameter addi			=	6'b001000;
	parameter load 			= 	6'b100011;
	parameter store			=	6'b101011;
	parameter branch		=	6'b000100;
	parameter jump			=	6'b000010; 

	always @(*) begin
		case (INSTRUCTION)
			R_type: 		cu_sig <= 10'b1000010001;
			addi:			cu_sig <= 10'b000X000011;
			load:		 	cu_sig <= 10'b0001100011;
			store:			cu_sig <= 10'bX000X00110;
			branch:			cu_sig <= 10'bX010X01000;
			jump:			cu_sig <= 10'bX1X0XXX0XX;
		endcase
	end

	assign {REGDST, JUMP, BRANCH, MEM_READ, MEM_TO_REG, ALU_OP, MEM_WRITE, ALU_SRC, REG_WRITE} = cu_sig;

endmodule

module ALU_Control(
	input wire [1:0] ALU_OP,
	input wire [5:0] FUNCT,
	
	output reg [3:0] ALU_OPERATION
);
	always @(*) begin
		if(ALU_OP == 2'b00) ALU_OPERATION = 4'b0010;			//add
		else if(ALU_OP == 2'b01) ALU_OPERATION = 4'b0110;		//subtract
		else if(ALU_OP == 2'b10) begin
			case (FUNCT)
				6'b100000: ALU_OPERATION = 4'b0010;			//add
				6'b100010: ALU_OPERATION = 4'b0110;			//subtract
				6'b100100: ALU_OPERATION = 4'b0000;			//AND
				6'b100101: ALU_OPERATION = 4'b0001;			//OR
				6'b101010: ALU_OPERATION = 5'b0111;			//set-on-less-than
			endcase
		end
	end
endmodule

module register_set(
	input wire CLK,
	input wire [4:0]READ_REGISTER1,
	input wire [4:0]READ_REGISTER2,
	input wire [4:0]WRITE_REGISTER,
	input wire [31:0]WRITE_DATA,
	input wire REG_WRITE,

	output wire [31:0]READ_DATA1,
	output wire [31:0]READ_DATA2
);

	reg [31:0] r[0:31];						//32bit register set 32
	wire [31:0] r0, r1, r2, r3, r4, r5, r6, r7;		//use for waveform
	integer i;

	initial begin
		for(i=0; i<32 ;i=i+1)				//initial: all r[] = 0
			r[i] = 32'b0;
	end	
	
	assign READ_DATA1 = r[READ_REGISTER1];
	assign READ_DATA2 = r[READ_REGISTER2];

	assign {r0, r1, r2, r3} = {r[0], r[1], r[2], r[3]};		//use for waveform
	assign {r4, r5, r6, r7} = {r[4], r[5], r[6], r[7]};		//use for waveform


	always @(posedge CLK) begin
		if(REG_WRITE) r[WRITE_REGISTER] = WRITE_DATA;
	end

endmodule

module sign_extend(
	input wire [15:0]DATA,
	output wire [31:0]DATA_32BIT
);

	wire MSB;
	assign MSB = DATA[15];
	assign DATA_32BIT = {{16{MSB}}, DATA};

endmodule
