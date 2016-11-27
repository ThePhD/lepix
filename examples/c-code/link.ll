; ModuleID = 'link.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [17 x i8] c"./libexternal.so\00", align 1
@.str.1 = private unnamed_addr constant [9 x i8] c"ext_func\00", align 1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %libexternal = alloca i8*, align 8
  %ext_func = alloca i32 (...)*, align 8
  %v = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %2 = call i8* @dlopen(i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str, i32 0, i32 0), i32 258) #2
  store i8* %2, i8** %libexternal, align 8
  %3 = load i8*, i8** %libexternal, align 8
  %4 = call i8* @dlsym(i8* %3, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.1, i32 0, i32 0)) #2
  %5 = bitcast i32 (...)** %ext_func to i8**
  store i8* %4, i8** %5, align 8
  %6 = load i32 (...)*, i32 (...)** %ext_func, align 8
  %7 = call i32 (...) %6()
  store i32 %7, i32* %v, align 4
  %8 = load i8*, i8** %libexternal, align 8
  %9 = call i32 @dlclose(i8* %8) #2
  ret i32 0
}

; Function Attrs: nounwind
declare i8* @dlopen(i8*, i32) #1

; Function Attrs: nounwind
declare i8* @dlsym(i8*, i8*) #1

; Function Attrs: nounwind
declare i32 @dlclose(i8*) #1

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
