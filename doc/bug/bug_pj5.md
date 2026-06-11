"E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\node\node.exe" "E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor hvigor client: Starting hvigor daemon.
> hvigor Hvigor Daemon started in 944 ms
> hvigor UP-TO-DATE :entry:default@PreBuild...  
> hvigor Finished :entry:default@CreateModuleInfo... after 2 ms 
> hvigor UP-TO-DATE :entry:default@GenerateMetadata...  
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MergeProfile...  
> hvigor UP-TO-DATE :entry:default@CreateBuildProfile...  
> hvigor Finished :entry:default@PreCheckSyscap... after 1 ms 
> hvigor UP-TO-DATE :entry:default@GeneratePkgContextInfo...  
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 1 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MakePackInfo...  
> hvigor Finished :entry:default@SyscapTransform... after 25 ms 
> hvigor UP-TO-DATE :entry:default@ProcessProfile...  
> hvigor UP-TO-DATE :entry:default@ProcessRouterMap...  
> hvigor UP-TO-DATE :entry:default@ProcessShareConfig...  
> hvigor Finished :entry:default@ProcessStartupConfig... after 16 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 1 ms 
> hvigor UP-TO-DATE :entry:default@ProcessResource...  
> hvigor UP-TO-DATE :entry:default@GenerateLoaderJson...  
> hvigor UP-TO-DATE :entry:default@ProcessLibs...  
> hvigor UP-TO-DATE :entry:default@CompileResource...  
> hvigor UP-TO-DATE :entry:default@DoNativeStrip...  
> hvigor Finished :entry:default@BuildJS... after 4 ms 
> hvigor UP-TO-DATE :entry:default@CacheNativeLibs...  
> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor WARN: 
1 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:70:14
 'pushUrl' has been deprecated.

2 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:85:21
 'show' has been deprecated.

3 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:117:14
 'pushUrl' has been deprecated.

4 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:88:5
 'animateTo' has been deprecated.

5 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:115:14
 'getContext' has been deprecated.

6 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:115:14
 Function may throw exceptions. Special handling is required.

7 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:118:12
 'getContext' has been deprecated.

8 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:118:12
 Function may throw exceptions. Special handling is required.

9 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:126:12
 'getContext' has been deprecated.

10 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:126:12
 Function may throw exceptions. Special handling is required.

11 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:39:29
 'getParams' has been deprecated.

12 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:76:21
 'show' has been deprecated.

13 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:107:7
 'animateTo' has been deprecated.

14 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:36:29
 'getParams' has been deprecated.

15 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:60:21
 'show' has been deprecated.

16 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:129:16
 'pushUrl' has been deprecated.

17 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:30:29
 'getParams' has been deprecated.

18 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:62:21
 'show' has been deprecated.

19 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:108:20
 'replaceUrl' has been deprecated.

20 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:27:55
 'getContext' has been deprecated.

21 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:24:29
 'getParams' has been deprecated.

22 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:50:21
 'show' has been deprecated.

> hvigor ERROR: ArkTS Compiler Error
1 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:26


2 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:37


3 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:52


4 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:26


5 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:37


6 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:52


7 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:68


8 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:26


9 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:37


10 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:52


11 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:68


12 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:334:29


13 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:334:45


14 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:29


15 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:45


16 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:62


17 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:29


18 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:46


19 ERROR: 10505001 ArkTS Compiler Error
Error Message: ',' expected. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:63


20 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'num'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:23


21 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. Did you mean 'Text'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:33


22 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 6. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:33


23 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'active'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:319:46


24 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'num'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:23


25 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:33


26 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 8. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:33


27 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'active'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:46


28 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'marginL'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:320:61


29 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'num'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:23


30 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:33


31 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 8. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:33


32 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'active'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:46


33 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'marginL'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:321:61


34 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. Did you mean 'Text'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:334:25


35 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'subtext'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:334:38


36 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 4. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:334:38


37 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. Did you mean 'Text'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:25


38 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'subtext'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:38


39 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 6. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:38


40 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'marginL'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:335:55


41 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'text'. Did you mean 'Text'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:25


42 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'subtext'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:39


43 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 0-2 arguments, but got 6. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:39


44 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'marginL'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:336:56


COMPILE RESULT:FAIL {ERROR:45 WARN:22}

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --debug option to get more log output.

> hvigor ERROR: BUILD FAILED in 1 min 14 s 227 ms 

Process finished with exit code -1
