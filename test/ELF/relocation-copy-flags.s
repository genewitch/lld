// REQUIRES: x86

// RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
// RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %p/Inputs/relocation-copy.s -o %t2.o
// RUN: ld.lld %t2.o -o %t2.so -shared
// RUN: ld.lld %t.o %t2.so -o %t.exe
// RUN: llvm-readobj -s -section-data -r %t.exe | FileCheck %s

        .global _start
_start:
        .long x

        .section foo
        .long y

        .section bar, "aw"
        .long z

// CHECK:      Name: .text
// CHECK-NEXT: Type: SHT_PROGBITS
// CHECK-NEXT: Flags [
// CHECK-NEXT:   SHF_ALLOC
// CHECK-NEXT:   SHF_EXECINSTR
// CHECK-NEXT: ]
// CHECK-NEXT: Address: 0x11000
// CHECK-NEXT: Offset: 0x1000
// CHECK-NEXT: Size: 4
// CHECK-NEXT: Link: 0
// CHECK-NEXT: Info: 0
// CHECK-NEXT: AddressAlignment: 4
// CHECK-NEXT: EntrySize: 0
// CHECK-NEXT: SectionData (
// CHECK-NEXT:   0000: 10300100
// CHECK-NEXT: )

// CHECK:      Name: bar
// CHECK-NEXT: Type: SHT_PROGBITS
// CHECK-NEXT: Flags [
// CHECK-NEXT:   SHF_ALLOC
// CHECK-NEXT:   SHF_WRITE
// CHECK-NEXT: ]
// CHECK-NEXT: Address: 0x13000
// CHECK-NEXT: Offset: 0x3000
// CHECK-NEXT: Size: 4
// CHECK-NEXT: Link: 0
// CHECK-NEXT: Info: 0
// CHECK-NEXT: AddressAlignment: 1
// CHECK-NEXT: EntrySize: 0
// CHECK-NEXT: SectionData (
// CHECK-NEXT:   0000: 00000000
// CHECK-NEXT: )

// CHECK:      Name: foo
// CHECK-NEXT: Type: SHT_PROGBITS
// CHECK-NEXT: Flags [
// CHECK-NEXT: ]
// CHECK-NEXT: Address: 0x0
// CHECK-NEXT: Offset: 0x3004
// CHECK-NEXT: Size: 4
// CHECK-NEXT: Link: 0
// CHECK-NEXT: Info: 0
// CHECK-NEXT: AddressAlignment: 1
// CHECK-NEXT: EntrySize: 0
// CHECK-NEXT: SectionData (
// CHECK-NEXT:   0000: 00000000
// CHECK-NEXT: )

// CHECK:      Relocations [
// CHECK-NEXT:   Section (4) .rela.dyn {
// CHECK-NEXT:     0x13010 R_X86_64_COPY x 0x0
// CHECK-NEXT:     0x13000 R_X86_64_32 z 0x0
// CHECK-NEXT:   }
// CHECK-NEXT: ]
