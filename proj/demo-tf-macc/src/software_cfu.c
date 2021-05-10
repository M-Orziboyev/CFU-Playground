/*
 * Copyright 2021 The CFU-Playground Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdint.h>
#include "cfu.h"

//
// In this function, place C code to emulate your CFU. You can switch between
// hardware and emulated CFU by setting the CFU_SOFTWARE_DEFINED DEFINE in
// the Makefile.
uint32_t software_cfu(int funct3, int funct7, uint32_t rs1, uint32_t rs2)
{
  static unsigned acc;
  static unsigned input_offset;
  unsigned acc_old  = acc;
  unsigned acc_new  = acc + rs1 * (rs2 + input_offset);
  if (funct3 == 0) {
     input_offset = rs1;
  } else if (funct3 == 1) {
     acc = rs1;
  } else if (funct3 == 2) {
     acc = acc_new;
  } else {
     ;
  }
  return acc_old;
}