
#include "riscv.h"

/* riscv.h defines a macro:

    #define opcode_R(opcode, funct3, funct7, rs1, rs2)

   that returns at 32b value.  The opcode must be "CUSTOM0" (also defined in riscv.h).

   'func3' is used as functionID sent to the CFU.

*/

// =============== Access the custom instruction

// generic name for each custom instruction
#define cfu_op0_hw(rs1, rs2)  opcode_R(CUSTOM0, 0, 0, (rs1), (rs2))
#define cfu_op1_hw(rs1, rs2)  opcode_R(CUSTOM0, 1, 0, (rs1), (rs2))
#define cfu_op2_hw(rs1, rs2)  opcode_R(CUSTOM0, 2, 0, (rs1), (rs2))
#define cfu_op3_hw(rs1, rs2)  opcode_R(CUSTOM0, 3, 0, (rs1), (rs2))
#define cfu_op4_hw(rs1, rs2)  opcode_R(CUSTOM0, 4, 0, (rs1), (rs2))
#define cfu_op5_hw(rs1, rs2)  opcode_R(CUSTOM0, 5, 0, (rs1), (rs2))
#define cfu_op6_hw(rs1, rs2)  opcode_R(CUSTOM0, 6, 0, (rs1), (rs2))
#define cfu_op7_hw(rs1, rs2)  opcode_R(CUSTOM0, 7, 0, (rs1), (rs2))




// =============== Software (C implementation of custom instructions)

uint32_t Cfu(uint32_t functionid, uint32_t rs1, uint32_t rs2);

// generic name for each custom instruction
#define cfu_op0_sw(rs1, rs2)  Cfu(0, rs1, rs2)
#define cfu_op1_sw(rs1, rs2)  Cfu(1, rs1, rs2)
#define cfu_op2_sw(rs1, rs2)  Cfu(2, rs1, rs2)
#define cfu_op3_sw(rs1, rs2)  Cfu(3, rs1, rs2)
#define cfu_op4_sw(rs1, rs2)  Cfu(4, rs1, rs2)
#define cfu_op5_sw(rs1, rs2)  Cfu(5, rs1, rs2)
#define cfu_op6_sw(rs1, rs2)  Cfu(6, rs1, rs2)
#define cfu_op7_sw(rs1, rs2)  Cfu(7, rs1, rs2)



// =============== Switch HW vs SW

#ifdef CFU_FORCE_SW
#define cfu_op0(rs1, rs2)       cfu_op0_sw(rs1, rs2)
#define cfu_op1(rs1, rs2)       cfu_op1_sw(rs1, rs2)
#define cfu_op2(rs1, rs2)       cfu_op2_sw(rs1, rs2)
#define cfu_op3(rs1, rs2)       cfu_op3_sw(rs1, rs2)
#define cfu_op4(rs1, rs2)       cfu_op4_sw(rs1, rs2)
#define cfu_op5(rs1, rs2)       cfu_op5_sw(rs1, rs2)
#define cfu_op6(rs1, rs2)       cfu_op6_sw(rs1, rs2)
#define cfu_op7(rs1, rs2)       cfu_op7_sw(rs1, rs2)

#else

#define cfu_op0(rs1, rs2)       cfu_op0_hw((rs1), (rs2))
#define cfu_op1(rs1, rs2)       cfu_op1_hw((rs1), (rs2))
#define cfu_op2(rs1, rs2)       cfu_op2_hw((rs1), (rs2))
#define cfu_op3(rs1, rs2)       cfu_op3_hw((rs1), (rs2))
#define cfu_op4(rs1, rs2)       cfu_op4_hw((rs1), (rs2))
#define cfu_op5(rs1, rs2)       cfu_op5_hw((rs1), (rs2))
#define cfu_op6(rs1, rs2)       cfu_op6_hw((rs1), (rs2))
#define cfu_op7(rs1, rs2)       cfu_op7_hw((rs1), (rs2))

#endif
