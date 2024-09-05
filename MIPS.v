`include "fetch.v"
`include "decode.v"
`include "execution.v"

module MIPS_CPU(
	input wire CLK,
	input wire RST
);


//Instruction Fetch//		
	wire [31:0]pc;
	wire [31:0]pc_add4;		
	wire [31:0]instruction;

	adder_32bit u_adder(.A(pc),
						.B(32'd4),
						.O(pc_add4));
	pc_reg u_pc_reg(.CLK(CLK),
					.RST(RST),
					.PC_NEXT(pc_mux2_out),
					.PC(pc)); 
	instruction_memory u_instruction_memory(.ADDRESS(pc),
					.INSTRUCTION(instruction));

//Instruction Decoding//
	wire reg_dst, jump, branch, mem_read, mem_to_reg,mem_write, alu_src, reg_write;
	wire [1:0] alu_op;
	wire [31:0] mem_to_reg_data;
	wire [31:0] read_data1;
	wire [31:0] read_data2;
	wire [4:0] write_register;
	wire [31:0] sign_extend_32bit;
	wire [3:0] alu_operation;

	CU u_CU(.INSTRUCTION(instruction[31:26]),
			.REGDST(reg_dst),
			.JUMP(jump),
			.BRANCH(branch),
			.MEM_READ(mem_read),
			.MEM_TO_REG(mem_to_reg),
			.ALU_OP(alu_op),
			.MEM_WRITE(mem_write),
			.ALU_SRC(alu_src),
			.REG_WRITE(reg_write));

	ALU_Control u_ALU_Control(	.ALU_OP(alu_op),
								.FUNCT(instruction[5:0]),
								.ALU_OPERATION(alu_operation));
	
	assign write_register = reg_dst ? instruction[15:11] : instruction[20:16];


	register_set u_register_set(.CLK(CLK),
								.READ_REGISTER1(instruction[25:21]),
								.READ_REGISTER2(instruction[20:16]),
								.WRITE_REGISTER(write_register),
								.WRITE_DATA(mem_to_reg_data),
								.REG_WRITE(reg_write),
								.READ_DATA1(read_data1),
								.READ_DATA2(read_data2));

	sign_extend u_sign_extend(.DATA(instruction[15:0]), .DATA_32BIT(sign_extend_32bit));

//executrion#1: R-Type, Load, Store//
	wire [31:0] alu_in1;
	wire [31:0] alu_in2;
	wire alu_zero;
	wire [31:0] alu_result;
	wire [31:0]	read_data;

	assign alu_in1 = read_data1;
	assign alu_in2 = alu_src ? sign_extend_32bit : read_data2;

	ALU u_ALU(	.IN1(alu_in1),
				.IN2(alu_in2),
				.ALU_OPERATION(alu_operation),
				.ZERO(alu_zero),
				.RESULT(alu_result));

	data_memory u_data_memory(	.CLK(CLK),
								.ADDRESS(alu_result),
								.WRITE_DATA(read_data2),
								.MEM_WRITE(mem_write),
								.MEM_READ(mem_read),
								.READ_DATA(read_data));

	assign mem_to_reg_data = mem_to_reg ? read_data : alu_result;

//executrion#2: Branch//
	wire [31:0] sign_extend_shift_left2;
	wire [31:0] pc_branch;
	wire [31:0] pc_mux1_out;
	wire pc_src;

	assign sign_extend_shift_left2 = (sign_extend_32bit << 2);
	assign pc_src = branch & alu_zero;
	
	adder_32bit u2_adder(.A(pc_add4),
						.B(sign_extend_shift_left2),
						.O(pc_branch));
	assign pc_mux1_out = pc_src ? pc_branch : pc_add4;

//executrion#3: Jump//
	wire [27:0] instruction_shift_left2;
	wire [31:0] jump_address;
	wire [31:0] pc_mux2_out;

	assign instruction_shift_left2 = instruction[25:0] << 2;
	assign jump_address = {pc_add4[31:28],instruction_shift_left2};	//jump region: 2^28 = 256MB
	assign pc_mux2_out = jump ? jump_address : pc_mux1_out;

endmodule



`timescale 1ns/1ps
module tb;

	reg clk;
	reg rst;

	MIPS_CPU u_MIPS(.CLK(clk), .RST(rst));

	initial begin
		#10
		rst = 1'b1;
		clk = 1'b0;
		#10
		rst = 1'b0;
		forever #10 clk = ~clk;
	end

	initial begin
		$dumpvars;
		#5000
		$dumpflush;
		$finish;
	end
endmodule

