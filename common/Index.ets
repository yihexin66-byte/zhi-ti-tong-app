export { BaseViewModel } from './src/main/ets/base/BaseViewModel';
export { Result } from './src/main/ets/base/Result';
export { CommonConstants } from './src/main/ets/constants/CommonConstants';
export { RouteConstants } from './src/main/ets/constants/RouteConstants';
export { StateKeys } from './src/main/ets/constants/StateKeys';
export { Logger } from './src/main/ets/log/Logger';
export { MOCK_PAPER, MOCK_PAPERS, MOCK_QUESTIONS } from './src/main/ets/mock/MockExamData';
export { MOCK_RESULT } from './src/main/ets/mock/MockResultData';
export { OptionItem, QuestionItem, PaperInfo, AnswerItem, ExamResult } from './src/main/ets/models/QuestionModel';
// 状态模型
export { FontSetting, FONT_LEVELS, FontLevel } from './src/main/ets/models/FontSetting';
export { BackgroundMonitor } from './src/main/ets/models/BackgroundMonitor';
export { CategoryGroup, getRandomPapers, groupByCategory, filterByCategory } from './src/main/ets/utils/PaperUtils';
export { formatDuration, formatCountdown } from './src/main/ets/utils/TimeUtils';
export { questionTypeLabel, submitTypeLabel } from './src/main/ets/utils/ExamUtils';
export { ValidationResult, ValidationUtil } from './src/main/ets/utils/ValidationUtil';
// 全局配置与网络层基础设施（6-1）
export { AppConfig } from './src/main/ets/config/AppConfig';
export { RequestConfig, HttpResult, Interceptor } from './src/main/ets/network/types';
export { TokenProvider } from './src/main/ets/network/interceptors';
export { httpClient, setTokenProvider } from './src/main/ets/network/http';
export { BaseService, ApiResponse } from './src/main/ets/base/BaseService';
// 会话与持久化（6-2）
export { PreferencesUtil } from './src/main/ets/utils/PreferencesUtil';
export { SessionUser, SessionUserData } from './src/main/ets/session/SessionUser';
export { SessionManager } from './src/main/ets/session/SessionManager';
