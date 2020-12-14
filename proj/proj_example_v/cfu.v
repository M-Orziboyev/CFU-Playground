

module Cfu (
  input               io_bus_cmd_valid,
  output              io_bus_cmd_ready,
  input      [2:0]    io_bus_cmd_payload_function_id,
  input      [31:0]   io_bus_cmd_payload_inputs_0,
  input      [31:0]   io_bus_cmd_payload_inputs_1,
  output              io_bus_rsp_valid,
  input               io_bus_rsp_ready,
  output              io_bus_rsp_payload_response_ok,
  output     [31:0]   io_bus_rsp_payload_outputs_0,
  input               clk
);

  assign io_bus_rsp_valid = io_bus_cmd_valid;
  assign io_bus_cmd_ready = io_bus_rsp_ready;
  assign io_bus_rsp_payload_response_ok = 1'b1;

  //  byte sum (unsigned)
  wire [31:0] cfu0;
  assign cfu0[31:0] =  io_bus_cmd_payload_inputs_0[7:0]   + io_bus_cmd_payload_inputs_1[7:0] +
                       io_bus_cmd_payload_inputs_0[15:8]  + io_bus_cmd_payload_inputs_1[15:8] +
                       io_bus_cmd_payload_inputs_0[23:16] + io_bus_cmd_payload_inputs_1[23:16] +
                       io_bus_cmd_payload_inputs_0[31:24] + io_bus_cmd_payload_inputs_1[31:24];

  // byte swap
  wire [31:0] cfu1;
  assign cfu1[31:24] =     io_bus_cmd_payload_inputs_0[7:0];
  assign cfu1[23:16] =     io_bus_cmd_payload_inputs_0[15:8];
  assign cfu1[15:8] =      io_bus_cmd_payload_inputs_0[23:16];
  assign cfu1[7:0] =       io_bus_cmd_payload_inputs_0[31:24];

  // bit reverse
  wire [31:0] cfu2;
  genvar n;
  generate
      for (n=0; n<32; n=n+1) begin
          assign cfu2[n] =     io_bus_cmd_payload_inputs_0[31-n];
      end
  endgenerate


  //
  // select output -- note that we're not fully decoding the 3 function_id bits
  //
  assign io_bus_rsp_payload_outputs_0 = io_bus_cmd_payload_function_id[1] ? cfu2 :
                                      ( io_bus_cmd_payload_function_id[0] ? cfu1 : cfu0);


endmodule