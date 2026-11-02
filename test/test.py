import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_kmeans(dut):
    dut._log.info("Starting K-Means Hardware Verification")

    clock = Clock(dut.clk, 20, unit="ns")  # 50 MHz
    cocotb.start_soon(clock.start())

    # Reset the chip
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # Test Point (12, 15) -> Should be assigned to Cluster 0
    dut.ui_in.value = 12   # Px
    dut.uio_in.value = 15  # Py
    await ClockCycles(dut.clk, 5)

    # Check cluster_out (bit 0 of uo_out) is 0
    assert (dut.uo_out.value.integer & 1) == 0
    dut._log.info("Point (12, 15) successfully assigned to Cluster 0!")
