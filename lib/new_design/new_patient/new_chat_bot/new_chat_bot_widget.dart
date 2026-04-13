import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/local_db/local_database.dart';
import '/backend/local_db/patient_session.dart';
import '/settings/patient_three_dash/patient_three_dash_widget.dart';
import 'dart:convert';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'new_chat_bot_model.dart';
export 'new_chat_bot_model.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  final String text;
  final bool isUser;
  final DateTime createdAt;
}

class _StructuredTriageData {
  const _StructuredTriageData({
    this.age,
    this.gender,
    this.chronicDisease,
    this.possibleDisease,
    this.emergencyLevel,
  });

  final String? age;
  final String? gender;
  final String? chronicDisease;
  final String? possibleDisease;
  final String? emergencyLevel;

  bool get hasCoreResults =>
      (possibleDisease != null && possibleDisease!.isNotEmpty) &&
      (emergencyLevel != null && emergencyLevel!.isNotEmpty);

  Map<String, String?> toMap() {
    return {
      'age': age,
      'gender': gender,
      'chronic Disease': chronicDisease,
      'possible Disease': possibleDisease,
      'emergency Level': emergencyLevel,
    };
  }
}

/// Generate a premium AI Chatbot Page for Pre-Diagno using the patient coral
/// theme (#E8735A) with a soft blush background, glowing elements, and smooth
/// animations.
///
/// Add a top header with a back button and title “AI Assistant”. In the body,
/// design a modern chat layout with rounded message bubbles: user messages in
/// coral gradient bubbles (right) and AI messages in light cards (left) with
/// soft shadows. Use dark readable text, not white on light backgrounds. Add
/// subtle fade/slide animations for messages and a typing indicator. At the
/// bottom, include a rounded input field with placeholder “Type your
/// message…” and a glowing coral send button. Keep everything soft, elegant,
/// highly spaced, with rounded corners, layered shadows, and 16px padding
/// using Theme Variables only.
class NewChatBotWidget extends StatefulWidget {
  const NewChatBotWidget({super.key});

  static String routeName = 'NewChatBot';
  static String routePath = '/newChatBot';

  @override
  State<NewChatBotWidget> createState() => _NewChatBotWidgetState();
}

class _NewChatBotWidgetState extends State<NewChatBotWidget> {
  late NewChatBotModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isSending = false;
  bool _isBotTyping = false;
  bool _caseSavedForConversation = false;

    static const String _localApiKey =
      'fc7f60ab38dc4dd8bfbae7241e22f985.Gj7LXASUO3QbaWu4TuGVL_-I';
    static const String _localModel = 'kimi-k2.5:cloud';
  static const String _promptOneAssetPath =
      'lib/new_design/new_patient/new_chat_bot/prompt1.txt';
  static const String _promptTwoAssetPath =
      'lib/new_design/new_patient/new_chat_bot/prompt2.txt';
  static const String _triageJsonContract = '''
Return ONLY one JSON object and no other text.
Use exactly these keys:
{
  "age": "",
  "gender": "",
  "chronic Disease": "",
  "possible Disease": "",
  "emergency Level": ""
}
Rules:
- all answers must be in English, even if the question is in Arabic.
- age: digits only when known, else "".
- gender: Male or Female when known, else "".
- chronic Disease: use "No" if no chronic condition else just use "Yes".
- possible Disease: short diagnosis phrase.
- emergency Level: one of "1", "2", "3", "4", "5".
''';

  String _systemPromptOne = '';
  String _systemPromptTwo = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewChatBotModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _loadSystemPrompts();

    _messages.add(
      _ChatMessage(
        text:'''
Hello! I'm your AI health assistant. To access your medical record and current location send "Accept".

مرحباً! أنا مساعدك الصحي المدعوم بالذكاء الاصطناعي. للوصول إلى سجلك الطبي وموقعك الحالي، أرسل موافق
''',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _loadSystemPrompts() async {
    try {
      final promptOne = await rootBundle.loadString(_promptOneAssetPath);
      final promptTwo = await rootBundle.loadString(_promptTwoAssetPath);

      if (!mounted) {
        return;
      }

      safeSetState(() {
        _systemPromptOne = promptOne.trim();
        _systemPromptTwo = promptTwo.trim();
      });
    } catch (_) {
      // Keep empty prompts if files cannot be loaded.
    }
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    _model.dispose();

    super.dispose();
  }

  String _formatTime(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime);

  Uri _chatEndpoint() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:11434/api/chat');
    }
    return Uri.parse('http://localhost:11434/api/chat');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) {
        return;
      }
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _isFinalTriageReply(String text) {
    final normalized = text.toLowerCase();
    final hasEnglishMarkers =
      (normalized.contains('triage level') ||
        normalized.contains('emergency level')) &&
      (normalized.contains('possible disease') ||
        normalized.contains('action required') ||
        normalized.contains('first aid advice'));
    final hasArabicMarkers =
      (normalized.contains('مستوى') || normalized.contains('الطوارئ')) &&
      (normalized.contains('المرض') ||
        normalized.contains('الإجراء المطلوب') ||
        normalized.contains('اسعافات') ||
        normalized.contains('إسعافات'));
    return hasEnglishMarkers || hasArabicMarkers;
  }

    String _allAiRepliesText() {
    return _messages
      .where((m) => !m.isUser)
      .map((m) => m.text)
      .join('\n');
    }

  String _allConversationText() {
    return _messages
        .map((m) => '${m.isUser ? 'Patient' : 'AI'}: ${m.text}')
        .join('\n');
  }

  String _normalizeStructuredKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
  }

  String? _cleanExtractedValue(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.toLowerCase() == 'null' || trimmed == '-') {
      return null;
    }
    return trimmed;
  }

  Map<String, dynamic>? _tryDecodeJsonMap(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {
      // Ignore invalid JSON candidates.
    }
    return null;
  }

  String? _extractLastBalancedJsonObject(String source) {
    int depth = 0;
    int start = -1;
    String? lastObject;

    for (int i = 0; i < source.length; i++) {
      final char = source[i];
      if (char == '{') {
        if (depth == 0) {
          start = i;
        }
        depth++;
      } else if (char == '}') {
        if (depth == 0) {
          continue;
        }
        depth--;
        if (depth == 0 && start >= 0) {
          lastObject = source.substring(start, i + 1);
          start = -1;
        }
      }
    }

    return lastObject;
  }

  Map<String, dynamic>? _extractJsonMapFromText(String source) {
    final direct = _tryDecodeJsonMap(source.trim());
    if (direct != null) {
      return direct;
    }

    final fenced = RegExp(
      r'```(?:json)?\s*([\s\S]*?)\s*```',
      caseSensitive: false,
    ).allMatches(source);
    for (final match in fenced.toList().reversed) {
      final candidate = match.group(1);
      if (candidate == null || candidate.trim().isEmpty) {
        continue;
      }
      final decoded = _tryDecodeJsonMap(candidate.trim());
      if (decoded != null) {
        return decoded;
      }
    }

    final balanced = _extractLastBalancedJsonObject(source);
    if (balanced != null) {
      return _tryDecodeJsonMap(balanced.trim());
    }

    return null;
  }

  String? _readJsonField(Map<String, dynamic> jsonMap, List<String> keys) {
    final normalizedKeys = keys.map(_normalizeStructuredKey).toSet();
    for (final entry in jsonMap.entries) {
      if (!normalizedKeys.contains(_normalizeStructuredKey(entry.key))) {
        continue;
      }
      final value = entry.value;
      if (value is String) {
        return _cleanExtractedValue(value);
      }
      if (value is num || value is bool) {
        return _cleanExtractedValue(value.toString());
      }
    }
    return null;
  }

  _StructuredTriageData? _extractStructuredTriage(String source) {
    final jsonMap = _extractJsonMapFromText(source);
    if (jsonMap == null) {
      return null;
    }

    final age = _readJsonField(jsonMap, ['age']);
    final gender = _readJsonField(jsonMap, ['gender']);
    final chronicDisease =
        _readJsonField(jsonMap, ['chronic Disease', 'chronicDisease']);
    final possibleDisease =
        _readJsonField(jsonMap, ['possible Disease', 'possibleDisease']);
    final emergencyLevel =
        _readJsonField(jsonMap, ['emergency Level', 'emergencyLevel']);

    if (age == null &&
        gender == null &&
        chronicDisease == null &&
        possibleDisease == null &&
        emergencyLevel == null) {
      return null;
    }

    return _StructuredTriageData(
      age: age,
      gender: gender,
      chronicDisease: chronicDisease,
      possibleDisease: possibleDisease,
      emergencyLevel: emergencyLevel,
    );
  }

  String? _firstMatch(String source, List<RegExp> patterns, {int group = 1}) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(source);
      if (match == null) {
        continue;
      }
      final value = match.group(group)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String? _extractEmergencyLevel(String aiReply) {
    return _firstMatch(aiReply, [
      RegExp(
        r'^\s*(?:Triage\s*Level|Emergency\s*Level)\s*[:\-]\s*(.+)$',
        multiLine: true,
        caseSensitive: false,
      ),
      RegExp(
        r'^\s*(?:Level)\s*[:\-]\s*(\d(?:\s*[-–]\s*\w+)?)$',
        multiLine: true,
        caseSensitive: false,
      ),
      RegExp(
        r'^\s*(?:مستوى\s*الفرز|مستوى\s*الطوارئ)\s*[:\-]\s*(.+)$',
        multiLine: true,
      ),
    ]);
  }

  String? _extractPossibleDisease(String aiReply) {
    return _firstMatch(aiReply, [
      RegExp(
        r'^\s*(?:Possible\s*Disease|Likely\s*Disease)\s*[:\-]\s*(.+)$',
        multiLine: true,
        caseSensitive: false,
      ),
      RegExp(
        r'^\s*(?:Diagnosis|Predicted\s*Disease)\s*[:\-]\s*(.+)$',
        multiLine: true,
        caseSensitive: false,
      ),
      RegExp(
        r'^\s*(?:المرض\s*المحتمل|التشخيص\s*المحتمل)\s*[:\-]\s*(.+)$',
        multiLine: true,
      ),
    ]);
  }

  String? _extractAge(String conversation) {
    return _firstMatch(conversation, [
      RegExp(r'\bage\b[^\d]{0,10}(\d{1,3})', caseSensitive: false),
      RegExp(r'العمر[^\d]{0,10}(\d{1,3})'),
    ]);
  }

  String? _extractGender(String conversation) {
    final lower = conversation.toLowerCase();
    if (RegExp(r'\b(male|man|boy)\b').hasMatch(lower) ||
        lower.contains('ذكر') ||
        lower.contains('رجل')) {
      return 'Male';
    }
    if (RegExp(r'\b(female|woman|girl)\b').hasMatch(lower) ||
        lower.contains('أنثى') ||
        lower.contains('انثى') ||
        lower.contains('امرأة') ||
        lower.contains('مرأة')) {
      return 'Female';
    }
    return null;
  }

  String? _extractChronicDisease(String conversation) {
    final value = _firstMatch(conversation, [
      RegExp(
        r'(?:chronic\s*diseases?|chronic\s*illness)\s*[:\-]?\s*([^\n\r]+)',
        multiLine: true,
        caseSensitive: false,
      ),
      RegExp(
        r'(?:امراض\s*مزمنة|أمراض\s*مزمنة|مرض\s*مزمن)\s*[:\-]?\s*([^\n\r]+)',
        multiLine: true,
      ),
    ]);

    if (value == null) {
      return null;
    }

    final normalized = value.toLowerCase();
    if (RegExp(r'\b(no|none|nothing|nil)\b').hasMatch(normalized) ||
        normalized.contains('لا يوجد') ||
        normalized.contains('مافي') ||
        normalized.contains('ما في')) {
      return 'None';
    }
    return value;
  }

  Future<void> _printAiCasesTable() async {
    final allCases = await LocalDatabaseService.instance.getAllAICases();
    print('[AI_CASES_TABLE] total_rows=${allCases.length}');
    for (final row in allCases) {
      print('[AI_CASES_TABLE] ${jsonEncode(row.toMap())}');
    }
  }

  void _printTriageJsonOutput(String aiReply) {
    final conversation = _allConversationText();
    final aiCorpus = _allAiRepliesText();

    final structuredFromReply = _extractStructuredTriage(aiReply);
    final structuredFromCorpus = _extractStructuredTriage(aiCorpus);

    final age = structuredFromReply?.age ??
        structuredFromCorpus?.age ??
        _extractAge(conversation) ??
        '';
    final gender = structuredFromReply?.gender ??
        structuredFromCorpus?.gender ??
        _extractGender(conversation) ??
        '';
    final chronicDisease = structuredFromReply?.chronicDisease ??
        structuredFromCorpus?.chronicDisease ??
        _extractChronicDisease(conversation) ??
        '';
    final possibleDisease = structuredFromReply?.possibleDisease ??
        structuredFromCorpus?.possibleDisease ??
        _extractPossibleDisease(aiReply) ??
        _extractPossibleDisease(aiCorpus) ??
        '';
    final emergencyLevel = structuredFromReply?.emergencyLevel ??
        structuredFromCorpus?.emergencyLevel ??
        _extractEmergencyLevel(aiReply) ??
        _extractEmergencyLevel(aiCorpus) ??
        '';

    print(
      '[AI_JSON] ${jsonEncode({
            'age': age,
            'gender': gender,
            'chronic Disease': chronicDisease,
            'possible Disease': possibleDisease,
            'emergency Level': emergencyLevel,
          })}',
    );
  }

  Future<_StructuredTriageData?> _requestFinalTriageJson() async {
    final uri = _chatEndpoint();
    final conversation = _allConversationText();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_localApiKey',
      },
      body: jsonEncode({
        'model': _localModel,
        'format': 'json',
        'messages': [
          {
            'role': 'system',
            'content': _triageJsonContract,
          },
          {
            'role': 'user',
            'content':
                'The conversation is complete. Fill the JSON fields from this conversation and return only the JSON object. If unknown use "".\n\n$conversation',
          },
        ],
        'stream': false,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    String? contentText;

    final directMessage = decoded['message'];
    if (directMessage is Map<String, dynamic>) {
      final content = directMessage['content'];
      if (content is String && content.trim().isNotEmpty) {
        contentText = content.trim();
      } else if (content is Map || content is List) {
        contentText = jsonEncode(content);
      }
    }

    if (contentText == null || contentText.isEmpty) {
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final firstChoice = choices.first;
        if (firstChoice is Map<String, dynamic>) {
          final choiceMessage = firstChoice['message'];
          if (choiceMessage is Map<String, dynamic>) {
            final content = choiceMessage['content'];
            if (content is String && content.trim().isNotEmpty) {
              contentText = content.trim();
            } else if (content is Map || content is List) {
              contentText = jsonEncode(content);
            }
          }
        }
      }
    }

    if (contentText == null || contentText.isEmpty) {
      return null;
    }

    return _extractStructuredTriage(contentText);
  }

  Future<void> _tryPersistAiCase(String aiReply) async {
    if (_caseSavedForConversation) {
      return;
    }

    final cpr = await PatientSessionService.getCurrentPatientCpr();
    if (cpr == null || cpr.trim().isEmpty) {
      return;
    }
    final normalizedCpr = cpr.trim();

    final existingPatient =
        await LocalDatabaseService.instance.getEKeyByCpr(normalizedCpr);
    if (existingPatient == null) {
      return;
    }

    final conversation = _allConversationText();
    final aiCorpus = _allAiRepliesText();

    final structuredFromReply = _extractStructuredTriage(aiReply);
    final structuredFromCorpus = _extractStructuredTriage(aiCorpus);

    final possibleDisease =
        structuredFromReply?.possibleDisease ??
        structuredFromCorpus?.possibleDisease ??
        _extractPossibleDisease(aiReply) ??
        _extractPossibleDisease(aiCorpus);
    final emergencyLevel =
        structuredFromReply?.emergencyLevel ??
        structuredFromCorpus?.emergencyLevel ??
        _extractEmergencyLevel(aiReply) ??
        _extractEmergencyLevel(aiCorpus);

    final isLikelyFinal =
        _isFinalTriageReply(aiReply) ||
        (structuredFromReply?.hasCoreResults ?? false);
    final hasCoreResults =
        (possibleDisease != null && possibleDisease.isNotEmpty) &&
            (emergencyLevel != null && emergencyLevel.isNotEmpty);

    if (!isLikelyFinal && !hasCoreResults) {
      return;
    }

    final finalStructured = await _requestFinalTriageJson();
    if (finalStructured != null) {
      print('[AI_JSON] ${jsonEncode(finalStructured.toMap())}');
    } else {
      _printTriageJsonOutput(aiReply);
    }

    final age = finalStructured?.age ??
        structuredFromReply?.age ??
        structuredFromCorpus?.age ??
        _extractAge(conversation);
    final gender = finalStructured?.gender ??
        structuredFromReply?.gender ??
        structuredFromCorpus?.gender ??
        _extractGender(conversation);
    final chronicDisease = finalStructured?.chronicDisease ??
        structuredFromReply?.chronicDisease ??
        structuredFromCorpus?.chronicDisease ??
        _extractChronicDisease(conversation);

    final resolvedPossibleDisease = finalStructured?.possibleDisease ?? possibleDisease;
    final resolvedEmergencyLevel = finalStructured?.emergencyLevel ?? emergencyLevel;

    final aiCase = AICase(
      caseId: 'CASE-${DateTime.now().millisecondsSinceEpoch}',
      cpr: normalizedCpr,
      age: age,
      gender: gender,
      chronicDisease: chronicDisease,
      possibleDisease: resolvedPossibleDisease,
      emergencyLevel: resolvedEmergencyLevel,
    );

    await LocalDatabaseService.instance.insertAICase(aiCase);
    await _printAiCasesTable();
    _caseSavedForConversation = true;
  }

  Future<String> _generateAiReply() async {
    final uri = _chatEndpoint();

    final recentMessages = _messages.length > 24
        ? _messages.sublist(_messages.length - 24)
        : _messages;

    final chatMessages = recentMessages
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_localApiKey',
      },
      body: jsonEncode({
        'model': _localModel,
        'messages': [
          if (_systemPromptOne.isNotEmpty)
            {
              'role': 'system',
              'content': _systemPromptOne,
            },
          if (_systemPromptTwo.isNotEmpty)
            {
              'role': 'system',
              'content': _systemPromptTwo,
            },
          ...chatMessages,
        ],
        'stream': false,
      }),
    );

    if (response.statusCode != 200) {
      String? providerError;
      try {
        final errorDecoded = jsonDecode(response.body);
        if (errorDecoded is Map<String, dynamic>) {
          final err = errorDecoded['error'];
          if (err is String && err.trim().isNotEmpty) {
            providerError = err.trim();
          } else if (err is Map<String, dynamic>) {
            final msg = err['message'];
            if (msg is String && msg.trim().isNotEmpty) {
              providerError = msg.trim();
            }
          }
        }
      } catch (_) {
        // Ignore parse issues and keep generic fallback.
      }

      if (providerError != null) {
        return 'AI provider error (${response.statusCode}): $providerError';
      }
      return 'I\'m having trouble reaching the AI service right now. Please try again in a moment.';
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      return 'I could not parse the AI response. Please try again.';
    }

    final directMessage = decoded['message'];
    if (directMessage is Map<String, dynamic>) {
      final content = directMessage['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content.trim();
      }
    }

    // Fallback parser for OpenAI-compatible response shapes.
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      return 'I do not have a response right now. Please try rephrasing your question.';
    }

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return 'I do not have a response right now. Please try again.';
    }

    final message = firstChoice['message'];
    if (message is! Map<String, dynamic>) {
      return 'I do not have a response right now. Please try again.';
    }

    final content = message['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        if (part is Map<String, dynamic>) {
          final text = part['text'];
          if (text is String && text.trim().isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            buffer.write(text.trim());
          }
        }
      }

      if (buffer.isNotEmpty) {
        return buffer.toString();
      }
    }

    return 'I do not have a response right now. Please try again.';
  }

  Future<void> _sendMessage() async {
    if (_isSending) {
      return;
    }

    final prompt = _model.textController?.text.trim() ?? '';
    if (prompt.isEmpty) {
      return;
    }

    safeSetState(() {
      _messages.add(
        _ChatMessage(
          text: prompt,
          isUser: true,
          createdAt: DateTime.now(),
        ),
      );
      _model.textController?.clear();
      _isSending = true;
      _isBotTyping = true;
    });
    _scrollToBottom();

    try {
      final aiReply = await _generateAiReply();
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _messages.add(
          _ChatMessage(
            text: aiReply,
            isUser: false,
            createdAt: DateTime.now(),
          ),
        );
      });
      try {
        await _tryPersistAiCase(aiReply);
      } catch (_) {
        // Ignore persistence errors to keep chat response flow uninterrupted.
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _messages.add(
          _ChatMessage(
            text:
                'I\'m unable to connect right now. Please check your internet and try again.',
            isUser: false,
            createdAt: DateTime.now(),
          ),
        );
      });
    } finally {
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _isSending = false;
        _isBotTyping = false;
      });
      _scrollToBottom();
    }
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;
    final bubbleWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.7 : 0.75);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            isUser ? 48.0 : 0.0,
            0.0,
            isUser ? 0.0 : 48.0,
            10.0,
          ),
          child: Container(
            width: bubbleWidth,
            decoration: BoxDecoration(
              color: isUser ? null : Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 12.0,
                  color: isUser
                      ? const Color(0x33E8735A)
                      : const Color(0x1A000000),
                  offset: const Offset(0.0, 4.0),
                )
              ],
              gradient: isUser
                  ? const LinearGradient(
                      colors: [Color(0xFFE8735A), Color(0xFFFF9A7A)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(1.0, 1.0),
                      end: AlignmentDirectional(-1.0, -1.0),
                    )
                  : null,
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? 'Patient' : 'Pre-Diagno AI',
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                          ),
                          color: isUser
                              ? const Color(0xFF5D2D2D)
                              : const Color(0xFFE8735A),
                          fontSize: 11.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                  ),
                  Text(
                    message.text,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: const Color(0xFF2D2D2D),
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          lineHeight: 1.5,
                        ),
                  ),
                  Text(
                    _formatTime(message.createdAt),
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).labelSmall.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).labelSmall.fontStyle,
                          ),
                          color:
                              isUser ? const Color(0xFF5D2D2D) : const Color(0xFF9E9E9E),
                          fontSize: 10.0,
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).labelSmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).labelSmall.fontStyle,
                        ),
                  ),
                ].divide(const SizedBox(height: 8.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 48.0, 10.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.45,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12.0,
                  color: Color(0x1A000000),
                  offset: Offset(0.0, 4.0),
                )
              ],
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8735A)),
                    ),
                  ),
                  Text(
                    'AI is typing...',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.inter(
                            fontWeight:
                                FlutterFlowTheme.of(context).bodySmall.fontWeight,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          color: const Color(0xFF6A6A6A),
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                  ),
                ].divide(const SizedBox(width: 10.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5EEE8),
        endDrawer: Drawer(
          elevation: 16.0,
          child: wrapWithModel(
            model: _model.patientThreeDashModel,
            updateCallback: () => safeSetState(() {}),
            child: const PatientThreeDashWidget(),
          ),
        ),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5EEE8),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
            child: FlutterFlowIconButton(
              borderColor: const Color(0xFFE8735A),
              borderRadius: 22.0,
              borderWidth: 1.0,
              buttonSize: 44.0,
              fillColor: Colors.white,
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Color(0xFFE8735A),
                size: 20.0,
              ),
              onPressed: () async {
                context.replaceNamed(PatientHomePageWidget.routeName);
              },
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'AI Assistant',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleMedium.fontStyle,
                      ),
                      color: const Color(0xFF2D2D2D),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
              ),
              Text(
                'Pre-Diagno • Online',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight:
                            FlutterFlowTheme.of(context).labelSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: const Color(0xFFE8735A),
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).labelSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
            ],
          ),
          actions: [
            Container(
              width: 44.79,
              height: 77.8,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
              child: Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 12.0,
                    buttonSize: 44.0,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 26.0,
                    ),
                    onPressed: () async {
                      scaffoldKey.currentState!.openEndDrawer();
                    },
                  ),
                ),
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 1.0,
                decoration: const BoxDecoration(
                  color: Color(0x1AE8735A),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: ListView.builder(
                    controller: _chatScrollController,
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
                    itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isBotTyping && index == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20.0,
                      color: Color(0x12000000),
                      offset: Offset(0.0, -4.0),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      12.0, 12.0, 12.0, 14.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(24.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  width: 1.5,
                                ),
                              ),
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                textCapitalization: TextCapitalization.none,
                                textAlign: TextAlign.start,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: 'Type your message…',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 12.0, 16.0, 12.0),
                                ),
                                style:
                                    FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                maxLines: 5,
                                minLines: 1,
                                keyboardType: TextInputType.multiline,
                                cursorColor: FlutterFlowTheme.of(context).primary,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _isSending ? null : () async => _sendMessage(),
                            borderRadius: BorderRadius.circular(23.0),
                            child: Container(
                              width: 46.0,
                              height: 46.0,
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 8.0,
                                    color: Color(0x33000000),
                                    offset: Offset(0.0, 2.0),
                                  )
                                ],
                                gradient: LinearGradient(
                                  colors: _isSending
                                      ? const [
                                          Color(0xFFEDAE9F),
                                          Color(0xFFF9C5B8)
                                        ]
                                      : const [
                                          Color(0xFFE8735A),
                                          Color(0xFFFF9A7A)
                                        ],
                                  stops: const [0.0, 1.0],
                                  begin: const AlignmentDirectional(1.0, 1.0),
                                  end: const AlignmentDirectional(-1.0, -1.0),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: _isSending
                                    ? const SizedBox(
                                        width: 18.0,
                                        height: 18.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 20.0,
                                      ),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            6.0, 8.0, 6.0, 0.0),
                        child: Center(
                          child: Text(
                            'It\'s AI, not a doctor',
                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                  ),
                                  color: const Color.fromARGB(255, 253, 122, 83),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
