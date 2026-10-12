import localUnitTest from './LocalUnit.test';
import paperUtilsTest from './PaperUtils.test'
import timeUtilsTest from './TimeUtils.test'
import validationUtilTest from './ValidationUtil.test'
import loginViewModelTest from './LoginViewModel.test'
import homeViewModelTest from './HomeViewModel.test'
import subjectViewModelTest from './SubjectViewModel.test'
import examListViewModelTest from './ExamListViewModel.test'
import paperServiceTest from './PaperService.test'
import examDetailViewModelTest from './ExamDetailViewModel.test'
import resultViewModelTest from './ResultViewModel.test'
import mineViewModelTest from './MineViewModel.test'
import backgroundMonitorTest from './BackgroundMonitor.test'

export default function testsuite() {
  localUnitTest();
  paperUtilsTest()
  timeUtilsTest()
  validationUtilTest()
  loginViewModelTest()
  homeViewModelTest()
  subjectViewModelTest()
  examListViewModelTest()
  paperServiceTest()
  examDetailViewModelTest()
  resultViewModelTest()
  mineViewModelTest()
  backgroundMonitorTest()
}