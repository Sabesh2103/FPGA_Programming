`timescale 1ns/1ps
// Self-checking testbench for pulse_extender.
module tb_pulse_extender;
    localparam N = 10;               // small value for fast simulation
    reg  clk = 0, rst_n = 0, pulse_in = 0;
    wire pulse_out;
    integer errors = 0;
    integer width;

    pulse_extender #(.EXTEND_CYCLES(N)) dut (
        .clk(clk), .rst_n(rst_n), .pulse_in(pulse_in), .pulse_out(pulse_out)
    );

    always #10 clk = ~clk;           // 50 MHz

    // Send a pulse_in of 'len' clock cycles
    task send_pulse(input integer len);
        begin
            @(negedge clk); pulse_in = 1;
            repeat (len) @(negedge clk);
            pulse_in = 0;
        end
    endtask

    // Wait for pulse_out to rise, then measure its width in clock cycles
    task measure_width;
        begin
            width = 0;
            while (pulse_out !== 1'b1) @(posedge clk);
            while (pulse_out === 1'b1) begin
                width = width + 1;
                @(posedge clk);
            end
        end
    endtask

    task check(input integer expected, input [255:0] name);
        begin
            if (width !== expected) begin
                $display("FAIL  %0s: width=%0d expected=%0d", name, width, expected);
                errors = errors + 1;
            end else
                $display("PASS  %0s: width=%0d", name, width);
        end
    endtask

    initial begin
        $dumpfile("tb_pulse_extender.vcd");
        $dumpvars(0, tb_pulse_extender);

        // Reset
        repeat (3) @(negedge clk);
        rst_n = 1;
        repeat (2) @(negedge clk);
        if (pulse_out !== 1'b0) begin
            $display("FAIL  output not low after reset"); errors = errors + 1;
        end

        // Test 1: single-cycle pulse is extended to N cycles
        fork send_pulse(1); measure_width; join
        check(N, "1-cycle input");
        repeat (5) @(negedge clk);

        // Test 2: long input pulse (5 cycles) still gives N cycles
        fork send_pulse(5); measure_width; join
        check(N, "5-cycle input");
        repeat (5) @(negedge clk);

        // Test 3: retrigger 4 cycles after the first pulse -> output extended
        fork
            begin
                send_pulse(1);
                repeat (3) @(negedge clk);
                send_pulse(1);
            end
            measure_width;
        join
        $display("INFO  retrigger width=%0d (> %0d means extended)", width, N);
        if (width <= N) begin
            $display("FAIL  retrigger did not extend output"); errors = errors + 1;
        end
        repeat (N + 5) @(negedge clk);

        // Test 4: async reset mid-pulse clears the output
        send_pulse(1);
        repeat (6) @(negedge clk);
        rst_n = 0; #1;
        if (pulse_out !== 1'b0) begin
            $display("FAIL  reset did not clear output"); errors = errors + 1;
        end else $display("PASS  reset clears output");
        rst_n = 1;

        repeat (5) @(negedge clk);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
