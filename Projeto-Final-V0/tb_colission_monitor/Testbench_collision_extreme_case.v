`timescale 1ns/1ps

module tb_crossbar_monitor_cases;

  parameter N = 8;
  parameter W = 8;
  parameter ROUTE_BITS = $clog2(N);

  reg  [N*W-1:0]          in_data_flat;
  reg  [N*ROUTE_BITS-1:0] route_flat;
  reg  [N-1:0]            output_enable;

  wire [N*W-1:0]          out_data_flat;
  wire                    collision_error;

  crossbar_top_level #(
    .N(N),
    .W(W),
    .ROUTE_BITS(ROUTE_BITS)
  ) dut (
    .in_data_flat(in_data_flat),
    .route_flat(route_flat),
    .output_enable(output_enable),
    .out_data_flat(out_data_flat),
    .collision_error(collision_error)
  );

  initial begin

    // Input pattern:
    in_data_flat = {
      8'h88, 8'h77, 8'h66, 8'h55,
      8'h44, 8'h33, 8'h22, 8'h11
    };

    // Enable all outputs
    output_enable = 8'b1111_1111;

    // CASE 1: VALID MAPPING (NO COLLISION)
    route_flat = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd2,3'd1,3'd0};
    #10;

    // CASE 2: SIMPLE COLLISION
    route_flat = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd3,3'd1,3'd0};
    #10;

    // CASE 3: MULTIPLE COLLISIONS
    route_flat = {3'd7,3'd6,3'd5,3'd5,3'd2,3'd2,3'd1,3'd0};
    #10;

    // CASE 4: COLLISION BUT ONE DISABLED
    route_flat    = {3'd7,3'd6,3'd5,3'd4,3'd3,3'd3,3'd1,3'd0};
    output_enable = 8'b1111_1101;
    #10;

    // CASE 5: EXTREME COLLISION
    output_enable = 8'b1111_1111;
    route_flat = {3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0};
    #10;

    $stop;
  end

endmodule
