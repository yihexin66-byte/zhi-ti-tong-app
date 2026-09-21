import localUnitTest from './LocalUnit.test';
import paperUtilsTest from './PaperUtils.test'
import timeUtilsTest from './TimeUtils.test'
import validationUtilTest from './ValidationUtil.test'
import loginViewModelTest from './LoginViewModel.test'
import homeViewModelTest from './HomeViewModel.test'
import subjectViewModelTest from './SubjectViewModel.test'
import examListViewModelTest from './ExamListViewModel.test'
import examDetailViewModelTest from './ExamDetailViewModel.test'

export default function testsuite() {
  localUnitTest();
  paperUtilsTest()
  timeUtilsTest()
  validationUtilTest()
  loginViewModelTest()
  homeViewModelTest()
  subjectViewModelTest()
  examListViewModelTest()
  examDetailViewModelTest()
}