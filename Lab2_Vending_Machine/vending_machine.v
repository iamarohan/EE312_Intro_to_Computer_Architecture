`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			// Sign of the item withdrawal
	o_return_coin,				// Sign of the coin return
	stopwatch,
	current_total,
	return_temp,
);

	// Ports Declaration
	// Do not modify the module interface
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
	input i_trigger_return;

	output reg [`kNumItems-1:0] o_available_item;
	output reg [`kNumItems-1:0] o_output_item;
	output reg [`kNumCoins-1:0] o_return_coin;

	output [3:0] stopwatch;
	output [`kTotalBits-1:0] current_total;
	output [`kTotalBits-1:0] return_temp;
	// Normally, every output is register,
	//   so that it can provide stable value to the outside.

//////////////////////////////////////////////////////////////////////	/

	//we have to return many coins
	reg [`kCoinBits-1:0] returning_coin_0;
	reg [`kCoinBits-1:0] returning_coin_1;
	reg [`kCoinBits-1:0] returning_coin_2;
	reg block_item_0;
	reg block_item_1;
	//check timeout
	reg [3:0] stopwatch;
	//when return triggered
	reg have_to_return;
	reg [`kTotalBits-1:0] return_temp;
	reg [`kTotalBits-1:0] temp;
////////////////////////////////////////////////////////////////////////

	// Net constant values (prefix kk & CamelCase)
	// Please refer the wikepedia webpate to know the CamelCase practive of writing.
	// http://en.wikipedia.org/wiki/CamelCase
	// Do not modify the values.
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// NOTE: integer will never be used other than special usages.
	// Only used for loop iteration.
	// You may add more integer variables for loop iteration.
	integer i, j, k,l,m,n;

	// Internal states. You may add your own net & reg variables.
	reg [`kTotalBits-1:0] current_total;
	reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0];

	// Next internal states. You may add your own net and reg variables.
	reg [`kTotalBits-1:0] current_total_nxt;
	reg [`kItemBits-1:0] num_items_nxt [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins_nxt [`kNumCoins-1:0];

	// Variables. You may add more your own registers.
	reg [`kTotalBits-1:0] input_total, output_total, return_total_0,return_total_1,return_total_2;


	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).

		// Calculate the next current_total state. current_total_nxt =
		if (i_input_coin) begin
			for (i = 0; i < `kNumCoins; i = i+1) begin
				if (i_input_coin[i]) begin
					current_total_nxt = current_total + kkCoinValue[i];
				end
			end
			stopwatch = 4'b1010;
		end
		if (i_select_item) begin
			for (i = 0; i < `kNumItems; i =i+1) begin
				if (i_select_item[i]) begin
					current_total_nxt = current_total - kkItemPrice[i];
				end
			end
		stopwatch = 4'b1010;

		end
	end

	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		for (i = 0; i < `kNumItems; i = i+1) begin
			num_items_nxt[i] = num_items[i];
		end

		if (current_total >= kkItemPrice[0]) begin
		   o_available_item = 4'b0001;
		end 
		if (current_total >= kkItemPrice[1]) begin
		   o_available_item = 4'b0011;
		end 
		if (current_total >= kkItemPrice[2]) begin
		   o_available_item = 4'b0111;
		end 
		if (current_total >= kkItemPrice[3]) begin
		   o_available_item = 4'b1111;
		end 
		if (!num_items[0]) begin
		   o_available_item = o_available_item - 4'b0001;
		end 
		if (!num_items[1]) begin
		   o_available_item = o_available_item - 4'b0010;
		end 
		if (!num_items[2]) begin
		   o_available_item = o_available_item - 4'b0100;
		end  
		if (!num_items[3]) begin
		   o_available_item = o_available_item - 4'b1000;
		end 
		if (i_select_item) begin
			// TODO: o_output_item
			if (i_select_item[0] && (current_total>=kkItemPrice[0])) begin
				o_output_item = 4'b0001;
				num_items_nxt[0] = num_items[0] - 31'b1;
			end
			else if (i_select_item[1] && (current_total>=kkItemPrice[1])) begin
				o_output_item = 4'b0010;
				num_items_nxt[1] = num_items[1] - 31'b1;
			end
			else if (i_select_item[2] && (current_total>=kkItemPrice[2])) begin
				o_output_item = 4'b0100;
				num_items_nxt[2] = num_items[2] - 31'b1;
			end
			else if (i_select_item[3] && (current_total>=kkItemPrice[3])) begin
				o_output_item = 4'b1000;
				num_items_nxt[3] = num_items[3] - 31'b1;
			end
		end
		// o_return_coin
	end

	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		o_return_coin = 3'b000;
		if (!reset_n) begin
			// TODO: reset all states.
			current_total = 0;
			current_total_nxt = 0;

			for (i = 0; i < `kNumCoins; i = i+1) begin
				num_coins[i] = `kEachCoinNum;
				num_coins_nxt[i] = `kEachCoinNum;
			end

			for (i = 0; i < `kNumItems; i = i+1) begin
				num_items[i] = `kEachItemNum;
				num_items_nxt[i] = `kEachItemNum;
			end
			
			o_output_item = 0;
			o_available_item = 0;
			o_return_coin = 0;
			stopwatch = 4'b1010;

		end
		else begin
			// TODO: update all states.
			if (i_input_coin || i_select_item) begin
				current_total = current_total_nxt;
				current_total_nxt = 0;
				for (i = 0; i < `kNumCoins; i = i+1) begin
					num_coins[i] = num_coins_nxt[i];
				end
			
				for (i = 0; i < `kNumItems; i = i+1) begin
					num_items[i] = num_items_nxt[i];
				end


				o_output_item = 4'b0000;
			end
/////////////////////////////////////////////////////////////////////////

			// decrease stopwatch
			if (!i_trigger_return&&!i_input_coin&&!i_select_item) begin
				stopwatch = stopwatch - 4'b0001;
			end
			//if you have to return some coins then you have to turn on the bit

			if ((i_trigger_return || (!stopwatch)) && (current_total)) begin
				returning_coin_2 = current_total/kkCoinValue[2];
				return_temp = current_total-kkCoinValue[2]*returning_coin_2;
				returning_coin_1 = return_temp/kkCoinValue[1];
				return_temp = return_temp-kkCoinValue[1]*returning_coin_1;
				returning_coin_0 = return_temp/kkCoinValue[0];

				if (returning_coin_0) begin
					returning_coin_0 = returning_coin_0 - 1;
					o_return_coin = o_return_coin + 3'b001;
					current_total = current_total - 'd100;
				end
				if (returning_coin_1) begin
					returning_coin_1 = returning_coin_1 - 1;
					o_return_coin = o_return_coin + 3'b010;
					current_total = current_total - 'd500;
				end
				if (returning_coin_2) begin
					returning_coin_2 = returning_coin_2 - 1;
					o_return_coin = o_return_coin + 3'b100;
					current_total = current_total - 'd1000;
				end
				stopwatch = 4'b1010;
			end
	
/////////////////////////////////////////////////////////////////////////
		end		   //update all state end
	end	   //always end

endmodule
