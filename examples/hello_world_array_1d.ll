; ModuleID = 'hello_world_array_1d.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.lepix_bounds_1_ = type { i64, i64 }
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
define i32 @main(i32 %argc, i8** %arv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %x = alloca %struct.lepix_array_n1_, align 8
  %x_fill = alloca i32*, align 8
  store i32 0, i32* %1, align 4
  store i32 %argc, i32* %2, align 4
  store i8** %arv, i8*** %3, align 8
  %4 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %x, i32 0, i32 0
  %5 = call noalias i8* @malloc(i64 16) #4
  store i8* %5, i8** %4, align 8
  %6 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %x, i32 0, i32 1
  %7 = getelementptr inbounds [1 x i64], [1 x i64]* %6, i64 0, i64 0
  store i64 4, i64* %7, align 8
  %8 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %x, i32 0, i32 0
  %9 = load i8*, i8** %8, align 8
  %10 = bitcast i8* %9 to i32*
  store i32* %10, i32** %x_fill, align 8
  %11 = load i32*, i32** %x_fill, align 8
  %12 = getelementptr inbounds i32, i32* %11, i64 0
  store i32 11, i32* %12, align 4
  %13 = load i32*, i32** %x_fill, align 8
  %14 = getelementptr inbounds i32, i32* %13, i64 1
  store i32 22, i32* %14, align 4
  %15 = load i32*, i32** %x_fill, align 8
  %16 = getelementptr inbounds i32, i32* %15, i64 2
  store i32 44, i32* %16, align 4
  %17 = load i32*, i32** %x_fill, align 8
  %18 = getelementptr inbounds i32, i32* %17, i64 3
  store i32 88, i32* %18, align 4
  %19 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %x, i32 0, i32 0
  %20 = load i8*, i8** %19, align 8
  %21 = getelementptr inbounds i8, i8* %20, i64 12
  %22 = bitcast i8* %21 to i32*
  %23 = load i32, i32* %22, align 4
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i32 0, i32 0), i32 %23)
  %25 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %x, i32 0, i32 0
  %26 = load i8*, i8** %25, align 8
  call void @free(i8* %26) #4
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
