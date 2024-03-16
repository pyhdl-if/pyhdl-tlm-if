
interface tlm_hdl2hvl_fifo #(
    parameter Twidth=32, 
    parameter Tdepth=1) (
    input               clock,
    input               reset,
    input               valid,
    output              ready,
    input[Twidth-1:0]   dat_i);
    localparam pointer_w = (Tdepth > 1)?$clog2(Tdepth):1;
    localparam counter_w = pointer_w+1;

    reg[Twidth-1:0]     fifo[Tdepth-1:0];
    reg[pointer_w-1:0]  rptr;
    reg[pointer_w-1:0]  wptr;
    reg[counter_w-1:0]  count;

    assign ready = ((count != Tdepth) & !reset);
    wire push = (valid & ready);
    reg pop;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            rptr <= {pointer_w{1'b0}};
            wptr <= {pointer_w{1'b0}};
            count <= {counter_w{1'b0}};
            pop = 0;
        end else begin
            case ({push, pop})
            2'b01: begin // Pop with no push
                count <= count - 1;
                rptr <= ((rptr + 1) & (Tdepth-1));
                pop = 0;
            end
            2'b10: begin // Push with no pop
                fifo[wptr] <= dat_i;
                count <= count + 1;
                wptr <= ((wptr+1) & (Tdepth-1));
            end
            2'b11: begin // Simultaneous push and pop
                fifo[wptr] <= dat_i;
                wptr <= ((wptr+1) & (Tdepth-1));
                rptr <= ((rptr + 1) & (Tdepth-1));
                pop = 0;
            end
            endcase
        end
    end

    task get(output reg[Twidth-1:0] dat_o);
        while (count == 0 || pop == 1) begin
            @(posedge clock);
        end
        dat_o = fifo[rptr];
        pop = 1;
    endtask

endinterface
