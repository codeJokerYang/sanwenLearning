"E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\node\node.exe" "E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor UP-TO-DATE :entry:default@PreBuild...  
> hvigor Finished :entry:default@CreateModuleInfo... after 1 ms 
> hvigor UP-TO-DATE :entry:default@GenerateMetadata...  
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MergeProfile...  
> hvigor UP-TO-DATE :entry:default@CreateBuildProfile...  
> hvigor Finished :entry:default@PreCheckSyscap... after 1 ms 
> hvigor UP-TO-DATE :entry:default@GeneratePkgContextInfo...  
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 1 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor UP-TO-DATE :entry:default@MakePackInfo...  
> hvigor Finished :entry:default@SyscapTransform... after 7 ms 
> hvigor UP-TO-DATE :entry:default@ProcessProfile...  
> hvigor UP-TO-DATE :entry:default@ProcessRouterMap...  
> hvigor UP-TO-DATE :entry:default@ProcessShareConfig...  
> hvigor Finished :entry:default@ProcessStartupConfig... after 3 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 1 ms 
> hvigor UP-TO-DATE :entry:default@ProcessResource...  
> hvigor UP-TO-DATE :entry:default@GenerateLoaderJson...  
> hvigor UP-TO-DATE :entry:default@ProcessLibs...  
> hvigor UP-TO-DATE :entry:default@CompileResource...  
> hvigor UP-TO-DATE :entry:default@DoNativeStrip...  
> hvigor Finished :entry:default@BuildJS... after 6 ms 
> hvigor UP-TO-DATE :entry:default@CacheNativeLibs...  
> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor WARN: 
1 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
2 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Logger.ets:25:10
 Function may throw exceptions. Special handling is required.

3 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Logger.ets:26:7
 Function may throw exceptions. Special handling is required.

4 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/NetworkMonitor.ets:48:26
 To use this API, you need to apply for the permissions: ohos.permission.GET_NETWORK_INFO

5 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/NetworkMonitor.ets:87:64
 To use this API, you need to apply for the permissions: ohos.permission.GET_NETWORK_INFO

6 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:30:24
 Function may throw exceptions. Special handling is required.

7 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:89:18
 Function may throw exceptions. Special handling is required.

8 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:96:18
 Function may throw exceptions. Special handling is required.

9 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:104:18
 Function may throw exceptions. Special handling is required.

10 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:111:18
 Function may throw exceptions. Special handling is required.

11 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:118:11
 Function may throw exceptions. Special handling is required.

12 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:127:5
 Function may throw exceptions. Special handling is required.

13 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:132:7
 Function may throw exceptions. Special handling is required.

14 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:152:12
 Function may throw exceptions. Special handling is required.

15 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:157:9
 Function may throw exceptions. Special handling is required.

16 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:160:12
 Function may throw exceptions. Special handling is required.

17 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:165:9
 Function may throw exceptions. Special handling is required.

18 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:168:12
 Function may throw exceptions. Special handling is required.

19 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:214:9
 Function may throw exceptions. Special handling is required.

20 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:222:11
 Function may throw exceptions. Special handling is required.

21 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:222:28
 Function may throw exceptions. Special handling is required.

22 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:223:14
 Function may throw exceptions. Special handling is required.

23 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:223:31
 Function may throw exceptions. Special handling is required.

24 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:224:46
 Function may throw exceptions. Special handling is required.

25 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:225:52
 Function may throw exceptions. Special handling is required.

26 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:226:48
 Function may throw exceptions. Special handling is required.

27 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:227:63
 Function may throw exceptions. Special handling is required.

28 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:228:58
 Function may throw exceptions. Special handling is required.

29 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:229:59
 Function may throw exceptions. Special handling is required.

30 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:230:51
 Function may throw exceptions. Special handling is required.

31 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/CourseService.ets:112:9
 Function may throw exceptions. Special handling is required.

32 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:61:40
 'decodeWithStream' has been deprecated.

33 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:75:33
 Function may throw exceptions. Special handling is required.

34 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:79:9
 Function may throw exceptions. Special handling is required.

35 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:86:52
 Function may throw exceptions. Special handling is required.

36 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:93:9
 Function may throw exceptions. Special handling is required.

37 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:96:47
 Function may throw exceptions. Special handling is required.

38 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:97:47
 'outData' has been deprecated.

39 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:112:50
 Function may throw exceptions. Special handling is required.

40 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:113:11
 Function may throw exceptions. Special handling is required.

41 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:114:11
 Function may throw exceptions. Special handling is required.

42 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:115:11
 Function may throw exceptions. Special handling is required.

43 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:120:50
 Function may throw exceptions. Special handling is required.

44 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:121:27
 Function may throw exceptions. Special handling is required.

45 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:122:31
 Function may throw exceptions. Special handling is required.

46 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:144:54
 Function may throw exceptions. Special handling is required.

47 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:150:11
 Function may throw exceptions. Special handling is required.

48 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:153:49
 Function may throw exceptions. Special handling is required.

49 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:154:48
 'outData' has been deprecated.

50 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:220:21
 To use this API, you need to apply for the permissions: ohos.permission.INTERNET

51 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:413:20
 'decodeWithStream' has been deprecated.

52 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:63:5
 Function may throw exceptions. Special handling is required.

53 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:63:12
 'pushUrl' has been deprecated.

54 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:74:5
 Function may throw exceptions. Special handling is required.

55 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:74:12
 'pushUrl' has been deprecated.

56 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:432:10
 Function may throw exceptions. Special handling is required.

57 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:433:7
 Function may throw exceptions. Special handling is required.

58 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:464:12
 Function may throw exceptions. Special handling is required.

59 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:466:13
 Function may throw exceptions. Special handling is required.

60 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:466:33
 Function may throw exceptions. Special handling is required.

61 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:467:20
 Function may throw exceptions. Special handling is required.

62 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:467:40
 Function may throw exceptions. Special handling is required.

63 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:468:49
 Function may throw exceptions. Special handling is required.

64 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:469:66
 Function may throw exceptions. Special handling is required.

65 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:470:64
 Function may throw exceptions. Special handling is required.

66 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:471:27
 Function may throw exceptions. Special handling is required.

67 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:471:47
 Function may throw exceptions. Special handling is required.

68 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:472:31
 Function may throw exceptions. Special handling is required.

69 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:472:51
 Function may throw exceptions. Special handling is required.

70 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:473:63
 Function may throw exceptions. Special handling is required.

71 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:474:65
 Function may throw exceptions. Special handling is required.

72 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:475:21
 Function may throw exceptions. Special handling is required.

73 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:475:41
 Function may throw exceptions. Special handling is required.

74 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:476:42
 Function may throw exceptions. Special handling is required.

75 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:476:60
 Function may throw exceptions. Special handling is required.

76 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:477:56
 Function may throw exceptions. Special handling is required.

77 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:480:5
 Function may throw exceptions. Special handling is required.

78 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:500:12
 Function may throw exceptions. Special handling is required.

79 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:502:13
 Function may throw exceptions. Special handling is required.

80 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:502:33
 Function may throw exceptions. Special handling is required.

81 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:503:20
 Function may throw exceptions. Special handling is required.

82 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:503:40
 Function may throw exceptions. Special handling is required.

83 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:504:56
 Function may throw exceptions. Special handling is required.

84 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:505:26
 Function may throw exceptions. Special handling is required.

85 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:505:46
 Function may throw exceptions. Special handling is required.

86 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:506:24
 Function may throw exceptions. Special handling is required.

87 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:506:44
 Function may throw exceptions. Special handling is required.

88 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:507:18
 Function may throw exceptions. Special handling is required.

89 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:507:38
 Function may throw exceptions. Special handling is required.

90 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:508:25
 Function may throw exceptions. Special handling is required.

91 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:508:45
 Function may throw exceptions. Special handling is required.

92 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:509:55
 Function may throw exceptions. Special handling is required.

93 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:512:5
 Function may throw exceptions. Special handling is required.

94 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:9
 Function may throw exceptions. Special handling is required.

95 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:21
 Function may throw exceptions. Special handling is required.

96 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:57
 Function may throw exceptions. Special handling is required.

97 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:69
 Function may throw exceptions. Special handling is required.

98 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:12
 Function may throw exceptions. Special handling is required.

99 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:24
 Function may throw exceptions. Special handling is required.

100 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:58
 Function may throw exceptions. Special handling is required.

101 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:70
 Function may throw exceptions. Special handling is required.

102 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:209:18
 Function may throw exceptions. Special handling is required.

103 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:209:30
 Function may throw exceptions. Special handling is required.

104 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:210:40
 Function may throw exceptions. Special handling is required.

105 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:210:50
 Function may throw exceptions. Special handling is required.

106 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:12
 Function may throw exceptions. Special handling is required.

107 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:22
 Function may throw exceptions. Special handling is required.

108 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:67
 Function may throw exceptions. Special handling is required.

109 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:77
 Function may throw exceptions. Special handling is required.

110 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:212:17
 Function may throw exceptions. Special handling is required.

111 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:212:27
 Function may throw exceptions. Special handling is required.

112 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:9
 Function may throw exceptions. Special handling is required.

113 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:21
 Function may throw exceptions. Special handling is required.

114 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:57
 Function may throw exceptions. Special handling is required.

115 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:69
 Function may throw exceptions. Special handling is required.

116 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:13
 Function may throw exceptions. Special handling is required.

117 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:25
 Function may throw exceptions. Special handling is required.

118 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:62
 Function may throw exceptions. Special handling is required.

119 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:74
 Function may throw exceptions. Special handling is required.

120 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:217:15
 Function may throw exceptions. Special handling is required.

121 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:217:27
 Function may throw exceptions. Special handling is required.

122 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:9
 Function may throw exceptions. Special handling is required.

123 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:21
 Function may throw exceptions. Special handling is required.

124 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:57
 Function may throw exceptions. Special handling is required.

125 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:69
 Function may throw exceptions. Special handling is required.

126 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:12
 Function may throw exceptions. Special handling is required.

127 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:24
 Function may throw exceptions. Special handling is required.

128 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:60
 Function may throw exceptions. Special handling is required.

129 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:72
 Function may throw exceptions. Special handling is required.

130 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:17
 Function may throw exceptions. Special handling is required.

131 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:29
 Function may throw exceptions. Special handling is required.

132 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:70
 Function may throw exceptions. Special handling is required.

133 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:82
 Function may throw exceptions. Special handling is required.

134 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:17
 Function may throw exceptions. Special handling is required.

135 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:29
 Function may throw exceptions. Special handling is required.

136 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:74
 Function may throw exceptions. Special handling is required.

137 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:86
 Function may throw exceptions. Special handling is required.

138 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:224:39
 Function may throw exceptions. Special handling is required.

139 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:224:49
 Function may throw exceptions. Special handling is required.

140 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:225:17
 Function may throw exceptions. Special handling is required.

141 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:225:27
 Function may throw exceptions. Special handling is required.

142 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:9
 Function may throw exceptions. Special handling is required.

143 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:21
 Function may throw exceptions. Special handling is required.

144 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:57
 Function may throw exceptions. Special handling is required.

145 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:69
 Function may throw exceptions. Special handling is required.

146 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:229:18
 Function may throw exceptions. Special handling is required.

147 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:229:28
 Function may throw exceptions. Special handling is required.

148 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:230:22
 Function may throw exceptions. Special handling is required.

149 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:230:34
 Function may throw exceptions. Special handling is required.

150 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:20
 Function may throw exceptions. Special handling is required.

151 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:32
 Function may throw exceptions. Special handling is required.

152 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:77
 Function may throw exceptions. Special handling is required.

153 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:89
 Function may throw exceptions. Special handling is required.

154 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:232:21
 Function may throw exceptions. Special handling is required.

155 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:232:33
 Function may throw exceptions. Special handling is required.

156 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:233:17
 Function may throw exceptions. Special handling is required.

157 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:233:27
 Function may throw exceptions. Special handling is required.

158 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:237:31
 Function may throw exceptions. Special handling is required.

159 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:238:5
 Function may throw exceptions. Special handling is required.
