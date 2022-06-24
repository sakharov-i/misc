
// Quartus exmple constraint:
// set_false_path -through [get_pins -compatibility_mode *cdc_async_rst*|sync_ff*|clrn]

module cdc_async_rst #( parameter
  SYNC_STAGES = 2,
  bit ARST_ACTIVE_STATE = 1'b0
) (
  input logic clk,
  input logic arst_src,
  output logic arst_dst
);

logic [SYNC_STAGES-1:0] sync_ff;

generate
  if (ARST_ACTIVE_STATE) begin
    always_ff @(posedge clk or posedge arst_src) begin
      if(arst_src) begin
        sync_ff <= '1;
      end else begin
        sync_ff <= sync_ff << 1 | 1'b0;
      end
    end
    assign arst_dst = sync_ff[SYNC_STAGES-1];
  end else begin
    always_ff @(posedge clk or negedge arst_src) begin
      if(~arst_src) begin
        sync_ff <= '0;
      end else begin
        sync_ff <= sync_ff << 1 | 1'b1;
      end
    end
    assign arst_dst = sync_ff[SYNC_STAGES-1];
  end
endgenerate


endmodule