; ModuleID = 'functions.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.lepix_bounds_1_ = type { i64, i64 }
%struct.lepix_array_n1_ = type { i8*, [1 x i64] }

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
define i32 @sum(i8* %arr_temp.coerce0, i64 %arr_temp.coerce1) #0 {
  %arr_temp = alloca %struct.lepix_array_n1_, align 8
  %arr = alloca %struct.lepix_array_n1_, align 8
  %x = alloca i32, align 4
  %i = alloca i32, align 4
  %1 = bitcast %struct.lepix_array_n1_* %arr_temp to { i8*, i64 }*
  %2 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %1, i32 0, i32 0
  store i8* %arr_temp.coerce0, i8** %2, align 8
  %3 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %1, i32 0, i32 1
  store i64 %arr_temp.coerce1, i64* %3, align 8
  %4 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 0
  %5 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr_temp, i32 0, i32 1
  %6 = getelementptr inbounds [1 x i64], [1 x i64]* %5, i64 0, i64 0
  %7 = load i64, i64* %6, align 8
  %8 = mul i64 %7, 4
  %9 = call noalias i8* @malloc(i64 %8) #3
  store i8* %9, i8** %4, align 8
  %10 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 1
  %11 = getelementptr inbounds [1 x i64], [1 x i64]* %10, i64 0, i64 0
  %12 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr_temp, i32 0, i32 1
  %13 = getelementptr inbounds [1 x i64], [1 x i64]* %12, i64 0, i64 0
  %14 = load i64, i64* %13, align 8
  store i64 %14, i64* %11, align 8
  %15 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 0
  %16 = load i8*, i8** %15, align 8
  %17 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr_temp, i32 0, i32 0
  %18 = load i8*, i8** %17, align 8
  %19 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr_temp, i32 0, i32 1
  %20 = getelementptr inbounds [1 x i64], [1 x i64]* %19, i64 0, i64 0
  %21 = load i64, i64* %20, align 8
  %22 = mul i64 %21, 4
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %16, i8* %18, i64 %22, i32 1, i1 false)
  store i32 0, i32* %x, align 4
  store i32 0, i32* %i, align 4
  br label %23

; <label>:23                                      ; preds = %41, %0
  %24 = load i32, i32* %i, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 1
  %27 = getelementptr inbounds [1 x i64], [1 x i64]* %26, i64 0, i64 0
  %28 = load i64, i64* %27, align 8
  %29 = icmp slt i64 %25, %28
  br i1 %29, label %30, label %44

; <label>:30                                      ; preds = %23
  %31 = load i32, i32* %i, align 4
  %32 = sext i32 %31 to i64
  %33 = mul i64 %32, 4
  %34 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 0
  %35 = load i8*, i8** %34, align 8
  %36 = getelementptr inbounds i8, i8* %35, i64 %33
  %37 = bitcast i8* %36 to i32*
  %38 = load i32, i32* %37, align 4
  %39 = load i32, i32* %x, align 4
  %40 = add nsw i32 %39, %38
  store i32 %40, i32* %x, align 4
  br label %41

; <label>:41                                      ; preds = %30
  %42 = load i32, i32* %i, align 4
  %43 = add nsw i32 %42, 1
  store i32 %43, i32* %i, align 4
  br label %23

; <label>:44                                      ; preds = %23
  %45 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %arr, i32 0, i32 0
  %46 = load i8*, i8** %45, align 8
  call void @free(i8* %46) #3
  %47 = load i32, i32* %x, align 4
  ret i32 %47
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #2

; Function Attrs: nounwind
declare void @free(i8*) #2

; Function Attrs: nounwind uwtable
define { i8*, i64 } @numbers() #0 {
  %1 = alloca %struct.lepix_array_n1_, align 8
  %tmp = alloca %struct.lepix_array_n1_, align 8
  %tmp_fill = alloca i32*, align 8
  %2 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %tmp, i32 0, i32 0
  %3 = call noalias i8* @malloc(i64 12) #3
  store i8* %3, i8** %2, align 8
  %4 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %tmp, i32 0, i32 1
  %5 = getelementptr inbounds [1 x i64], [1 x i64]* %4, i64 0, i64 0
  store i64 3, i64* %5, align 8
  %6 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %tmp, i32 0, i32 0
  %7 = load i8*, i8** %6, align 8
  %8 = bitcast i8* %7 to i32*
  store i32* %8, i32** %tmp_fill, align 8
  %9 = load i32*, i32** %tmp_fill, align 8
  %10 = getelementptr inbounds i32, i32* %9, i64 0
  store i32 1, i32* %10, align 4
  %11 = load i32*, i32** %tmp_fill, align 8
  %12 = getelementptr inbounds i32, i32* %11, i64 1
  store i32 2, i32* %12, align 4
  %13 = load i32*, i32** %tmp_fill, align 8
  %14 = getelementptr inbounds i32, i32* %13, i64 2
  store i32 3, i32* %14, align 4
  %15 = bitcast %struct.lepix_array_n1_* %1 to i8*
  %16 = bitcast %struct.lepix_array_n1_* %tmp to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %15, i8* %16, i64 16, i32 8, i1 false)
  %17 = bitcast %struct.lepix_array_n1_* %1 to { i8*, i64 }*
  %18 = load { i8*, i64 }, { i8*, i64 }* %17, align 8
  ret { i8*, i64 } %18
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %tmp1 = alloca %struct.lepix_array_n1_, align 8
  %tmp2 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  %4 = call { i8*, i64 } @numbers()
  %5 = bitcast %struct.lepix_array_n1_* %tmp1 to { i8*, i64 }*
  %6 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %5, i32 0, i32 0
  %7 = extractvalue { i8*, i64 } %4, 0
  store i8* %7, i8** %6, align 8
  %8 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %5, i32 0, i32 1
  %9 = extractvalue { i8*, i64 } %4, 1
  store i64 %9, i64* %8, align 8
  %10 = bitcast %struct.lepix_array_n1_* %tmp1 to { i8*, i64 }*
  %11 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %10, i32 0, i32 0
  %12 = load i8*, i8** %11, align 8
  %13 = getelementptr inbounds { i8*, i64 }, { i8*, i64 }* %10, i32 0, i32 1
  %14 = load i64, i64* %13, align 8
  %15 = call i32 @sum(i8* %12, i64 %14)
  store i32 %15, i32* %tmp2, align 4
  %16 = getelementptr inbounds %struct.lepix_array_n1_, %struct.lepix_array_n1_* %tmp1, i32 0, i32 0
  %17 = load i8*, i8** %16, align 8
  call void @free(i8* %17) #3
  %18 = load i32, i32* %tmp2, align 4
  ret i32 %18
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
