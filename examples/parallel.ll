; ModuleID = 'parallel.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.lepix_thread_pool_ = type { %struct.lepix_thread_handle_*, i64 }
%struct.lepix_thread_handle_ = type { i64, %union.pthread_attr_t, %union.pthread_condattr_t, %union.pthread_cond_t, %union.pthread_mutexattr_t, %union.pthread_mutex_t, %union.pthread_condattr_t, %union.pthread_cond_t, %union.pthread_mutexattr_t, %union.pthread_mutex_t, i64, %struct.lepix_parallel_transfer_* }
%union.pthread_attr_t = type { i64, [48 x i8] }
%union.pthread_condattr_t = type { i32 }
%union.pthread_cond_t = type { %struct.anon }
%struct.anon = type { i32, i32, i64, i64, i64, i8*, i32, i32 }
%union.pthread_mutexattr_t = type { i32 }
%union.pthread_mutex_t = type { %struct.__pthread_mutex_s }
%struct.__pthread_mutex_s = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list }
%struct.__pthread_internal_list = type { %struct.__pthread_internal_list*, %struct.__pthread_internal_list* }
%struct.lepix_parallel_transfer_ = type { void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, i8, i64, i64, i64, i64, i8**, i64, %union.pthread_mutex_t, %union.pthread_mutexattr_t }
%struct.local_work = type { %union.pthread_mutex_t*, %union.pthread_cond_t*, %struct.lepix_parallel_transfer_ }

@lepix_pool_ = common global %struct.lepix_thread_pool_ zeroinitializer, align 8

; Function Attrs: nounwind uwtable
define void @lepix_create_parallel_transfer_(%struct.lepix_parallel_transfer_* %transfer, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %work, i64 %invocation_id, i64 %invocation_count, i64 %work_index, i64 %work_count, i8** %locals, i64 %locals_size) #0 {
  %1 = alloca %struct.lepix_parallel_transfer_*, align 8
  %2 = alloca void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca i8**, align 8
  %8 = alloca i64, align 8
  store %struct.lepix_parallel_transfer_* %transfer, %struct.lepix_parallel_transfer_** %1, align 8
  store void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %work, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %2, align 8
  store i64 %invocation_id, i64* %3, align 8
  store i64 %invocation_count, i64* %4, align 8
  store i64 %work_index, i64* %5, align 8
  store i64 %work_count, i64* %6, align 8
  store i8** %locals, i8*** %7, align 8
  store i64 %locals_size, i64* %8, align 8
  %9 = load void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %2, align 8
  %10 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %11 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %10, i32 0, i32 0
  store void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %9, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %11, align 8
  %12 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %13 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %12, i32 0, i32 1
  store i8 0, i8* %13, align 8
  %14 = load i64, i64* %5, align 8
  %15 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %16 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %15, i32 0, i32 2
  store i64 %14, i64* %16, align 8
  %17 = load i64, i64* %6, align 8
  %18 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %19 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %18, i32 0, i32 3
  store i64 %17, i64* %19, align 8
  %20 = load i64, i64* %3, align 8
  %21 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %22 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %21, i32 0, i32 4
  store i64 %20, i64* %22, align 8
  %23 = load i64, i64* %4, align 8
  %24 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %25 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %24, i32 0, i32 5
  store i64 %23, i64* %25, align 8
  %26 = load i8**, i8*** %7, align 8
  %27 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %28 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %27, i32 0, i32 6
  store i8** %26, i8*** %28, align 8
  %29 = load i64, i64* %8, align 8
  %30 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %31 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %30, i32 0, i32 7
  store i64 %29, i64* %31, align 8
  %32 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %33 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %32, i32 0, i32 9
  %34 = call i32 @pthread_mutexattr_init(%union.pthread_mutexattr_t* %33) #4
  %35 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %36 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %35, i32 0, i32 8
  %37 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %38 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %37, i32 0, i32 9
  %39 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* %36, %union.pthread_mutexattr_t* %38) #4
  ret void
}

; Function Attrs: nounwind
declare i32 @pthread_mutexattr_init(%union.pthread_mutexattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_init(%union.pthread_mutex_t*, %union.pthread_mutexattr_t*) #1

; Function Attrs: nounwind uwtable
define void @lepix_parallel_transfer_dead_(%struct.lepix_parallel_transfer_* %transfer) #0 {
  %1 = alloca %struct.lepix_parallel_transfer_*, align 8
  store %struct.lepix_parallel_transfer_* %transfer, %struct.lepix_parallel_transfer_** %1, align 8
  %2 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  call void @lepix_create_parallel_transfer_(%struct.lepix_parallel_transfer_* %2, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* null, i64 0, i64 0, i64 0, i64 0, i8** null, i64 0)
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @lepix_hardware_concurrency_() #0 {
  ret i64 2
}

; Function Attrs: nounwind uwtable
define i64 @lepix_concurrency_multiplicity_() #0 {
  ret i64 1
}

; Function Attrs: nounwind uwtable
define void @lepix_create_pool_(%struct.lepix_thread_pool_* %pool) #0 {
  %1 = alloca %struct.lepix_thread_pool_*, align 8
  %i = alloca i32, align 4
  %handle = alloca %struct.lepix_thread_handle_*, align 8
  %readywaitmutexattr = alloca %union.pthread_mutexattr_t*, align 8
  %readywaitattr = alloca %union.pthread_condattr_t*, align 8
  %readywaitmutex = alloca %union.pthread_mutex_t*, align 8
  %readywait = alloca %union.pthread_cond_t*, align 8
  %completedwaitmutexattr = alloca %union.pthread_mutexattr_t*, align 8
  %completedwaitattr = alloca %union.pthread_condattr_t*, align 8
  %completedwaitmutex = alloca %union.pthread_mutex_t*, align 8
  %completedwait = alloca %union.pthread_cond_t*, align 8
  %attr = alloca %union.pthread_attr_t*, align 8
  %t = alloca i64*, align 8
  store %struct.lepix_thread_pool_* %pool, %struct.lepix_thread_pool_** %1, align 8
  %2 = call i64 @lepix_hardware_concurrency_()
  %3 = call i64 @lepix_concurrency_multiplicity_()
  %4 = mul nsw i64 %2, %3
  %5 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %6 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %5, i32 0, i32 1
  store i64 %4, i64* %6, align 8
  %7 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %8 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %7, i32 0, i32 1
  %9 = load i64, i64* %8, align 8
  %10 = mul i64 288, %9
  %11 = call noalias i8* @malloc(i64 %10) #4
  %12 = bitcast i8* %11 to %struct.lepix_thread_handle_*
  %13 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %14 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %13, i32 0, i32 0
  store %struct.lepix_thread_handle_* %12, %struct.lepix_thread_handle_** %14, align 8
  store i32 0, i32* %i, align 4
  br label %15

; <label>:15                                      ; preds = %80, %0
  %16 = load i32, i32* %i, align 4
  %17 = sext i32 %16 to i64
  %18 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %19 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %18, i32 0, i32 1
  %20 = load i64, i64* %19, align 8
  %21 = icmp slt i64 %17, %20
  br i1 %21, label %22, label %83

; <label>:22                                      ; preds = %15
  %23 = load i32, i32* %i, align 4
  %24 = sext i32 %23 to i64
  %25 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %26 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %25, i32 0, i32 0
  %27 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %26, align 8
  %28 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %27, i64 %24
  store %struct.lepix_thread_handle_* %28, %struct.lepix_thread_handle_** %handle, align 8
  %29 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %30 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %29, i32 0, i32 11
  store %struct.lepix_parallel_transfer_* null, %struct.lepix_parallel_transfer_** %30, align 8
  %31 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %32 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %31, i32 0, i32 4
  store %union.pthread_mutexattr_t* %32, %union.pthread_mutexattr_t** %readywaitmutexattr, align 8
  %33 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %34 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %33, i32 0, i32 2
  store %union.pthread_condattr_t* %34, %union.pthread_condattr_t** %readywaitattr, align 8
  %35 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %36 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %35, i32 0, i32 5
  store %union.pthread_mutex_t* %36, %union.pthread_mutex_t** %readywaitmutex, align 8
  %37 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %38 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %37, i32 0, i32 3
  store %union.pthread_cond_t* %38, %union.pthread_cond_t** %readywait, align 8
  %39 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %40 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %39, i32 0, i32 8
  store %union.pthread_mutexattr_t* %40, %union.pthread_mutexattr_t** %completedwaitmutexattr, align 8
  %41 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %42 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %41, i32 0, i32 6
  store %union.pthread_condattr_t* %42, %union.pthread_condattr_t** %completedwaitattr, align 8
  %43 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %44 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %43, i32 0, i32 9
  store %union.pthread_mutex_t* %44, %union.pthread_mutex_t** %completedwaitmutex, align 8
  %45 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %46 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %45, i32 0, i32 7
  store %union.pthread_cond_t* %46, %union.pthread_cond_t** %completedwait, align 8
  %47 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %48 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %47, i32 0, i32 1
  store %union.pthread_attr_t* %48, %union.pthread_attr_t** %attr, align 8
  %49 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %50 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %49, i32 0, i32 0
  store i64* %50, i64** %t, align 8
  %51 = load %union.pthread_attr_t*, %union.pthread_attr_t** %attr, align 8
  %52 = call i32 @pthread_attr_init(%union.pthread_attr_t* %51) #4
  %53 = load %union.pthread_attr_t*, %union.pthread_attr_t** %attr, align 8
  %54 = call i32 @pthread_attr_setdetachstate(%union.pthread_attr_t* %53, i32 0) #4
  %55 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %readywaitattr, align 8
  %56 = call i32 @pthread_condattr_init(%union.pthread_condattr_t* %55) #4
  %57 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %readywaitmutexattr, align 8
  %58 = call i32 @pthread_mutexattr_init(%union.pthread_mutexattr_t* %57) #4
  %59 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %readywaitmutex, align 8
  %60 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %readywaitmutexattr, align 8
  %61 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* %59, %union.pthread_mutexattr_t* %60) #4
  %62 = load %union.pthread_cond_t*, %union.pthread_cond_t** %readywait, align 8
  %63 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %readywaitattr, align 8
  %64 = call i32 @pthread_cond_init(%union.pthread_cond_t* %62, %union.pthread_condattr_t* %63) #4
  %65 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %completedwaitattr, align 8
  %66 = call i32 @pthread_condattr_init(%union.pthread_condattr_t* %65) #4
  %67 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %completedwaitmutexattr, align 8
  %68 = call i32 @pthread_mutexattr_init(%union.pthread_mutexattr_t* %67) #4
  %69 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %completedwaitmutex, align 8
  %70 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %completedwaitmutexattr, align 8
  %71 = call i32 @pthread_mutex_init(%union.pthread_mutex_t* %69, %union.pthread_mutexattr_t* %70) #4
  %72 = load %union.pthread_cond_t*, %union.pthread_cond_t** %completedwait, align 8
  %73 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %completedwaitattr, align 8
  %74 = call i32 @pthread_cond_init(%union.pthread_cond_t* %72, %union.pthread_condattr_t* %73) #4
  %75 = load i64*, i64** %t, align 8
  %76 = load %union.pthread_attr_t*, %union.pthread_attr_t** %attr, align 8
  %77 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %78 = bitcast %struct.lepix_thread_handle_* %77 to i8*
  %79 = call i32 @pthread_create(i64* %75, %union.pthread_attr_t* %76, i8* (i8*)* @lepix_thread_work_spin_, i8* %78) #4
  br label %80

; <label>:80                                      ; preds = %22
  %81 = load i32, i32* %i, align 4
  %82 = add nsw i32 %81, 1
  store i32 %82, i32* %i, align 4
  br label %15

; <label>:83                                      ; preds = %15
  ret void
}

; Function Attrs: nounwind
declare noalias i8* @malloc(i64) #1

; Function Attrs: nounwind
declare i32 @pthread_attr_init(%union.pthread_attr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_attr_setdetachstate(%union.pthread_attr_t*, i32) #1

; Function Attrs: nounwind
declare i32 @pthread_condattr_init(%union.pthread_condattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_cond_init(%union.pthread_cond_t*, %union.pthread_condattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*) #1

; Function Attrs: nounwind uwtable
define i8* @lepix_thread_work_spin_(i8* %h) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i8*, align 8
  %handle = alloca %struct.lepix_thread_handle_*, align 8
  %result = alloca i32, align 4
  %transfer = alloca %struct.lepix_parallel_transfer_*, align 8
  store i8* %h, i8** %2, align 8
  %3 = load i8*, i8** %2, align 8
  %4 = bitcast i8* %3 to %struct.lepix_thread_handle_*
  store %struct.lepix_thread_handle_* %4, %struct.lepix_thread_handle_** %handle, align 8
  store i32 0, i32* %result, align 4
  br label %5

; <label>:5                                       ; preds = %46, %30, %0
  %6 = load i32, i32* %result, align 4
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %71

; <label>:8                                       ; preds = %5
  %9 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %10 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %9, i32 0, i32 5
  %11 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* %10) #4
  %12 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %13 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %12, i32 0, i32 11
  %14 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %13, align 8
  %15 = icmp eq %struct.lepix_parallel_transfer_* %14, null
  br i1 %15, label %16, label %22

; <label>:16                                      ; preds = %8
  %17 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %18 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %17, i32 0, i32 3
  %19 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %20 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %19, i32 0, i32 5
  %21 = call i32 @pthread_cond_wait(%union.pthread_cond_t* %18, %union.pthread_mutex_t* %20)
  store i32 %21, i32* %result, align 4
  br label %22

; <label>:22                                      ; preds = %16, %8
  %23 = load i32, i32* %result, align 4
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %30, label %25

; <label>:25                                      ; preds = %22
  %26 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %27 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %26, i32 0, i32 11
  %28 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %27, align 8
  %29 = icmp eq %struct.lepix_parallel_transfer_* %28, null
  br i1 %29, label %30, label %34

; <label>:30                                      ; preds = %25, %22
  %31 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %32 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %31, i32 0, i32 5
  %33 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %32) #4
  br label %5

; <label>:34                                      ; preds = %25
  %35 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %36 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %35, i32 0, i32 11
  %37 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %36, align 8
  %38 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %37, i32 0, i32 0
  %39 = load void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %38, align 8
  %40 = icmp eq void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %39, null
  br i1 %40, label %41, label %45

; <label>:41                                      ; preds = %34
  %42 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %43 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %42, i32 0, i32 5
  %44 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %43) #4
  br label %71

; <label>:45                                      ; preds = %34
  br label %46

; <label>:46                                      ; preds = %45
  %47 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %48 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %47, i32 0, i32 11
  %49 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %48, align 8
  store %struct.lepix_parallel_transfer_* %49, %struct.lepix_parallel_transfer_** %transfer, align 8
  %50 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %51 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %50, i32 0, i32 5
  %52 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %51) #4
  %53 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer, align 8
  %54 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %53, i32 0, i32 0
  %55 = load void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %54, align 8
  %56 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer, align 8
  %57 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  call void %55(%struct.lepix_parallel_transfer_* %56, %struct.lepix_thread_handle_* %57)
  %58 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %59 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %58, i32 0, i32 9
  %60 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* %59) #4
  %61 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %62 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %61, i32 0, i32 11
  store %struct.lepix_parallel_transfer_* null, %struct.lepix_parallel_transfer_** %62, align 8
  %63 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer, align 8
  %64 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %63, i32 0, i32 1
  store i8 1, i8* %64, align 8
  %65 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %66 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %65, i32 0, i32 7
  %67 = call i32 @pthread_cond_signal(%union.pthread_cond_t* %66) #4
  %68 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %69 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %68, i32 0, i32 9
  %70 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %69) #4
  br label %5

; <label>:71                                      ; preds = %41, %5
  call void @pthread_exit(i8* null) #5
  unreachable
                                                  ; No predecessors!
  %73 = load i8*, i8** %1, align 8
  ret i8* %73
}

; Function Attrs: nounwind uwtable
define void @lepix_destroy_pool_(%struct.lepix_thread_pool_* %pool) #0 {
  %1 = alloca %struct.lepix_thread_pool_*, align 8
  %dead_transfers = alloca %struct.lepix_parallel_transfer_*, align 8
  %i = alloca i32, align 4
  %handle = alloca %struct.lepix_thread_handle_*, align 8
  %dead_transfer = alloca %struct.lepix_parallel_transfer_*, align 8
  %t = alloca i64*, align 8
  %i1 = alloca i32, align 4
  %handle2 = alloca %struct.lepix_thread_handle_*, align 8
  %readywaitmutexattr = alloca %union.pthread_mutexattr_t*, align 8
  %readywaitattr = alloca %union.pthread_condattr_t*, align 8
  %readywaitmutex = alloca %union.pthread_mutex_t*, align 8
  %readywait = alloca %union.pthread_cond_t*, align 8
  %completedwaitmutexattr = alloca %union.pthread_mutexattr_t*, align 8
  %completedwaitattr = alloca %union.pthread_condattr_t*, align 8
  %completedwaitmutex = alloca %union.pthread_mutex_t*, align 8
  %completedwait = alloca %union.pthread_cond_t*, align 8
  %attr = alloca %union.pthread_attr_t*, align 8
  store %struct.lepix_thread_pool_* %pool, %struct.lepix_thread_pool_** %1, align 8
  %2 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %3 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %2, i32 0, i32 1
  %4 = load i64, i64* %3, align 8
  %5 = mul i64 112, %4
  %6 = call noalias i8* @malloc(i64 %5) #4
  %7 = bitcast i8* %6 to %struct.lepix_parallel_transfer_*
  store %struct.lepix_parallel_transfer_* %7, %struct.lepix_parallel_transfer_** %dead_transfers, align 8
  store i32 0, i32* %i, align 4
  br label %8

; <label>:8                                       ; preds = %38, %0
  %9 = load i32, i32* %i, align 4
  %10 = sext i32 %9 to i64
  %11 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %12 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %11, i32 0, i32 1
  %13 = load i64, i64* %12, align 8
  %14 = icmp slt i64 %10, %13
  br i1 %14, label %15, label %41

; <label>:15                                      ; preds = %8
  %16 = load i32, i32* %i, align 4
  %17 = sext i32 %16 to i64
  %18 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %19 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %18, i32 0, i32 0
  %20 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %19, align 8
  %21 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %20, i64 %17
  store %struct.lepix_thread_handle_* %21, %struct.lepix_thread_handle_** %handle, align 8
  %22 = load i32, i32* %i, align 4
  %23 = sext i32 %22 to i64
  %24 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %dead_transfers, align 8
  %25 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %24, i64 %23
  store %struct.lepix_parallel_transfer_* %25, %struct.lepix_parallel_transfer_** %dead_transfer, align 8
  %26 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %dead_transfer, align 8
  call void @lepix_parallel_transfer_dead_(%struct.lepix_parallel_transfer_* %26)
  %27 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %28 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %27, i32 0, i32 0
  store i64* %28, i64** %t, align 8
  %29 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %dead_transfer, align 8
  %30 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %31 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %30, i32 0, i32 11
  store %struct.lepix_parallel_transfer_* %29, %struct.lepix_parallel_transfer_** %31, align 8
  %32 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %33 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %32, i32 0, i32 3
  %34 = call i32 @pthread_cond_signal(%union.pthread_cond_t* %33) #4
  %35 = load i64*, i64** %t, align 8
  %36 = load i64, i64* %35, align 8
  %37 = call i32 @pthread_join(i64 %36, i8** null)
  br label %38

; <label>:38                                      ; preds = %15
  %39 = load i32, i32* %i, align 4
  %40 = add nsw i32 %39, 1
  store i32 %40, i32* %i, align 4
  br label %8

; <label>:41                                      ; preds = %8
  %42 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %dead_transfers, align 8
  %43 = bitcast %struct.lepix_parallel_transfer_* %42 to i8*
  call void @free(i8* %43) #4
  store i32 0, i32* %i1, align 4
  br label %44

; <label>:44                                      ; preds = %94, %41
  %45 = load i32, i32* %i1, align 4
  %46 = sext i32 %45 to i64
  %47 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %48 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %47, i32 0, i32 1
  %49 = load i64, i64* %48, align 8
  %50 = icmp slt i64 %46, %49
  br i1 %50, label %51, label %97

; <label>:51                                      ; preds = %44
  %52 = load i32, i32* %i1, align 4
  %53 = sext i32 %52 to i64
  %54 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %55 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %54, i32 0, i32 0
  %56 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %55, align 8
  %57 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %56, i64 %53
  store %struct.lepix_thread_handle_* %57, %struct.lepix_thread_handle_** %handle2, align 8
  %58 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %59 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %58, i32 0, i32 4
  store %union.pthread_mutexattr_t* %59, %union.pthread_mutexattr_t** %readywaitmutexattr, align 8
  %60 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %61 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %60, i32 0, i32 2
  store %union.pthread_condattr_t* %61, %union.pthread_condattr_t** %readywaitattr, align 8
  %62 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %63 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %62, i32 0, i32 5
  store %union.pthread_mutex_t* %63, %union.pthread_mutex_t** %readywaitmutex, align 8
  %64 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %65 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %64, i32 0, i32 3
  store %union.pthread_cond_t* %65, %union.pthread_cond_t** %readywait, align 8
  %66 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %67 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %66, i32 0, i32 8
  store %union.pthread_mutexattr_t* %67, %union.pthread_mutexattr_t** %completedwaitmutexattr, align 8
  %68 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %69 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %68, i32 0, i32 6
  store %union.pthread_condattr_t* %69, %union.pthread_condattr_t** %completedwaitattr, align 8
  %70 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %71 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %70, i32 0, i32 9
  store %union.pthread_mutex_t* %71, %union.pthread_mutex_t** %completedwaitmutex, align 8
  %72 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %73 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %72, i32 0, i32 7
  store %union.pthread_cond_t* %73, %union.pthread_cond_t** %completedwait, align 8
  %74 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle2, align 8
  %75 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %74, i32 0, i32 1
  store %union.pthread_attr_t* %75, %union.pthread_attr_t** %attr, align 8
  %76 = load %union.pthread_cond_t*, %union.pthread_cond_t** %readywait, align 8
  %77 = call i32 @pthread_cond_destroy(%union.pthread_cond_t* %76) #4
  %78 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %readywaitmutex, align 8
  %79 = call i32 @pthread_mutex_destroy(%union.pthread_mutex_t* %78) #4
  %80 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %readywaitmutexattr, align 8
  %81 = call i32 @pthread_mutexattr_destroy(%union.pthread_mutexattr_t* %80) #4
  %82 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %readywaitattr, align 8
  %83 = call i32 @pthread_condattr_destroy(%union.pthread_condattr_t* %82) #4
  %84 = load %union.pthread_cond_t*, %union.pthread_cond_t** %completedwait, align 8
  %85 = call i32 @pthread_cond_destroy(%union.pthread_cond_t* %84) #4
  %86 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %completedwaitmutex, align 8
  %87 = call i32 @pthread_mutex_destroy(%union.pthread_mutex_t* %86) #4
  %88 = load %union.pthread_mutexattr_t*, %union.pthread_mutexattr_t** %completedwaitmutexattr, align 8
  %89 = call i32 @pthread_mutexattr_destroy(%union.pthread_mutexattr_t* %88) #4
  %90 = load %union.pthread_condattr_t*, %union.pthread_condattr_t** %completedwaitattr, align 8
  %91 = call i32 @pthread_condattr_destroy(%union.pthread_condattr_t* %90) #4
  %92 = load %union.pthread_attr_t*, %union.pthread_attr_t** %attr, align 8
  %93 = call i32 @pthread_attr_destroy(%union.pthread_attr_t* %92) #4
  br label %94

; <label>:94                                      ; preds = %51
  %95 = load i32, i32* %i1, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, i32* %i1, align 4
  br label %44

; <label>:97                                      ; preds = %44
  ret void
}

; Function Attrs: nounwind
declare i32 @pthread_cond_signal(%union.pthread_cond_t*) #1

declare i32 @pthread_join(i64, i8**) #2

; Function Attrs: nounwind
declare void @free(i8*) #1

; Function Attrs: nounwind
declare i32 @pthread_cond_destroy(%union.pthread_cond_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_destroy(%union.pthread_mutex_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutexattr_destroy(%union.pthread_mutexattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_condattr_destroy(%union.pthread_condattr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_attr_destroy(%union.pthread_attr_t*) #1

; Function Attrs: nounwind
declare i32 @pthread_mutex_lock(%union.pthread_mutex_t*) #1

declare i32 @pthread_cond_wait(%union.pthread_cond_t*, %union.pthread_mutex_t*) #2

; Function Attrs: nounwind
declare i32 @pthread_mutex_unlock(%union.pthread_mutex_t*) #1

; Function Attrs: noreturn
declare void @pthread_exit(i8*) #3

; Function Attrs: nounwind uwtable
define void @lepix_launch_parallel_work_(%struct.lepix_thread_pool_* %pool, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %func, i64 %invocations, i8** %locals, i64 %locals_size) #0 {
  %1 = alloca %struct.lepix_thread_pool_*, align 8
  %2 = alloca void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i8**, align 8
  %5 = alloca i64, align 8
  %local_work_size = alloca i32, align 4
  %local_work_list = alloca %struct.local_work*, align 8
  %inv = alloca i64, align 8
  %dispatched = alloca i64, align 8
  %i = alloca i64, align 8
  %handle = alloca %struct.lepix_thread_handle_*, align 8
  %work = alloca %struct.local_work*, align 8
  %transfer = alloca %struct.lepix_parallel_transfer_*, align 8
  %i1 = alloca i64, align 8
  %work2 = alloca %struct.local_work*, align 8
  %transfer3 = alloca %struct.lepix_parallel_transfer_*, align 8
  store %struct.lepix_thread_pool_* %pool, %struct.lepix_thread_pool_** %1, align 8
  store void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %func, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %2, align 8
  store i64 %invocations, i64* %3, align 8
  store i8** %locals, i8*** %4, align 8
  store i64 %locals_size, i64* %5, align 8
  %6 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %7 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %6, i32 0, i32 1
  %8 = load i64, i64* %7, align 8
  %9 = trunc i64 %8 to i32
  store i32 %9, i32* %local_work_size, align 4
  %10 = load i32, i32* %local_work_size, align 4
  %11 = sext i32 %10 to i64
  %12 = mul i64 128, %11
  %13 = call noalias i8* @malloc(i64 %12) #4
  %14 = bitcast i8* %13 to %struct.local_work*
  store %struct.local_work* %14, %struct.local_work** %local_work_list, align 8
  %15 = load i64, i64* %3, align 8
  %16 = icmp eq i64 %15, 0
  br i1 %16, label %17, label %20

; <label>:17                                      ; preds = %0
  %18 = load i32, i32* %local_work_size, align 4
  %19 = sext i32 %18 to i64
  store i64 %19, i64* %3, align 8
  br label %20

; <label>:20                                      ; preds = %17, %0
  store i64 0, i64* %inv, align 8
  br label %21

; <label>:21                                      ; preds = %123, %20
  %22 = load i64, i64* %inv, align 8
  %23 = load i64, i64* %3, align 8
  %24 = icmp slt i64 %22, %23
  br i1 %24, label %25, label %124

; <label>:25                                      ; preds = %21
  store i64 0, i64* %dispatched, align 8
  store i64 0, i64* %i, align 8
  br label %26

; <label>:26                                      ; preds = %77, %25
  %27 = load i64, i64* %i, align 8
  %28 = load i32, i32* %local_work_size, align 4
  %29 = sext i32 %28 to i64
  %30 = icmp slt i64 %27, %29
  br i1 %30, label %31, label %35

; <label>:31                                      ; preds = %26
  %32 = load i64, i64* %inv, align 8
  %33 = load i64, i64* %3, align 8
  %34 = icmp slt i64 %32, %33
  br label %35

; <label>:35                                      ; preds = %31, %26
  %36 = phi i1 [ false, %26 ], [ %34, %31 ]
  br i1 %36, label %37, label %84

; <label>:37                                      ; preds = %35
  %38 = load i64, i64* %i, align 8
  %39 = load %struct.lepix_thread_pool_*, %struct.lepix_thread_pool_** %1, align 8
  %40 = getelementptr inbounds %struct.lepix_thread_pool_, %struct.lepix_thread_pool_* %39, i32 0, i32 0
  %41 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %40, align 8
  %42 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %41, i64 %38
  store %struct.lepix_thread_handle_* %42, %struct.lepix_thread_handle_** %handle, align 8
  %43 = load i64, i64* %i, align 8
  %44 = load %struct.local_work*, %struct.local_work** %local_work_list, align 8
  %45 = getelementptr inbounds %struct.local_work, %struct.local_work* %44, i64 %43
  store %struct.local_work* %45, %struct.local_work** %work, align 8
  %46 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %47 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %46, i32 0, i32 9
  %48 = load %struct.local_work*, %struct.local_work** %work, align 8
  %49 = getelementptr inbounds %struct.local_work, %struct.local_work* %48, i32 0, i32 0
  store %union.pthread_mutex_t* %47, %union.pthread_mutex_t** %49, align 8
  %50 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %51 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %50, i32 0, i32 7
  %52 = load %struct.local_work*, %struct.local_work** %work, align 8
  %53 = getelementptr inbounds %struct.local_work, %struct.local_work* %52, i32 0, i32 1
  store %union.pthread_cond_t* %51, %union.pthread_cond_t** %53, align 8
  %54 = load %struct.local_work*, %struct.local_work** %work, align 8
  %55 = getelementptr inbounds %struct.local_work, %struct.local_work* %54, i32 0, i32 2
  store %struct.lepix_parallel_transfer_* %55, %struct.lepix_parallel_transfer_** %transfer, align 8
  %56 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer, align 8
  %57 = load void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)*, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)** %2, align 8
  %58 = load i64, i64* %inv, align 8
  %59 = load i64, i64* %3, align 8
  %60 = load i64, i64* %i, align 8
  %61 = load i32, i32* %local_work_size, align 4
  %62 = sext i32 %61 to i64
  %63 = load i8**, i8*** %4, align 8
  %64 = load i64, i64* %5, align 8
  call void @lepix_create_parallel_transfer_(%struct.lepix_parallel_transfer_* %56, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* %57, i64 %58, i64 %59, i64 %60, i64 %62, i8** %63, i64 %64)
  %65 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %66 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %65, i32 0, i32 5
  %67 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* %66) #4
  %68 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer, align 8
  %69 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %70 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %69, i32 0, i32 11
  store %struct.lepix_parallel_transfer_* %68, %struct.lepix_parallel_transfer_** %70, align 8
  %71 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %72 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %71, i32 0, i32 3
  %73 = call i32 @pthread_cond_signal(%union.pthread_cond_t* %72) #4
  %74 = load %struct.lepix_thread_handle_*, %struct.lepix_thread_handle_** %handle, align 8
  %75 = getelementptr inbounds %struct.lepix_thread_handle_, %struct.lepix_thread_handle_* %74, i32 0, i32 5
  %76 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %75) #4
  br label %77

; <label>:77                                      ; preds = %37
  %78 = load i64, i64* %i, align 8
  %79 = add nsw i64 %78, 1
  store i64 %79, i64* %i, align 8
  %80 = load i64, i64* %inv, align 8
  %81 = add nsw i64 %80, 1
  store i64 %81, i64* %inv, align 8
  %82 = load i64, i64* %dispatched, align 8
  %83 = add nsw i64 %82, 1
  store i64 %83, i64* %dispatched, align 8
  br label %26

; <label>:84                                      ; preds = %35
  store i64 0, i64* %i1, align 8
  br label %85

; <label>:85                                      ; preds = %120, %84
  %86 = load i64, i64* %i1, align 8
  %87 = load i64, i64* %dispatched, align 8
  %88 = icmp slt i64 %86, %87
  br i1 %88, label %89, label %123

; <label>:89                                      ; preds = %85
  %90 = load i64, i64* %i1, align 8
  %91 = load %struct.local_work*, %struct.local_work** %local_work_list, align 8
  %92 = getelementptr inbounds %struct.local_work, %struct.local_work* %91, i64 %90
  store %struct.local_work* %92, %struct.local_work** %work2, align 8
  %93 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %94 = getelementptr inbounds %struct.local_work, %struct.local_work* %93, i32 0, i32 2
  store %struct.lepix_parallel_transfer_* %94, %struct.lepix_parallel_transfer_** %transfer3, align 8
  %95 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %96 = getelementptr inbounds %struct.local_work, %struct.local_work* %95, i32 0, i32 0
  %97 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %96, align 8
  %98 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* %97) #4
  %99 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %transfer3, align 8
  %100 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %99, i32 0, i32 1
  %101 = load i8, i8* %100, align 8
  %102 = trunc i8 %101 to i1
  br i1 %102, label %103, label %108

; <label>:103                                     ; preds = %89
  %104 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %105 = getelementptr inbounds %struct.local_work, %struct.local_work* %104, i32 0, i32 0
  %106 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %105, align 8
  %107 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %106) #4
  br label %120

; <label>:108                                     ; preds = %89
  %109 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %110 = getelementptr inbounds %struct.local_work, %struct.local_work* %109, i32 0, i32 1
  %111 = load %union.pthread_cond_t*, %union.pthread_cond_t** %110, align 8
  %112 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %113 = getelementptr inbounds %struct.local_work, %struct.local_work* %112, i32 0, i32 0
  %114 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %113, align 8
  %115 = call i32 @pthread_cond_wait(%union.pthread_cond_t* %111, %union.pthread_mutex_t* %114)
  %116 = load %struct.local_work*, %struct.local_work** %work2, align 8
  %117 = getelementptr inbounds %struct.local_work, %struct.local_work* %116, i32 0, i32 0
  %118 = load %union.pthread_mutex_t*, %union.pthread_mutex_t** %117, align 8
  %119 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %118) #4
  br label %120

; <label>:120                                     ; preds = %108, %103
  %121 = load i64, i64* %i1, align 8
  %122 = add nsw i64 %121, 1
  store i64 %122, i64* %i1, align 8
  br label %85

; <label>:123                                     ; preds = %85
  br label %21

; <label>:124                                     ; preds = %21
  %125 = load %struct.local_work*, %struct.local_work** %local_work_list, align 8
  %126 = bitcast %struct.local_work* %125 to i8*
  call void @free(i8* %126) #4
  ret void
}

; Function Attrs: nounwind uwtable
define void @lepix_parallel_main_0(%struct.lepix_parallel_transfer_* %transfer, %struct.lepix_thread_handle_* %thread) #0 {
  %1 = alloca %struct.lepix_parallel_transfer_*, align 8
  %2 = alloca %struct.lepix_thread_handle_*, align 8
  %x = alloca i32*, align 8
  store %struct.lepix_parallel_transfer_* %transfer, %struct.lepix_parallel_transfer_** %1, align 8
  store %struct.lepix_thread_handle_* %thread, %struct.lepix_thread_handle_** %2, align 8
  %3 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %4 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %3, i32 0, i32 6
  %5 = load i8**, i8*** %4, align 8
  %6 = getelementptr inbounds i8*, i8** %5, i64 0
  %7 = load i8*, i8** %6, align 8
  %8 = bitcast i8* %7 to i32*
  store i32* %8, i32** %x, align 8
  %9 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %10 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %9, i32 0, i32 8
  %11 = call i32 @pthread_mutex_lock(%union.pthread_mutex_t* %10) #4
  %12 = load i32*, i32** %x, align 8
  %13 = load i32, i32* %12, align 4
  %14 = add nsw i32 %13, 1
  %15 = load i32*, i32** %x, align 8
  store i32 %14, i32* %15, align 4
  %16 = load %struct.lepix_parallel_transfer_*, %struct.lepix_parallel_transfer_** %1, align 8
  %17 = getelementptr inbounds %struct.lepix_parallel_transfer_, %struct.lepix_parallel_transfer_* %16, i32 0, i32 8
  %18 = call i32 @pthread_mutex_unlock(%union.pthread_mutex_t* %17) #4
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %arv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %x = alloca i32, align 4
  %locals = alloca [1 x i8*], align 8
  store i32 0, i32* %1, align 4
  store i32 %argc, i32* %2, align 4
  store i8** %arv, i8*** %3, align 8
  call void @lepix_create_pool_(%struct.lepix_thread_pool_* @lepix_pool_)
  store i32 0, i32* %x, align 4
  %4 = getelementptr inbounds [1 x i8*], [1 x i8*]* %locals, i64 0, i64 0
  %5 = bitcast i32* %x to i8*
  store i8* %5, i8** %4, align 8
  %6 = getelementptr inbounds [1 x i8*], [1 x i8*]* %locals, i32 0, i32 0
  call void @lepix_launch_parallel_work_(%struct.lepix_thread_pool_* @lepix_pool_, void (%struct.lepix_parallel_transfer_*, %struct.lepix_thread_handle_*)* @lepix_parallel_main_0, i64 2, i8** %6, i64 1)
  call void @lepix_destroy_pool_(%struct.lepix_thread_pool_* @lepix_pool_)
  %7 = load i32, i32* %x, align 4
  ret i32 %7
}

attributes #0 = { nounwind uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { noreturn }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.8.0-2ubuntu4 (tags/RELEASE_380/final)"}
