import cocotb
from cocotb.triggers import Timer

SEG_LUT = {
    0x0: "1111110",
    0x1: "0110000",
    0x2: "1101101",
    0x3: "1111001",
    0x4: "0110011",
    0x5: "1011011",
    0x6: "1011111",
    0x7: "1110000",
    0x8: "1111111",
    0x9: "1111011",
    0xA: "1110111",
    0xB: "0011111",
    0xC: "1001110",
    0xD: "0111101",
    0xE: "1001111",
    0xF: "1000111",
}

@cocotb.test()
async def test_seven_segment(dut):
    for i in range(16):
        dut.val.value = i

        await Timer(1, unit="ns")

        expected = SEG_LUT[i]
        actual = str(dut.seg.value)

        assert actual == expected, f"mismatch for {i}: got {actual}, expected {expected}"