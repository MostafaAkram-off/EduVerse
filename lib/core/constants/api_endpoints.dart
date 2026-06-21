abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://eduverseapi.azurewebsites.net';

  // ── Auth ─────────────────────────────────────────────────
  static const String login          = '/Auth/Login';
  static const String register       = '/Auth/Register';
  static const String getProfile     = '/Auth/GetProfile';
  static const String getUser        = '/Auth/GetUser';
  static const String updateProfile  = '/Auth/UpdateProfile';
  static const String changePassword = '/Auth/ChangePassword';
  static const String forgotPassword = '/Auth/ForgotPassword';
  static const String verifyCode     = '/Auth/VerifyCode';
  static const String resetPassword  = '/Auth/ResetPassword';
  static String sendConfirmationEmail(String email) =>
      '/Auth/SendConfirmationEmail/$email';
  static const String reviveToken  = '/Auth/ReviveToken';
  static const String confirmEmail = '/Auth/ConfirmEmail';

  // ── Cloud ─────────────────────────────────────────────────
  static String cloudAdd(String folder)                        => '/Cloud/Add/$folder';
  static String cloudGet(String folder, String filename)       => '/Cloud/Get/$folder/$filename';
  static String cloudGetSas(String folder, String filename)    => '/Cloud/GetSas/$folder/$filename';
  static String cloudDelete(String folder, String filename)    => '/Cloud/Delete/$folder/$filename';
  static String getProfilePicture(String filename)             => '/Cloud/Get/ProfilePicture/$filename';
  static String deleteProfilePicture(String filename)          => '/Cloud/Delete/ProfilePicture/$filename';
  static const String uploadProfilePicture = '/Cloud/Add/ProfilePicture';

  // ── Courses ───────────────────────────────────────────────
  static const String getAllCourses    = '/Course/GetAll';
  static const String createCourse    = '/Course/Create';
  static const String updateCourse    = '/Course/Update';
  static const String addRating        = '/Course/AddRating';
  static const String addAssignment    = '/Course/AddAssignment';
  static String getCourseById(String id)              => '/Course/GetById/$id';
  static String searchCourses(String query)           => '/Course/search/$query';
  static String getCoursesByCategory(String catId)   => '/Course/GetByCategory/$catId';
  static String getAllSessions(String courseId)        => '/Course/GetAllSessions/$courseId';
  static String getSessionById(String id)             => '/Course/GetSessionById/$id';
  static const String addSession                      = '/Course/AddSession';
  static const String updateSession                   = '/Course/UpdateSession';
  static String deleteSession(String id)              => '/Course/DeleteSession/$id';
  static String getAllAssignments(String courseId)     => '/Course/GetAllAssignments/$courseId';
  static String getAssignmentById(String id)          => '/Course/GetAssignmentById/$id';
  static String getAssignmentsBySession(String sid)   => '/Course/GetAssignmentBySession/$sid';
  static const String updateAssignment                = '/Course/UpdateAssignment';
  static String deleteAssignment(String id)           => '/Course/DeleteAssignment/$id';

  // ── User ─────────────────────────────────────────────────
  // Enrollment
  static const String enrolledCourses    = '/User/enrolledcourses';
  static const String myEnrolledCourses  = '/User/my-enrolled-courses';
  static String enroll(String courseId)  => '/User/enroll/$courseId';
  static String myEnrollment(String courseId) => '/User/my-enrollment/$courseId';

  // Payment
  static const String myPayments = '/User/payments';
  static String payment(String courseId, String method) =>
      '/User/payment/$courseId/$method';

  // Assignments
  static const String submitAssignment    = '/User/submitassignment';
  static const String myAssignments       = '/User/my-assignments';
  static const String mySubmissions       = '/User/my-submissions';
  static String submitAssignmentById(String id) => '/Assignment/Submit/$id';
  static String mySubmission(String id)          => '/User/my-submission/$id';
  static String userSubmissions(String email)    => '/User/usersubmissions/$email';
  static String assignmentSubmissions(String id) => '/User/assignmentsubmissions/$id';
  static String submission(String id, String email) => '/User/submission/$id/$email';

  // Progress
  static const String updateProgress = '/User/updateprogress';
  static String myCourseProgress(String courseId)      => '/User/my-course-progress/$courseId';
  static String markSessionCompleted(String sessionId)  => '/User/mark-session-completed/$sessionId';
  static String toggleSessionDone(String sessionId)     => '/Progress/ToggleSessionDone/$sessionId';
  static String progressCourse(String courseId)         => '/Progress/Course/$courseId';
  static String assignmentProgress(String courseId)     => '/AssignmentProgress/Course/$courseId';

  // Certificates
  static const String myCertificates  = '/User/my-certificates';
  static const String addCertificate  = '/User/addcertificate';
  static String generateCertificate(String courseId)   => '/Certificate/Generate/$courseId';
  static String certificateEligibility(String courseId) => '/Certificate/Eligibility/$courseId';
  static String verifyCertificate(String code)         => '/Certificate/Verify/$code';
  static String downloadCertificate(String certificateId) => '/Certificate/Download/$certificateId';
  static String userCertificates(String email)       => '/User/usercertificates/$email';
  static String myCertificate(String courseId)       => '/User/my-certificate/$courseId';
  static String certificateFile(String courseId, String email) =>
      '/User/certificatefile/$courseId/$email';

  // Misc
  static String enrollmentData(String courseId, String email) =>
      '/User/enrollmentdata/$courseId/$email';
  static const String myEnrollmentData   = '/User/enrollmentdata';
  static String enrolledUsers(String courseId) => '/User/enrolledusers/$courseId';

  // ── Notifications ─────────────────────────────────────────
  static const String myNotifications = '/Notification/MyNotifications';
  static String markNotificationRead(String id) => '/Notification/MarkAsRead/$id';

  // ── Attendance ────────────────────────────────────────────
  static String markAttendance(String sessionId)    => '/Attendance/Mark/$sessionId';
  static String sessionAttendance(String sessionId) => '/Attendance/Session/$sessionId';
  static String createSessionQr(String sessionId)   => '/Attendance/CreateSessionQr/$sessionId';

  // ── Instructor ────────────────────────────────────────────
  static const String instructorOverview    = '/Instructor/Overview';
  static const String instructorSessions    = '/Instructor/Sessions';
  static const String instructorStudents    = '/Instructor/Students';
  static const String instructorSubmissions = '/Instructor/Submissions';
  static const String instructorMyCourses   = '/Instructor/MyCourses';
  static String instructorSubmission(String assignmentId, String studentId) =>
      '/Instructor/Submission/$assignmentId/$studentId';
  static String gradeSubmission(String assignmentId, String studentId) =>
      '/Instructor/GradeSubmission/$assignmentId/$studentId';
  static String instructorMark(String sessionId, String userId) =>
      '/Instructor/Mark?sessionId=$sessionId&userId=$userId';

  // ── Recommendations ───────────────────────────────────────
  static const String recommendationsForMe      = '/Recommendation/ForMe';
  static const String recommendationsTrending   = '/Recommendation/Trending';
  static String recommendationsSimilar(String courseId) =>
      '/Recommendation/Similar/$courseId';

  // ── Category ──────────────────────────────────────────────
  static const String getAllCategories           = '/Category/GetAll';
  static String getCategoryById(String id)       => '/Category/GetById/$id';
  static String getCategoryByName(String name)   => '/Category/GetByName/$name';

  // ── Health ────────────────────────────────────────────────
  static const String healthPing = '/health/ping';
  static const String healthDb   = '/health/db';
}
