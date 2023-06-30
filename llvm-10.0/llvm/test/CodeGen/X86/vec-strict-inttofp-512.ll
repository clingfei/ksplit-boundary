; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx512f -O3 | FileCheck %s --check-prefixes=CHECK,NODQ-32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f -O3 | FileCheck %s --check-prefixes=CHECK,NODQ-64
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=avx512f,avx512dq -O3 | FileCheck %s --check-prefixes=CHECK,DQ,DQ-32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512f,avx512dq -O3 | FileCheck %s --check-prefixes=CHECK,DQ,DQ-64

declare <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i1(<16 x i1>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i1(<16 x i1>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i8(<16 x i8>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i8(<16 x i8>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i16(<16 x i16>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i16(<16 x i16>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i32(<16 x i32>, metadata, metadata)
declare <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i32(<16 x i32>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i1(<8 x i1>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i1(<8 x i1>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i8(<8 x i8>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i8(<8 x i8>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i16(<8 x i16>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i16(<8 x i16>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i32(<8 x i32>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i32(<8 x i32>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i64(<8 x i64>, metadata, metadata)
declare <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i64(<8 x i64>, metadata, metadata)
declare <8 x float> @llvm.experimental.constrained.sitofp.v8f32.v8i64(<8 x i64>, metadata, metadata)
declare <8 x float> @llvm.experimental.constrained.uitofp.v8f32.v8i64(<8 x i64>, metadata, metadata)

define <16 x float> @sitofp_v16i1_v16f32(<16 x i1> %x) #0 {
; CHECK-LABEL: sitofp_v16i1_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; CHECK-NEXT:    vpslld $31, %zmm0, %zmm0
; CHECK-NEXT:    vpsrad $31, %zmm0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i1(<16 x i1> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @uitofp_v16i1_v16f32(<16 x i1> %x) #0 {
; NODQ-32-LABEL: uitofp_v16i1_v16f32:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    vpand {{\.LCPI.*}}, %xmm0, %xmm0
; NODQ-32-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; NODQ-32-NEXT:    vcvtdq2ps %zmm0, %zmm0
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: uitofp_v16i1_v16f32:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; NODQ-64-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; NODQ-64-NEXT:    vcvtdq2ps %zmm0, %zmm0
; NODQ-64-NEXT:    retq
;
; DQ-32-LABEL: uitofp_v16i1_v16f32:
; DQ-32:       # %bb.0:
; DQ-32-NEXT:    vpand {{\.LCPI.*}}, %xmm0, %xmm0
; DQ-32-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; DQ-32-NEXT:    vcvtdq2ps %zmm0, %zmm0
; DQ-32-NEXT:    retl
;
; DQ-64-LABEL: uitofp_v16i1_v16f32:
; DQ-64:       # %bb.0:
; DQ-64-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; DQ-64-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; DQ-64-NEXT:    vcvtdq2ps %zmm0, %zmm0
; DQ-64-NEXT:    retq
 %result = call <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i1(<16 x i1> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @sitofp_v16i8_v16f32(<16 x i8> %x) #0 {
; CHECK-LABEL: sitofp_v16i8_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovsxbd %xmm0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i8(<16 x i8> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @uitofp_v16i8_v16f32(<16 x i8> %x) #0 {
; CHECK-LABEL: uitofp_v16i8_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxbd {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero,xmm0[8],zero,zero,zero,xmm0[9],zero,zero,zero,xmm0[10],zero,zero,zero,xmm0[11],zero,zero,zero,xmm0[12],zero,zero,zero,xmm0[13],zero,zero,zero,xmm0[14],zero,zero,zero,xmm0[15],zero,zero,zero
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i8(<16 x i8> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @sitofp_v16i16_v16f32(<16 x i16> %x) #0 {
; CHECK-LABEL: sitofp_v16i16_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovsxwd %ymm0, %zmm0
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i16(<16 x i16> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @uitofp_v16i16_v16f32(<16 x i16> %x) #0 {
; CHECK-LABEL: uitofp_v16i16_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxwd {{.*#+}} zmm0 = ymm0[0],zero,ymm0[1],zero,ymm0[2],zero,ymm0[3],zero,ymm0[4],zero,ymm0[5],zero,ymm0[6],zero,ymm0[7],zero,ymm0[8],zero,ymm0[9],zero,ymm0[10],zero,ymm0[11],zero,ymm0[12],zero,ymm0[13],zero,ymm0[14],zero,ymm0[15],zero
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i16(<16 x i16> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @sitofp_v16i32_v16f32(<16 x i32> %x) #0 {
; CHECK-LABEL: sitofp_v16i32_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvtdq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.sitofp.v16f32.v16i32(<16 x i32> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <16 x float> @uitofp_v16i32_v16f32(<16 x i32> %x) #0 {
; CHECK-LABEL: uitofp_v16i32_v16f32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvtudq2ps %zmm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <16 x float> @llvm.experimental.constrained.uitofp.v16f32.v16i32(<16 x i32> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <16 x float> %result
}

define <8 x double> @sitofp_v8i1_v8f64(<8 x i1> %x) #0 {
; CHECK-LABEL: sitofp_v8i1_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; CHECK-NEXT:    vpslld $31, %ymm0, %ymm0
; CHECK-NEXT:    vpsrad $31, %ymm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i1(<8 x i1> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @uitofp_v8i1_v8f64(<8 x i1> %x) #0 {
; NODQ-32-LABEL: uitofp_v8i1_v8f64:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    vpand {{\.LCPI.*}}, %xmm0, %xmm0
; NODQ-32-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; NODQ-32-NEXT:    vcvtdq2pd %ymm0, %zmm0
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: uitofp_v8i1_v8f64:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; NODQ-64-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; NODQ-64-NEXT:    vcvtdq2pd %ymm0, %zmm0
; NODQ-64-NEXT:    retq
;
; DQ-32-LABEL: uitofp_v8i1_v8f64:
; DQ-32:       # %bb.0:
; DQ-32-NEXT:    vpand {{\.LCPI.*}}, %xmm0, %xmm0
; DQ-32-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; DQ-32-NEXT:    vcvtdq2pd %ymm0, %zmm0
; DQ-32-NEXT:    retl
;
; DQ-64-LABEL: uitofp_v8i1_v8f64:
; DQ-64:       # %bb.0:
; DQ-64-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; DQ-64-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; DQ-64-NEXT:    vcvtdq2pd %ymm0, %zmm0
; DQ-64-NEXT:    retq
 %result = call <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i1(<8 x i1> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @sitofp_v8i8_v8f64(<8 x i8> %x) #0 {
; CHECK-LABEL: sitofp_v8i8_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovsxbd %xmm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i8(<8 x i8> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @uitofp_v8i8_v8f64(<8 x i8> %x) #0 {
; CHECK-LABEL: uitofp_v8i8_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxbd {{.*#+}} ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i8(<8 x i8> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @sitofp_v8i16_v8f64(<8 x i16> %x) #0 {
; CHECK-LABEL: sitofp_v8i16_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovsxwd %xmm0, %ymm0
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i16(<8 x i16> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @uitofp_v8i16_v8f64(<8 x i16> %x) #0 {
; CHECK-LABEL: uitofp_v8i16_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vpmovzxwd {{.*#+}} ymm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i16(<8 x i16> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @sitofp_v8i32_v8f64(<8 x i32> %x) #0 {
; CHECK-LABEL: sitofp_v8i32_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvtdq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i32(<8 x i32> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @uitofp_v8i32_v8f64(<8 x i32> %x) #0 {
; CHECK-LABEL: uitofp_v8i32_v8f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcvtudq2pd %ymm0, %zmm0
; CHECK-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i32(<8 x i32> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @sitofp_v8i64_v8f64(<8 x i64> %x) #0 {
; NODQ-32-LABEL: sitofp_v8i64_v8f64:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    pushl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_offset 8
; NODQ-32-NEXT:    .cfi_offset %ebp, -8
; NODQ-32-NEXT:    movl %esp, %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_register %ebp
; NODQ-32-NEXT:    andl $-8, %esp
; NODQ-32-NEXT:    subl $128, %esp
; NODQ-32-NEXT:    vextractf32x4 $2, %zmm0, %xmm1
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf32x4 $3, %zmm0, %xmm1
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf128 $1, %ymm0, %xmm0
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; NODQ-32-NEXT:    vmovhps {{.*#+}} xmm0 = xmm0[0,1],mem[0,1]
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl (%esp)
; NODQ-32-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; NODQ-32-NEXT:    vmovhps {{.*#+}} xmm1 = xmm1[0,1],mem[0,1]
; NODQ-32-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; NODQ-32-NEXT:    vmovhps {{.*#+}} xmm1 = xmm1[0,1],mem[0,1]
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstpl {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovsd {{.*#+}} xmm2 = mem[0],zero
; NODQ-32-NEXT:    vmovhps {{.*#+}} xmm2 = xmm2[0,1],mem[0,1]
; NODQ-32-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; NODQ-32-NEXT:    vinsertf64x4 $1, %ymm0, %zmm1, %zmm0
; NODQ-32-NEXT:    movl %ebp, %esp
; NODQ-32-NEXT:    popl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa %esp, 4
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: sitofp_v8i64_v8f64:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vextracti32x4 $3, %zmm0, %xmm1
; NODQ-64-NEXT:    vpextrq $1, %xmm1, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm2, %xmm2
; NODQ-64-NEXT:    vmovq %xmm1, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm3, %xmm1
; NODQ-64-NEXT:    vunpcklpd {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; NODQ-64-NEXT:    vextracti32x4 $2, %zmm0, %xmm2
; NODQ-64-NEXT:    vpextrq $1, %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm3, %xmm3
; NODQ-64-NEXT:    vmovq %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vunpcklpd {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; NODQ-64-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm1
; NODQ-64-NEXT:    vextracti128 $1, %ymm0, %xmm2
; NODQ-64-NEXT:    vpextrq $1, %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vmovq %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vunpcklpd {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; NODQ-64-NEXT:    vpextrq $1, %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vmovq %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2sd %rax, %xmm4, %xmm0
; NODQ-64-NEXT:    vunpcklpd {{.*#+}} xmm0 = xmm0[0],xmm3[0]
; NODQ-64-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; NODQ-64-NEXT:    vinsertf64x4 $1, %ymm1, %zmm0, %zmm0
; NODQ-64-NEXT:    retq
;
; DQ-LABEL: sitofp_v8i64_v8f64:
; DQ:       # %bb.0:
; DQ-NEXT:    vcvtqq2pd %zmm0, %zmm0
; DQ-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.sitofp.v8f64.v8i64(<8 x i64> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x double> @uitofp_v8i64_v8f64(<8 x i64> %x) #0 {
; NODQ-32-LABEL: uitofp_v8i64_v8f64:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    vpandq {{\.LCPI.*}}, %zmm0, %zmm1
; NODQ-32-NEXT:    vporq {{\.LCPI.*}}, %zmm1, %zmm1
; NODQ-32-NEXT:    vpsrlq $32, %zmm0, %zmm0
; NODQ-32-NEXT:    vporq {{\.LCPI.*}}, %zmm0, %zmm0
; NODQ-32-NEXT:    vsubpd {{\.LCPI.*}}{1to8}, %zmm0, %zmm0
; NODQ-32-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: uitofp_v8i64_v8f64:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vpandq {{.*}}(%rip){1to8}, %zmm0, %zmm1
; NODQ-64-NEXT:    vporq {{.*}}(%rip){1to8}, %zmm1, %zmm1
; NODQ-64-NEXT:    vpsrlq $32, %zmm0, %zmm0
; NODQ-64-NEXT:    vporq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; NODQ-64-NEXT:    vsubpd {{.*}}(%rip){1to8}, %zmm0, %zmm0
; NODQ-64-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; NODQ-64-NEXT:    retq
;
; DQ-LABEL: uitofp_v8i64_v8f64:
; DQ:       # %bb.0:
; DQ-NEXT:    vcvtuqq2pd %zmm0, %zmm0
; DQ-NEXT:    ret{{[l|q]}}
 %result = call <8 x double> @llvm.experimental.constrained.uitofp.v8f64.v8i64(<8 x i64> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x double> %result
}

define <8 x float> @sitofp_v8i64_v8f32(<8 x i64> %x) #0 {
; NODQ-32-LABEL: sitofp_v8i64_v8f32:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    pushl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_offset 8
; NODQ-32-NEXT:    .cfi_offset %ebp, -8
; NODQ-32-NEXT:    movl %esp, %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_register %ebp
; NODQ-32-NEXT:    andl $-8, %esp
; NODQ-32-NEXT:    subl $96, %esp
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf128 $1, %ymm0, %xmm1
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf32x4 $2, %zmm0, %xmm1
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm1[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf32x4 $3, %zmm0, %xmm0
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],mem[0],xmm0[3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],mem[0]
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fstps (%esp)
; NODQ-32-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[2,3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],mem[0]
; NODQ-32-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; NODQ-32-NEXT:    movl %ebp, %esp
; NODQ-32-NEXT:    popl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa %esp, 4
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: sitofp_v8i64_v8f32:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vextracti32x4 $2, %zmm0, %xmm1
; NODQ-64-NEXT:    vpextrq $1, %xmm1, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm2, %xmm2
; NODQ-64-NEXT:    vmovq %xmm1, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm3, %xmm1
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[2,3]
; NODQ-64-NEXT:    vextracti32x4 $3, %zmm0, %xmm2
; NODQ-64-NEXT:    vmovq %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm3, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],xmm3[0],xmm1[3]
; NODQ-64-NEXT:    vpextrq $1, %xmm2, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],xmm2[0]
; NODQ-64-NEXT:    vpextrq $1, %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vmovq %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm3[0],xmm2[0],xmm3[2,3]
; NODQ-64-NEXT:    vextracti128 $1, %ymm0, %xmm0
; NODQ-64-NEXT:    vmovq %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1],xmm3[0],xmm2[3]
; NODQ-64-NEXT:    vpextrq $1, %xmm0, %rax
; NODQ-64-NEXT:    vcvtsi2ss %rax, %xmm4, %xmm0
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm0 = xmm2[0,1,2],xmm0[0]
; NODQ-64-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; NODQ-64-NEXT:    retq
;
; DQ-LABEL: sitofp_v8i64_v8f32:
; DQ:       # %bb.0:
; DQ-NEXT:    vcvtqq2ps %zmm0, %ymm0
; DQ-NEXT:    ret{{[l|q]}}
 %result = call <8 x float> @llvm.experimental.constrained.sitofp.v8f32.v8i64(<8 x i64> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x float> %result
}

define <8 x float> @uitofp_v8i64_v8f32(<8 x i64> %x) #0 {
; NODQ-32-LABEL: uitofp_v8i64_v8f32:
; NODQ-32:       # %bb.0:
; NODQ-32-NEXT:    pushl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_offset 8
; NODQ-32-NEXT:    .cfi_offset %ebp, -8
; NODQ-32-NEXT:    movl %esp, %ebp
; NODQ-32-NEXT:    .cfi_def_cfa_register %ebp
; NODQ-32-NEXT:    andl $-8, %esp
; NODQ-32-NEXT:    subl $96, %esp
; NODQ-32-NEXT:    vmovlps %xmm0, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf128 $1, %ymm0, %xmm3
; NODQ-32-NEXT:    vmovlps %xmm3, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm3[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf32x4 $2, %zmm0, %xmm2
; NODQ-32-NEXT:    vmovlps %xmm2, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm1 = xmm2[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractf32x4 $3, %zmm0, %xmm1
; NODQ-32-NEXT:    vmovlps %xmm1, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vpermilps {{.*#+}} xmm4 = xmm1[2,3,0,1]
; NODQ-32-NEXT:    vmovlps %xmm4, {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $1, %xmm0, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps (%esp)
; NODQ-32-NEXT:    vextractps $3, %xmm0, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $1, %xmm3, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $3, %xmm3, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $1, %xmm2, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $3, %xmm2, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $1, %xmm1, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vextractps $3, %xmm1, %eax
; NODQ-32-NEXT:    shrl $31, %eax
; NODQ-32-NEXT:    fildll {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    fadds {{\.LCPI.*}}(,%eax,4)
; NODQ-32-NEXT:    fstps {{[0-9]+}}(%esp)
; NODQ-32-NEXT:    vmovss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0],mem[0],xmm0[2,3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1],mem[0],xmm0[3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm0 = xmm0[0,1,2],mem[0]
; NODQ-32-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],mem[0],xmm1[2,3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],mem[0],xmm1[3]
; NODQ-32-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],mem[0]
; NODQ-32-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; NODQ-32-NEXT:    movl %ebp, %esp
; NODQ-32-NEXT:    popl %ebp
; NODQ-32-NEXT:    .cfi_def_cfa %esp, 4
; NODQ-32-NEXT:    retl
;
; NODQ-64-LABEL: uitofp_v8i64_v8f32:
; NODQ-64:       # %bb.0:
; NODQ-64-NEXT:    vextracti32x4 $2, %zmm0, %xmm1
; NODQ-64-NEXT:    vpextrq $1, %xmm1, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm2, %xmm2
; NODQ-64-NEXT:    vmovq %xmm1, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm3, %xmm1
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[2,3]
; NODQ-64-NEXT:    vextracti32x4 $3, %zmm0, %xmm2
; NODQ-64-NEXT:    vmovq %xmm2, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm3, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1],xmm3[0],xmm1[3]
; NODQ-64-NEXT:    vpextrq $1, %xmm2, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm1 = xmm1[0,1,2],xmm2[0]
; NODQ-64-NEXT:    vpextrq $1, %xmm0, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm4, %xmm2
; NODQ-64-NEXT:    vmovq %xmm0, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm3[0],xmm2[0],xmm3[2,3]
; NODQ-64-NEXT:    vextracti128 $1, %ymm0, %xmm0
; NODQ-64-NEXT:    vmovq %xmm0, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm4, %xmm3
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm2 = xmm2[0,1],xmm3[0],xmm2[3]
; NODQ-64-NEXT:    vpextrq $1, %xmm0, %rax
; NODQ-64-NEXT:    vcvtusi2ss %rax, %xmm4, %xmm0
; NODQ-64-NEXT:    vinsertps {{.*#+}} xmm0 = xmm2[0,1,2],xmm0[0]
; NODQ-64-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; NODQ-64-NEXT:    retq
;
; DQ-LABEL: uitofp_v8i64_v8f32:
; DQ:       # %bb.0:
; DQ-NEXT:    vcvtuqq2ps %zmm0, %ymm0
; DQ-NEXT:    ret{{[l|q]}}
 %result = call <8 x float> @llvm.experimental.constrained.uitofp.v8f32.v8i64(<8 x i64> %x,
                                                              metadata !"round.dynamic",
                                                              metadata !"fpexcept.strict") #0
  ret <8 x float> %result
}

attributes #0 = { strictfp }
