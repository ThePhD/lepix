; ModuleID = 'hello_world_array_slice.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.lepix_bounds_1_ = type { i64, i64 }
%struct.lepix_array_n2_ = type { i8*, [2 x i64] }
%struct.lepix_array_n1_ = type { i8*, [1 x i64] }

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1

; Function Attrs: nounwind uwtable
define { i64, i64 } @lepix_lib_bounds_for_1(i64 %threadindex, i64 %threadcount, i64 %dimension) #0 {
  %1 = alloca %struct.lepix_bounds_1_, align 8
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %c = alloca %struct.lepix_bounds_1_, align 8
  store i64 %threadindex, i64* %2, align 8
  store i64 %threadcount, i64* %3, align 8
  store i64 %dimension, i64* %4, align 8
  %5 = load i64, i64* %4, align 8
  %6 = load i64, i64* %3, align 8
  %7 = sdiv i64 %5, %6
  %8 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  store i64 %7, i64* %8, align 8
  %9 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  %10 = load i64, i64* %9, align 8
  %11 = icmp eq i64 %10, 0
  br i1 %11, label %12, label %15

; <label>:12                                      ; preds = %0
  %13 = load i64, i64* %4, align 8
  %14 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  store i64 %13, i64* %14, align 8
  br label %15

; <label>:15                                      ; preds = %12, %0
  %16 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  %17 = load i64, i64* %16, align 8
  %18 = load i64, i64* %2, align 8
  %19 = mul nsw i64 %17, %18
  %20 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 0
  store i64 %19, i64* %20, align 8
  %21 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 0
  %22 = load i64, i64* %21, align 8
  %23 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  %24 = load i64, i64* %23, align 8
  %25 = add nsw i64 %22, %24
  %26 = load i64, i64* %4, align 8
  %27 = icmp sgt i64 %25, %26
  br i1 %27, label %28, label %34

; <label>:28                                      ; preds = %15
  %29 = load i64, i64* %4, align 8
  %30 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  %31 = load i64, i64* %30, align 8
  %32 = sub nsw i64 %29, %31
  %33 = getelementptr inbounds %struct.lepix_bounds_1_, %struct.lepix_bounds_1_* %c, i32 0, i32 1
  store i64 %32, i64* %33, align 8
  br label %34

; <label>:34                                      ; preds = %28, %15
  %35 = bitcast %struct.lepix_bounds_1_* %1 to i8*
  %36 = bitcast %struct.lepix_bounds_1_* %c to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %35, i8* %36, i64 16, i32 8, i1 false)
  %37 = bitcast %struct.lepix_bounds_1_* %1 to { i64, i64 }*
  %38 = load { i64, i64 }, { i64, i64 }* %37, align 8
  ret { i64, i64 } %38
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32, i1) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %x = alloca %struct.lepix_array_n2_, align 8
  %y = alloca %struct.lepix_array_n1_, align 8
  %z = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %x, i32 0, i32 0
  %3 = call noalias i8* @malloc(i64 16) #4
  store i8* %3, i8** %2, align 8
  %4 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %x, i32 0, i32 1
  %5 = getelementptr inbounds [2 x i64], [2 x i64]* %4, i64 0, i64 0
  store i64 1, i64* %5, align 8
  %6 = getelementptr inbounds i64, i64* %5, i64 1
  store i64 4, i64* %6, align 8
  %7 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %y, i32 0, i32 0
  %8 = call noalias i8* @malloc(i64 4) #4
  store i8* %8, i8** %7, align 8
  %9 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %y, i32 0, i32 1
  %10 = getelementptr inbounds [1 x i64], [1 x i64]* %9, i64 0, i64 0
  store i64 1, i64* %10, align 8
  %11 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %x, i32 0, i32 1
  %12 = getelementptr inbounds [2 x i64], [2 x i64]* %11, i64 0, i64 0
  %13 = load i64, i64* %12, align 8
  %14 = mul nsw i64 3, %13
  %15 = add nsw i64 %14, 0
  %16 = mul i64 %15, 4
  %17 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %x, i32 0, i32 0
  %18 = load i8*, i8** %17, align 8
  %19 = getelementptr inbounds i8, i8* %18, i64 %16
  %20 = bitcast i8* %19 to i32*
  %21 = load i32, i32* %20, align 4
  store i32 %21, i32* %z, align 4
  %22 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %y, i32 0, i32 0
  %23 = load i8*, i8** %22, align 8
  %24 = getelementptr inbounds i8, i8* %23, i64 0
  %25 = load i8, i8* %24, align 1
  %26 = zext i8 %25 to i32
  %27 = load i32, i32* %z, align 4
  %28 = add nsw i32 %26, %27
  %29 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i32 0, i32 0), i32 %28)
  %30 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %x, i32 0, i32 0
  %31 = load i8*, i8** %30, align 8
  call void @free(i8* %31) #4
  %32 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %y, i32 0, i32 0
  %33 = load i8*, i8** %32, align 8
  call void @free(i8* %33) #4
  ret i32 0
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: nounwind
declare void @free(i8*) #2

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
