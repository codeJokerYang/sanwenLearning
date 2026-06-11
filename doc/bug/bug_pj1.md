"E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\node\node.exe" "E:\huaweiApp\devecostudio-windows-6.0.0.858\DevEco Studio\tools\hvigor\bin\hvigorw.js" --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
> hvigor hvigor client: Starting hvigor daemon.
> hvigor Hvigor Daemon started in 1.25 s
> hvigor Finished :entry:default@PreBuild... after 343 ms 
> hvigor Finished :entry:default@CreateModuleInfo... after 3 ms 
> hvigor Finished :entry:default@GenerateMetadata... after 9 ms 
> hvigor Finished :entry:default@ConfigureCmake... after 1 ms 
> hvigor Finished :entry:default@MergeProfile... after 8 ms 
> hvigor Finished :entry:default@CreateBuildProfile... after 6 ms 
> hvigor Finished :entry:default@PreCheckSyscap... after 1 ms 
> hvigor Finished :entry:default@GeneratePkgContextInfo... after 17 ms 
> hvigor Finished :entry:default@ProcessIntegratedHsp... after 2 ms 
> hvigor Finished :entry:default@BuildNativeWithCmake... after 1 ms 
> hvigor Finished :entry:default@MakePackInfo... after 9 ms 
> hvigor Finished :entry:default@SyscapTransform... after 6 ms 
> hvigor Finished :entry:default@ProcessProfile... after 722 ms 
> hvigor Finished :entry:default@ProcessRouterMap... after 13 ms 
> hvigor Finished :entry:default@ProcessShareConfig... after 8 ms 
> hvigor Finished :entry:default@ProcessStartupConfig... after 5 ms 
> hvigor Finished :entry:default@BuildNativeWithNinja... after 3 ms 
> hvigor Finished :entry:default@ProcessResource... after 18 ms 
> hvigor Finished :entry:default@GenerateLoaderJson... after 33 ms 
> hvigor Finished :entry:default@ProcessLibs... after 12 ms 
> hvigor Finished :entry:default@CompileResource... after 1 s 417 ms 
> hvigor Finished :entry:default@DoNativeStrip... after 11 ms 
> hvigor Finished :entry:default@BuildJS... after 9 ms 
> hvigor Finished :entry:default@CacheNativeLibs... after 17 ms 
> hvigor ERROR: Failed :entry:default@CompileArkTS... 
> hvigor WARN: 
1 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:242:32
 'Function.bind' is not supported (arkts-no-func-bind)

2 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:244:32
 'Function.bind' is not supported (arkts-no-func-bind)

3 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:248:112
 'Function.bind' is not supported (arkts-no-func-bind)

4 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:252:111
 'Function.bind' is not supported (arkts-no-func-bind)

5 WARN: ArkTS:WARN: For details about ArkTS syntax errors, see FAQs
6 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Logger.ets:25:10
 Function may throw exceptions. Special handling is required.

7 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Logger.ets:26:7
 Function may throw exceptions. Special handling is required.

8 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:30:24
 Function may throw exceptions. Special handling is required.

9 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:89:18
 Function may throw exceptions. Special handling is required.

10 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:96:18
 Function may throw exceptions. Special handling is required.

11 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:104:18
 Function may throw exceptions. Special handling is required.

12 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:111:18
 Function may throw exceptions. Special handling is required.

13 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:118:11
 Function may throw exceptions. Special handling is required.

14 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:127:5
 Function may throw exceptions. Special handling is required.

15 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:132:7
 Function may throw exceptions. Special handling is required.

16 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:152:12
 Function may throw exceptions. Special handling is required.

17 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:157:9
 Function may throw exceptions. Special handling is required.

18 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:160:12
 Function may throw exceptions. Special handling is required.

19 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:165:9
 Function may throw exceptions. Special handling is required.

20 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:168:12
 Function may throw exceptions. Special handling is required.

21 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:214:9
 Function may throw exceptions. Special handling is required.

22 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:222:11
 Function may throw exceptions. Special handling is required.

23 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:222:28
 Function may throw exceptions. Special handling is required.

24 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:223:14
 Function may throw exceptions. Special handling is required.

25 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:223:31
 Function may throw exceptions. Special handling is required.

26 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:224:46
 Function may throw exceptions. Special handling is required.

27 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:225:52
 Function may throw exceptions. Special handling is required.

28 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:226:48
 Function may throw exceptions. Special handling is required.

29 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:227:63
 Function may throw exceptions. Special handling is required.

30 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:228:58
 Function may throw exceptions. Special handling is required.

31 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:229:59
 Function may throw exceptions. Special handling is required.

32 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:230:51
 Function may throw exceptions. Special handling is required.

33 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/CourseService.ets:110:9
 Function may throw exceptions. Special handling is required.

34 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/NetworkMonitor.ets:48:26
 To use this API, you need to apply for the permissions: ohos.permission.GET_NETWORK_INFO

35 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/NetworkMonitor.ets:87:64
 To use this API, you need to apply for the permissions: ohos.permission.GET_NETWORK_INFO

36 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:50:40
 'decodeWithStream' has been deprecated.

37 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:197:21
 'on' has been deprecated.

38 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:205:21
 To use this API, you need to apply for the permissions: ohos.permission.INTERNET

39 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:396:20
 'decodeWithStream' has been deprecated.

40 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:63:5
 Function may throw exceptions. Special handling is required.

41 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/HomeViewModel.ets:63:12
 'pushUrl' has been deprecated.

42 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:74:5
 Function may throw exceptions. Special handling is required.

43 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:74:12
 'pushUrl' has been deprecated.

44 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:411:10
 Function may throw exceptions. Special handling is required.

45 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:412:7
 Function may throw exceptions. Special handling is required.

46 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:443:12
 Function may throw exceptions. Special handling is required.

47 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:445:13
 Function may throw exceptions. Special handling is required.

48 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:445:33
 Function may throw exceptions. Special handling is required.

49 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:446:20
 Function may throw exceptions. Special handling is required.

50 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:446:40
 Function may throw exceptions. Special handling is required.

51 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:447:49
 Function may throw exceptions. Special handling is required.

52 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:448:66
 Function may throw exceptions. Special handling is required.

53 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:449:64
 Function may throw exceptions. Special handling is required.

54 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:450:27
 Function may throw exceptions. Special handling is required.

55 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:450:47
 Function may throw exceptions. Special handling is required.

56 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:451:31
 Function may throw exceptions. Special handling is required.

57 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:451:51
 Function may throw exceptions. Special handling is required.

58 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:452:63
 Function may throw exceptions. Special handling is required.

59 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:453:65
 Function may throw exceptions. Special handling is required.

60 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:454:21
 Function may throw exceptions. Special handling is required.

61 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:454:41
 Function may throw exceptions. Special handling is required.

62 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:456:42
 Function may throw exceptions. Special handling is required.

63 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:456:60
 Function may throw exceptions. Special handling is required.

64 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:457:56
 Function may throw exceptions. Special handling is required.

65 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:460:5
 Function may throw exceptions. Special handling is required.

66 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:480:12
 Function may throw exceptions. Special handling is required.

67 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:482:13
 Function may throw exceptions. Special handling is required.

68 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:482:33
 Function may throw exceptions. Special handling is required.

69 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:483:20
 Function may throw exceptions. Special handling is required.

70 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:483:40
 Function may throw exceptions. Special handling is required.

71 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:484:56
 Function may throw exceptions. Special handling is required.

72 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:485:26
 Function may throw exceptions. Special handling is required.

73 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:485:46
 Function may throw exceptions. Special handling is required.

74 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:486:24
 Function may throw exceptions. Special handling is required.

75 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:486:44
 Function may throw exceptions. Special handling is required.

76 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:487:18
 Function may throw exceptions. Special handling is required.

77 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:487:38
 Function may throw exceptions. Special handling is required.

78 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:488:25
 Function may throw exceptions. Special handling is required.

79 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:488:45
 Function may throw exceptions. Special handling is required.

80 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:489:55
 Function may throw exceptions. Special handling is required.

81 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:492:5
 Function may throw exceptions. Special handling is required.

82 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:9
 Function may throw exceptions. Special handling is required.

83 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:21
 Function may throw exceptions. Special handling is required.

84 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:57
 Function may throw exceptions. Special handling is required.

85 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:207:69
 Function may throw exceptions. Special handling is required.

86 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:12
 Function may throw exceptions. Special handling is required.

87 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:24
 Function may throw exceptions. Special handling is required.

88 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:58
 Function may throw exceptions. Special handling is required.

89 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:208:70
 Function may throw exceptions. Special handling is required.

90 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:209:18
 Function may throw exceptions. Special handling is required.

91 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:209:30
 Function may throw exceptions. Special handling is required.

92 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:210:40
 Function may throw exceptions. Special handling is required.

93 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:210:50
 Function may throw exceptions. Special handling is required.

94 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:12
 Function may throw exceptions. Special handling is required.

95 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:22
 Function may throw exceptions. Special handling is required.

96 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:67
 Function may throw exceptions. Special handling is required.

97 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:211:77
 Function may throw exceptions. Special handling is required.

98 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:212:17
 Function may throw exceptions. Special handling is required.

99 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:212:27
 Function may throw exceptions. Special handling is required.

100 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:9
 Function may throw exceptions. Special handling is required.

101 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:21
 Function may throw exceptions. Special handling is required.

102 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:57
 Function may throw exceptions. Special handling is required.

103 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:215:69
 Function may throw exceptions. Special handling is required.

104 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:13
 Function may throw exceptions. Special handling is required.

105 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:25
 Function may throw exceptions. Special handling is required.

106 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:62
 Function may throw exceptions. Special handling is required.

107 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:216:74
 Function may throw exceptions. Special handling is required.

108 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:217:15
 Function may throw exceptions. Special handling is required.

109 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:217:27
 Function may throw exceptions. Special handling is required.

110 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:9
 Function may throw exceptions. Special handling is required.

111 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:21
 Function may throw exceptions. Special handling is required.

112 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:57
 Function may throw exceptions. Special handling is required.

113 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:220:69
 Function may throw exceptions. Special handling is required.

114 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:12
 Function may throw exceptions. Special handling is required.

115 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:24
 Function may throw exceptions. Special handling is required.

116 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:60
 Function may throw exceptions. Special handling is required.

117 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:221:72
 Function may throw exceptions. Special handling is required.

118 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:17
 Function may throw exceptions. Special handling is required.

119 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:29
 Function may throw exceptions. Special handling is required.

120 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:70
 Function may throw exceptions. Special handling is required.

121 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:222:82
 Function may throw exceptions. Special handling is required.

122 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:17
 Function may throw exceptions. Special handling is required.

123 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:29
 Function may throw exceptions. Special handling is required.

124 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:74
 Function may throw exceptions. Special handling is required.

125 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:223:86
 Function may throw exceptions. Special handling is required.

126 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:224:39
 Function may throw exceptions. Special handling is required.

127 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:224:49
 Function may throw exceptions. Special handling is required.

128 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:225:17
 Function may throw exceptions. Special handling is required.

129 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:225:27
 Function may throw exceptions. Special handling is required.

130 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:9
 Function may throw exceptions. Special handling is required.

131 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:21
 Function may throw exceptions. Special handling is required.

132 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:57
 Function may throw exceptions. Special handling is required.

133 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:228:69
 Function may throw exceptions. Special handling is required.

134 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:229:18
 Function may throw exceptions. Special handling is required.

135 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:229:28
 Function may throw exceptions. Special handling is required.

136 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:230:22
 Function may throw exceptions. Special handling is required.

137 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:230:34
 Function may throw exceptions. Special handling is required.

138 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:20
 Function may throw exceptions. Special handling is required.

139 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:32
 Function may throw exceptions. Special handling is required.

140 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:77
 Function may throw exceptions. Special handling is required.

141 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:231:89
 Function may throw exceptions. Special handling is required.

142 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:232:21
 Function may throw exceptions. Special handling is required.

143 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:232:33
 Function may throw exceptions. Special handling is required.

144 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:233:17
 Function may throw exceptions. Special handling is required.

145 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:233:27
 Function may throw exceptions. Special handling is required.

146 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:237:31
 Function may throw exceptions. Special handling is required.

147 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:238:5
 Function may throw exceptions. Special handling is required.

148 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:259:12
 Function may throw exceptions. Special handling is required.

149 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:259:41
 Function may throw exceptions. Special handling is required.

150 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:259:53
 Function may throw exceptions. Special handling is required.

151 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:260:5
 Function may throw exceptions. Special handling is required.

152 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:91:5
 'animateTo' has been deprecated.

153 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:29:27
 'getParams' has been deprecated.

154 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:33:27
 'getParams' has been deprecated.

155 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/LearningSpace.ets:108:16
 'pushUrl' has been deprecated.

156 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:26:27
 'getParams' has been deprecated.

157 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:76:18
 'replaceUrl' has been deprecated.

158 WARN: ArkTS:WARN File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:22:27
 'getParams' has been deprecated.

> hvigor ERROR: ArkTS Compiler Error
1 ERROR: 10605074 ArkTS Compiler Error
Error Message: Destructuring variable declarations are not supported (arkts-no-destruct-decls) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:19:13


2 ERROR: 10605074 ArkTS Compiler Error
Error Message: Destructuring variable declarations are not supported (arkts-no-destruct-decls) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:28:13


3 ERROR: 10605074 ArkTS Compiler Error
Error Message: Destructuring variable declarations are not supported (arkts-no-destruct-decls) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:37:13


4 ERROR: 10605142 ArkTS Compiler Error
Error Message: "as const" assertions are not supported (arkts-no-as-const) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:38:3


5 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:25:26


6 ERROR: 10605142 ArkTS Compiler Error
Error Message: "as const" assertions are not supported (arkts-no-as-const) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:48:3


7 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:41:34


8 ERROR: 10605142 ArkTS Compiler Error
Error Message: "as const" assertions are not supported (arkts-no-as-const) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:60:3


9 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:51:36


10 ERROR: 10605142 ArkTS Compiler Error
Error Message: "as const" assertions are not supported (arkts-no-as-const) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:70:3


11 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:63:28


12 ERROR: 10605142 ArkTS Compiler Error
Error Message: "as const" assertions are not supported (arkts-no-as-const) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Config.ets:80:3


13 ERROR: 10605087 ArkTS Compiler Error
Error Message: "throw" statements cannot accept values of arbitrary types (arkts-limited-throw) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:134:7


14 ERROR: 10605008 ArkTS Compiler Error
Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/db/RdbHelper.ets:177:13


15 ERROR: 10605029 ArkTS Compiler Error
Error Message: Indexed access is not supported for fields (arkts-no-props-by-index) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/CourseService.ets:27:15


16 ERROR: 10605029 ArkTS Compiler Error
Error Message: Indexed access is not supported for fields (arkts-no-props-by-index) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/CourseService.ets:29:15


17 ERROR: 10605043 ArkTS Compiler Error
Error Message: Array literals must contain elements of only inferrable types (arkts-no-noninferrable-arr-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:19:15


18 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:20:5


19 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:21:5


20 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:22:5


21 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:24:5


22 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:25:5


23 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:26:5


24 ERROR: 10605043 ArkTS Compiler Error
Error Message: Array literals must contain elements of only inferrable types (arkts-no-noninferrable-arr-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:33:17


25 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:34:7


26 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:35:7


27 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:36:7


28 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:37:7


29 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:38:7


30 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:39:7


31 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:72:74


32 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:87:10


33 ERROR: 10605074 ArkTS Compiler Error
Error Message: Destructuring variable declarations are not supported (arkts-no-destruct-decls) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:95:11


34 ERROR: 10605043 ArkTS Compiler Error
Error Message: Array literals must contain elements of only inferrable types (arkts-no-noninferrable-arr-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:117:19


35 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:118:9


36 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:119:9


37 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:120:9


38 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:121:9


39 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:122:9


40 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:123:9


41 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:124:9


42 ERROR: 10605043 ArkTS Compiler Error
Error Message: Array literals must contain elements of only inferrable types (arkts-no-noninferrable-arr-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:210:23


43 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:210:24


44 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:23:46


45 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:24:3


46 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:25:3


47 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:26:3


48 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:27:3


49 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:28:3


50 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:29:3


51 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:129:36


52 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:193:33


53 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:193:71


54 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:194:7


55 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:194:32


56 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:195:7


57 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:195:32


58 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:196:7


59 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:196:32


60 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:197:7


61 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:197:32


62 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:198:7


63 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:198:32


64 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:199:7


65 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:199:32


66 ERROR: 10605029 ArkTS Compiler Error
Error Message: Indexed access is not supported for fields (arkts-no-props-by-index) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:275:60


67 ERROR: 10605029 ArkTS Compiler Error
Error Message: Indexed access is not supported for fields (arkts-no-props-by-index) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/viewmodels/ThreeAskViewModel.ets:276:17


68 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:21:16


69 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:22:32


70 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:33:30


71 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:42:30


72 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:45:30


73 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:87:38


74 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/ForceLayoutUtil.ets:89:29


75 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:19:37


76 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:60:34


77 ERROR: 10605999 ArkTS Compiler Error
Error Message: Type 'string | boolean' is not assignable to type 'boolean'.
  Type 'string' is not assignable to type 'boolean'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:105:5


78 ERROR: 10605008 ArkTS Compiler Error
Error Message: Use explicit types instead of "any", "unknown" (arkts-no-any-unknown) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/Assessment.ets:292:13


79 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:8:46


80 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:9:3


81 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:10:3


82 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:11:3


83 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:12:3


84 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:13:3


85 ERROR: 10605001 ArkTS Compiler Error
Error Message: Objects with property names that are not identifiers are not supported (arkts-identifiers-as-prop-names) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:14:3


86 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:87:27


87 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:92:21


88 ERROR: 10605040 ArkTS Compiler Error
Error Message: Object literals cannot be used as type declarations (arkts-no-obj-literals-as-types) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:113:29


89 ERROR: 10605038 ArkTS Compiler Error
Error Message: Object literal must correspond to some explicitly declared class or interface (arkts-no-untyped-obj-literals) At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/RadarChart.ets:119:23


90 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'require'. Did you mean 'Require'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:19:37


91 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'require'. Did you mean 'Require'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:28:34


92 ERROR: 10505001 ArkTS Compiler Error
Error Message: Cannot find name 'require'. Did you mean 'Require'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/entryability/EntryAbility.ets:37:36


93 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'writeTextSync' does not exist on type 'typeof fileIo'. Did you mean 'writeSync'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/common/Logger.ets:51:10


94 ERROR: 10505001 ArkTS Compiler Error
Error Message: Expected 2 arguments, but got 3. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/CourseService.ets:263:89


95 ERROR: 10505001 ArkTS Compiler Error
Error Message: Module '"@ohos.security.huks"' has no exported member 'huks'. Did you mean to use 'import huks from "@ohos.security.huks"' instead? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:7:10


96 ERROR: 10505001 ArkTS Compiler Error
Error Message: Module '"@ohos.data.preferences"' has no exported member 'preferences'. Did you mean to use 'import preferences from "@ohos.data.preferences"' instead? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/ApiKeyStore.ets:8:10


97 ERROR: 10505001 ArkTS Compiler Error
Error Message: No overload matches this call.
  The last overload gave the following error.
    Argument of type '"error"' is not assignable to parameter of type '"dataSendProgress"'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:197:24


98 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:239:44


99 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:246:57


100 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:259:22


101 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:282:22


102 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:314:18


103 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'randomUUID' does not exist on type 'typeof util'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/AIService.ets:361:20


104 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'trackColor' does not exist on type 'ProgressAttribute<ProgressType.Linear, LinearStyleOptions | ProgressStyleOptions>'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/ProgressBar.ets:21:10


105 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:83:9


106 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:85:9


107 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:87:9


108 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:89:9


109 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:91:9


110 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type 'Resource' is not assignable to type 'string'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/CourseCard.ets:93:9


111 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'Light' does not exist on type 'typeof FontWeight'. Did you mean 'Lighter'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/HomePage.ets:199:34


112 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'writeTextSync' does not exist on type 'typeof fileIo'. Did you mean 'writeSync'? At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:385:14


113 ERROR: 10505001 ArkTS Compiler Error
Error Message: Type '"true" | "subjective" | "false" | "pending"' is not assignable to type 'CorrectStatus'.
  Type '"true"' is not assignable to type 'CorrectStatus'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/services/EvaluationService.ets:454:9


114 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'justifyContent' does not exist on type 'StackAttribute'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:80:6


115 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'easeInOut' does not exist on type 'typeof curves'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/PuzzleFragmentAnim.ets:93:21


116 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'enableKeyboard' does not exist on type 'TextInputAttribute'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/components/ManualInputBox.ets:37:8


117 ERROR: 10505001 ArkTS Compiler Error
Error Message: Property 'trackColor' does not exist on type 'ProgressAttribute<ProgressType.Linear, LinearStyleOptions | ProgressStyleOptions>'. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/AssessmentResult.ets:275:10


118 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:188:19


119 ERROR: 10905209 ArkTS Compiler Error
Error Message: Only UI component syntax can be written here. At File: E:/huaweiApp/AppSth/sanwenLearning/entry/src/main/ets/pages/KnowledgeGraph.ets:190:21


COMPILE RESULT:FAIL {ERROR:120 WARN:158}

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --debug option to get more log output.

> hvigor ERROR: BUILD FAILED in 1 min 25 s 638 ms 

Process finished with exit code -1
