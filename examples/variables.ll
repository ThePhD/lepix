; ModuleID = 'variables.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.lepix_array_n2_ = type { i8*, [2 x i64] }

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %c = alloca %struct.lepix_array_n2_, align 8
  %c_fill = alloca i32*, align 8
  %value = alloca i32, align 4
  store i32 0, i32* %1, align 4
  store i32 49, i32* %a, align 4
  %2 = load i32, i32* %a, align 4
  %3 = srem i32 %2, 8
  store i32 %3, i32* %b, align 4
  %4 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 0
  %5 = call noalias i8* @malloc(i64 48) #2
  store i8* %5, i8** %4, align 8
  %6 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 1
  %7 = getelementptr inbounds [2 x i64], [2 x i64]* %6, i64 0, i64 0
  store i64 6, i64* %7, align 8
  %8 = getelementptr inbounds i64, i64* %7, i64 1
  store i64 2, i64* %8, align 8
  %9 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 0
  %10 = load i8*, i8** %9, align 8
  %11 = bitcast i8* %10 to i32*
  store i32* %11, i32** %c_fill, align 8
  %12 = load i32*, i32** %c_fill, align 8
  %13 = getelementptr inbounds i32, i32* %12, i64 0
  store i32 0, i32* %13, align 4
  %14 = load i32*, i32** %c_fill, align 8
  %15 = getelementptr inbounds i32, i32* %14, i64 1
  store i32 2, i32* %15, align 4
  %16 = load i32*, i32** %c_fill, align 8
  %17 = getelementptr inbounds i32, i32* %16, i64 2
  store i32 4, i32* %17, align 4
  %18 = load i32*, i32** %c_fill, align 8
  %19 = getelementptr inbounds i32, i32* %18, i64 3
  store i32 6, i32* %19, align 4
  %20 = load i32*, i32** %c_fill, align 8
  %21 = getelementptr inbounds i32, i32* %20, i64 4
  store i32 8, i32* %21, align 4
  %22 = load i32*, i32** %c_fill, align 8
  %23 = getelementptr inbounds i32, i32* %22, i64 5
  store i32 10, i32* %23, align 4
  %24 = load i32*, i32** %c_fill, align 8
  %25 = getelementptr inbounds i32, i32* %24, i64 6
  store i32 1, i32* %25, align 4
  %26 = load i32*, i32** %c_fill, align 8
  %27 = getelementptr inbounds i32, i32* %26, i64 7
  store i32 3, i32* %27, align 4
  %28 = load i32*, i32** %c_fill, align 8
  %29 = getelementptr inbounds i32, i32* %28, i64 8
  store i32 5, i32* %29, align 4
  %30 = load i32*, i32** %c_fill, align 8
  %31 = getelementptr inbounds i32, i32* %30, i64 9
  store i32 7, i32* %31, align 4
  %32 = load i32*, i32** %c_fill, align 8
  %33 = getelementptr inbounds i32, i32* %32, i64 10
  store i32 9, i32* %33, align 4
  %34 = load i32*, i32** %c_fill, align 8
  %35 = getelementptr inbounds i32, i32* %34, i64 11
  store i32 11, i32* %35, align 4
  %36 = load i32, i32* %a, align 4
  %37 = load i32, i32* %b, align 4
  %38 = add nsw i32 %36, %37
  %39 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 1
  %40 = getelementptr inbounds [2 x i64], [2 x i64]* %39, i64 0, i64 0
  %41 = load i64, i64* %40, align 8
  %42 = mul nsw i64 0, %41
  %43 = add nsw i64 %42, 4
  %44 = mul i64 %43, 4
  %45 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 0
  %46 = load i8*, i8** %45, align 8
  %47 = getelementptr inbounds i8, i8* %46, i64 %44
  %48 = load i8, i8* %47, align 1
  %49 = zext i8 %48 to i32
  %50 = add nsw i32 %38, %49
  store i32 %50, i32* %value, align 4
  %51 = getelementptr inbounds %struct.lepix_array_n2_, %struct.lepix_array_n2_* %c, i32 0, i32 0
  %52 = load i8*, i8** %51, align 8
  call void @free(i8* %52) #2
  %53 = load i32, i32* %value, align 4
  ret i32 %53
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
