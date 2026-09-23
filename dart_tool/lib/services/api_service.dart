import 'dart:async';
import 'dart:convert';
import 'api_config.dart';
import 'api_transport.dart';

class ApiResult<T> {
  const ApiResult({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
    this.isOffline = false,
  });

  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;
  final bool isOffline;

  factory ApiResult.success(T data, {String? message, int statusCode = 200}) {
    return ApiResult(
      isSuccess: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode,
    );
  }

  factory ApiResult.failure(String message, {int? statusCode, bool isOffline = false}) {
    return ApiResult(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
      isOffline: isOffline,
    );
  }
}

/// Robust HTTP client configured for MindSetu FastAPI Backend
/// Supports local development (127.0.0.1:8000) and production deployment (PRODUCTION_API_URL).
class ApiService {
  ApiService._internal();

  static final ApiService instance = ApiService._internal();

  // Base URL initialized from compile-time ApiConfig (PRODUCTION_API_URL or local default)
  String _baseUrl = ApiConfig.initialBaseUrl;

  String? _accessToken;
  String? _currentUserId;
  String? _currentRole;
  String? _patientId;
  String? _caregiverId;
  String? _doctorId;

  String get baseUrl => _baseUrl;
  bool get isAuthenticated => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get currentUserId => _currentUserId;
  String? get currentRole => _currentRole;
  String? get patientId => _patientId;
  String? get caregiverId => _caregiverId;
  String? get doctorId => _doctorId;

  ApiTransport _transport = defaultTransport;

  void setBaseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/+$'), '');
    ApiConfig.setCustomBaseUrl(_baseUrl);
  }

  void setTransport(ApiTransport transport) {
    _transport = transport;
  }

  void resetTransport() {
    _transport = defaultTransport;
  }

  void setToken(String token, {String? role, String? userId, String? patientId}) {
    _accessToken = token;
    _currentRole = role;
    _currentUserId = userId;
    if (patientId != null) _patientId = patientId;
  }

  void clearAuth() {
    _accessToken = null;
    _currentRole = null;
    _currentUserId = null;
    _patientId = null;
    _caregiverId = null;
    _doctorId = null;
  }

  // ==========================================
  // 1. HEALTH & CONNECTIVITY
  // ==========================================

  Future<bool> checkHealth() async {
    try {
      final res = await _request('GET', '/health', timeoutSeconds: 3);
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  // ==========================================
  // 2. AUTHENTICATION
  // ==========================================

  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final res = await _request(
      'POST',
      '/api/v1/auth/login',
      body: {'email': email.trim(), 'password': password},
      timeoutSeconds: 5,
    );

    if (res.isSuccess && res.data is Map<String, dynamic>) {
      final data = res.data as Map<String, dynamic>;
      _accessToken = data['access_token'] as String?;
      _currentRole = data['role'] as String?;
      _currentUserId = data['user_id'] as String?;
      _patientId = data['patient_id'] as String?;
      _caregiverId = data['caregiver_id'] as String?;
      _doctorId = data['doctor_id'] as String?;
      return ApiResult.success(data, message: res.message);
    }
    return ApiResult.failure(res.message ?? 'Login failed', statusCode: res.statusCode, isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    required String role, // PATIENT, CAREGIVER, DOCTOR
    String? phone,
  }) async {
    return _request(
      'POST',
      '/api/v1/auth/register',
      body: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'role': role.toUpperCase(),
        if (phone != null) 'phone': phone.trim(),
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getMe() async {
    return _request('GET', '/api/v1/auth/me');
  }

  // ==========================================
  // 3. PATIENT DATA
  // ==========================================

  Future<ApiResult<Map<String, dynamic>>> getPatientMe() async {
    return _request('GET', '/api/v1/patients/me');
  }

  Future<ApiResult<Map<String, dynamic>>> getPatientDashboard() async {
    return _request('GET', '/api/v1/patients/me/dashboard');
  }

  Future<ApiResult<Map<String, dynamic>>> updatePatientMe(Map<String, dynamic> updateData) async {
    return _request('PUT', '/api/v1/patients/me', body: updateData);
  }

  // ==========================================
  // 4. COGNITIVE ACTIVITIES & RESULTS
  // ==========================================

  Future<ApiResult<List<dynamic>>> getActivities() async {
    final res = await _request('GET', '/api/v1/activities');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load activities', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> getActivity(String activityId) async {
    return _request('GET', '/api/v1/activities/$activityId');
  }

  Future<ApiResult<Map<String, dynamic>>> submitActivityResult({
    required String activityId,
    required int score,
    required double accuracy,
    required int completionTimeSeconds,
    int movesCount = 0,
    String difficultyLevel = 'gentle',
    Map<String, dynamic>? metricsData,
  }) async {
    return _request(
      'POST',
      '/api/v1/activities/results',
      body: {
        'activity_id': activityId,
        'score': score,
        'accuracy': accuracy,
        'completion_time_seconds': completionTimeSeconds,
        'moves_count': movesCount,
        'difficulty_level': difficultyLevel,
        'metrics_data': metricsData ?? {},
        'device_synced': true,
      },
    );
  }

  Future<ApiResult<List<dynamic>>> getActivityResults() async {
    final res = await _request('GET', '/api/v1/activities/results');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load results', isOffline: res.isOffline);
  }

  // ==========================================
  // 5. MEMORIES (JOURNAL)
  // ==========================================

  Future<ApiResult<List<dynamic>>> getMemories() async {
    final res = await _request('GET', '/api/v1/memories');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load memories', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> createMemory({
    required String title,
    String? description,
    String? dateEra,
    String? location,
    String? photoIcon,
    List<String>? tags,
    Map<String, dynamic>? recallQuiz,
  }) async {
    return _request(
      'POST',
      '/api/v1/memories',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (dateEra != null) 'date_era': dateEra,
        if (location != null) 'location': location,
        if (photoIcon != null) 'image_url': photoIcon,
        if (tags != null) 'tags': tags,
        if (recallQuiz != null) 'quiz_data': recallQuiz,
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> deleteMemory(String memoryId) async {
    return _request('DELETE', '/api/v1/memories/$memoryId');
  }

  // ==========================================
  // 6. DAILY REMINDERS
  // ==========================================

  Future<ApiResult<List<dynamic>>> getReminders() async {
    final res = await _request('GET', '/api/v1/reminders');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load reminders', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> updateReminder(
    String reminderId, {
    bool? isCompleted,
    bool? verifiedByCaregiver,
  }) async {
    return _request(
      'PUT',
      '/api/v1/reminders/$reminderId',
      body: {
        if (isCompleted != null) 'is_completed': isCompleted,
        if (verifiedByCaregiver != null) 'verified_by_caregiver': verifiedByCaregiver,
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createReminder(Map<String, dynamic> reminderData) async {
    return _request('POST', '/api/v1/reminders', body: reminderData);
  }

  Future<ApiResult<Map<String, dynamic>>> deleteReminder(String reminderId) async {
    return _request('DELETE', '/api/v1/reminders/$reminderId');
  }

  // ==========================================
  // 7. CAREGIVER OBSERVATIONS & NOTES
  // ==========================================

  Future<ApiResult<List<dynamic>>> getNotes() async {
    final res = await _request('GET', '/api/v1/notes');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load notes', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> createNote({
    required String mood,
    required double sleepHours,
    required String appetite,
    required String notes,
  }) async {
    return _request(
      'POST',
      '/api/v1/notes',
      body: {
        'mood': mood,
        'sleep_hours': sleepHours,
        'appetite': appetite,
        'behavior_notes': notes,
      },
    );
  }

  Future<ApiResult<List<dynamic>>> getCaregiverPatients() async {
    final res = await _request('GET', '/api/v1/caregivers/me/patients');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load caregiver patients', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> connectCaregiverPatient(String patientId) async {
    return _request('POST', '/api/v1/caregivers/connect', body: {'patient_id': patientId.trim()});
  }

  // ==========================================
  // 8. DOCTOR CLINICAL ENDPOINTS
  // ==========================================

  Future<ApiResult<List<dynamic>>> getDoctorPatients() async {
    final res = await _request('GET', '/api/v1/doctors/patients');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load doctor patients', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> openDoctorPatient(String patientId) async {
    return _request('POST', '/api/v1/doctors/open_patient', body: {'patient_id': patientId.trim()});
  }

  Future<ApiResult<List<dynamic>>> getDoctorPatientInsights(String patientId) async {
    final res = await _request('GET', '/api/v1/doctors/patients/$patientId/insights');
    if (res.isSuccess && res.data is List) {
      return ApiResult.success(res.data as List<dynamic>);
    }
    return ApiResult.failure(res.message ?? 'Failed to load insights', isOffline: res.isOffline);
  }

  Future<ApiResult<Map<String, dynamic>>> getDoctorPatientReports(String patientId) async {
    return _request('GET', '/api/v1/doctors/patients/$patientId/reports');
  }

  // ==========================================
  // 9. PROGRESS & TRENDS
  // ==========================================

  Future<ApiResult<Map<String, dynamic>>> getProgressSummary() async {
    return _request('GET', '/api/v1/progress/summary');
  }

  Future<ApiResult<Map<String, dynamic>>> getProgressTrends() async {
    return _request('GET', '/api/v1/progress/trends');
  }

  // ==========================================
  // 10. OFFLINE SYNC PUSH & PULL
  // ==========================================

  Future<ApiResult<Map<String, dynamic>>> pushSync({
    required List<Map<String, dynamic>> items,
  }) async {
    return _request(
      'POST',
      '/api/v1/sync/push',
      body: {
        'items': items,
        'client_timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> pullSync({String? lastSyncedAt}) async {
    final query = lastSyncedAt != null ? '?since=${Uri.encodeComponent(lastSyncedAt)}' : '';
    return _request('GET', '/api/v1/sync/pull$query');
  }

  // ==========================================
  // 11. VOICE COMPANION (GROQ AI)
  // ==========================================

  Future<ApiResult<Map<String, dynamic>>> sendVoiceChat({
    required String query,
    String? language,
    String? region,
    Map<String, dynamic>? context,
  }) async {
    final res = await _request(
      'POST',
      '/api/v1/voice/chat',
      body: {
        'query': query.trim(),
        if (language != null) 'language': language,
        if (region != null) 'region': region,
        if (context != null) 'context': context,
      },
      timeoutSeconds: 8,
    );

    if (res.isSuccess && res.data is Map<String, dynamic>) {
      return ApiResult.success(res.data as Map<String, dynamic>, message: res.message);
    }
    return ApiResult.failure(
      res.message ?? 'Voice assistant request failed',
      statusCode: res.statusCode,
      isOffline: res.isOffline,
    );
  }

  Future<ApiResult<Map<String, dynamic>>> transcribeAudio(
    List<int> audioBytes, {
    String fileName = 'audio.wav',
    String? language,
  }) async {
    // Audio transcription endpoint
    return ApiResult.failure('Audio transcription via API is available on supported devices');
  }

  // ==========================================
  // INTERNAL HTTP DISPATCHER
  // ==========================================

  Future<ApiResult<T>> _request<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    int timeoutSeconds = 5,
  }) async {
    try {
      final url = '$_baseUrl$path';
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_accessToken != null) {
        headers['Authorization'] = 'Bearer $_accessToken';
      }

      final bodyStr = body != null ? jsonEncode(body) : null;

      final resp = await _transport.sendRequest(
        method: method,
        url: url,
        headers: headers,
        body: bodyStr,
        timeoutSeconds: timeoutSeconds,
      );

      if (resp.isOffline) {
        return ApiResult.failure(resp.body, isOffline: true);
      }

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.trim().isEmpty) {
          return ApiResult.success(null as T, statusCode: resp.statusCode);
        }

        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          final isSuccess = decoded['success'] == true;
          final dynamic dataField = decoded['data'];
          final String? message = decoded['message'] as String?;

          if (isSuccess) {
            return ApiResult.success(dataField as T, message: message, statusCode: resp.statusCode);
          } else {
            return ApiResult.failure(message ?? 'Server error', statusCode: resp.statusCode);
          }
        }
        return ApiResult.success(decoded as T, statusCode: resp.statusCode);
      } else {
        String errorMsg = 'HTTP ${resp.statusCode} error';
        try {
          final errDecoded = jsonDecode(resp.body);
          if (errDecoded is Map && errDecoded['detail'] != null) {
            errorMsg = errDecoded['detail'].toString();
          } else if (errDecoded is Map && errDecoded['message'] != null) {
            errorMsg = errDecoded['message'].toString();
          }
        } catch (_) {}

        return ApiResult.failure(errorMsg, statusCode: resp.statusCode);
      }
    } catch (e) {
      return ApiResult.failure('Network connection issue: $e', isOffline: true);
    }
  }
}
