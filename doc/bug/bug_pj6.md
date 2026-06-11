"E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\node\node.exe" "E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor Finished :entry:default@PreBuild... after 22 ms 
> hvigor Finished :entry:default@CreateModuleInfo... after 1 ms 
> hvigor UP-TO-DATE :entry:default@GenerateMetadata...  
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MergeProfile...  
> hvigor UP-TO-DATE :entry:default@CreateBuildProfile...  
> hvigor Finished :entry:default@PreCheckSyscap... after 4 ms 
> hvigor UP-TO-DATE :entry:default@GeneratePkgContextInfo...  
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 1 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MakePackInfo...  
> hvigor Finished :entry:default@SyscapTransform... after 6 ms 
> hvigor UP-TO-DATE :entry:default@ProcessProfile...  
> hvigor UP-TO-DATE :entry:default@ProcessRouterMap...  
> hvigor UP-TO-DATE :entry:default@ProcessShareConfig...  
> hvigor Finished :entry:default@ProcessStartupConfig... after 4 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 1 ms 
> hvigor UP-TO-DATE :entry:default@ProcessResource...  
> hvigor UP-TO-DATE :entry:default@GenerateLoaderJson...  
> hvigor UP-TO-DATE :entry:default@ProcessLibs...  
> hvigor WARN: Warning: the string of 'home_quick_upload_a11y' does not have a base resource.

> hvigor Finished :entry:default@CompileResource... after 691 ms 
> hvigor UP-TO-DATE :entry:default@DoNativeStrip...  
> hvigor Finished :entry:default@BuildJS... after 8 ms 
> hvigor UP-TO-DATE :entry:default@CacheNativeLibs...  
> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor WARN: 
1 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:210:11
 Function may throw exceptions. Special handling is required.

2 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:220:11
 Function may throw exceptions. Special handling is required.

3 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:231:11
 Function may throw exceptions. Special handling is required.

4 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:232:11
 Function may throw exceptions. Special handling is required.

5 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:233:11
 Function may throw exceptions. Special handling is required.

6 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:91:14
 'pushUrl' has been deprecated.

7 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/BottomTabBar.ets:29:18
 'back' has been deprecated.

8 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/BottomTabBar.ets:50:18
 'pushUrl' has been deprecated.

9 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/BottomTabBar.ets:71:18
 'pushUrl' has been deprecated.

10 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/BottomTabBar.ets:92:18
 'pushUrl' has been deprecated.

11 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:69:5
 Function may throw exceptions. Special handling is required.

12 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:69:12
 'pushUrl' has been deprecated.

13 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:81:20
 'showToast' has been deprecated.

14 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:84:7
 Function may throw exceptions. Special handling is required.

15 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:84:20
 'showToast' has been deprecated.

16 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:127:39
 'pushUrl' has been deprecated.

17 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:137:38
 'pushUrl' has been deprecated.

18 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:138:38
 'pushUrl' has been deprecated.

19 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:139:38
 'pushUrl' has been deprecated.

20 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:156:47
 'showToast' has been deprecated.

21 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningHome.ets:86:21
 'show' has been deprecated.

22 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningHome.ets:118:14
 'pushUrl' has been deprecated.

23 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningHome.ets:233:39
 'pushUrl' has been deprecated.

24 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:88:5
 'animateTo' has been deprecated.

25 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:115:14
 'getContext' has been deprecated.

26 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:115:14
 Function may throw exceptions. Special handling is required.

27 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:118:12
 'getContext' has been deprecated.

28 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:118:12
 Function may throw exceptions. Special handling is required.

29 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:126:12
 'getContext' has been deprecated.

30 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:126:12
 Function may throw exceptions. Special handling is required.

31 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:42:29
 'getParams' has been deprecated.

32 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:79:21
 'show' has been deprecated.

33 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:110:7
 'animateTo' has been deprecated.

34 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:39:29
 'getParams' has been deprecated.

35 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:63:21
 'show' has been deprecated.

36 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:132:16
 'pushUrl' has been deprecated.

37 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:33:29
 'getParams' has been deprecated.

38 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:65:21
 'show' has been deprecated.

39 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:111:20
 'replaceUrl' has been deprecated.

40 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:27:55
 'getContext' has been deprecated.

41 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:27:29
 'getParams' has been deprecated.

42 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:53:21
 'show' has been deprecated.

43 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/SettingsPage.ets:43:22
 'back' has been deprecated.

44 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/SettingsPage.ets:228:9
 'getContext' has been deprecated.

45 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:58:28
 'showToast' has been deprecated.

46 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:145:30
 'showToast' has been deprecated.

47 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:155:24
 'pushUrl' has been deprecated.

48 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:165:29
 'show' has been deprecated.

> hvigor ERROR: ArkTS Compiler Error
1 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/ProfileHeader.ets:60:7


2 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/StatsCard.ets:42:7


3 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/StatsCard.ets:48:7


4 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:113:13


5 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:119:13


6 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:185:13


7 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  Overload 1 of 2, '(value: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'.
  Overload 2 of 2, '(options: ShadowOptions | ShadowStyle): ColumnAttribute', gave the following error.
    Argument of type '{ color: string; offsetX: number; offsetY: number; blur: number; }' is not assignable to parameter of type 'ShadowOptions | ShadowStyle'.
      Object literal may only specify known properties, and 'blur' does not exist in type 'ShadowOptions'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/ProfilePage.ets:191:13


COMPILE RESULT:FAIL {ERROR:8 WARN:48}

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --debug option to get more log output.

> hvigor ERROR: BUILD FAILED in 5 s 573 ms 

Process finished with exit code -1
