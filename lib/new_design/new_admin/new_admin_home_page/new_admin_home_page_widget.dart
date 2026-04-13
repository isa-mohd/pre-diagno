import '/backend/local_db/admin_session.dart';
import '/backend/local_db/local_database.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/new_design/new_admin/admin_notification/admin_notification_widget.dart';
import '/settings/admin_three/admin_three_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'new_admin_home_page_model.dart';
export 'new_admin_home_page_model.dart';

class NewAdminHomePageWidget extends StatefulWidget {
  const NewAdminHomePageWidget({super.key});

  static String routeName = 'NewAdminHomePage';
  static String routePath = '/newAdminHomePage';

  @override
  State<NewAdminHomePageWidget> createState() => _NewAdminHomePageWidgetState();
}

class _NewAdminHomePageWidgetState extends State<NewAdminHomePageWidget> {
  late NewAdminHomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _adminName = 'Admin';
  int _totalStaff = 0;
  int _totalEmployees = 0;
  int _appointmentCount = 0;
  int _criticalEmergencyCount = 0;
  bool _isLoading = true;

  List<Employee> _previewEmployees = const [];
  List<Appointment> _previewAppointments = const [];
  Map<String, String> _patientNameByCpr = const {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewAdminHomePageModel());
    _loadDashboardData();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    safeSetState(() => _isLoading = true);
    try {
      final db = LocalDatabaseService.instance;
      final currentEmployee = await AdminSessionService.getCurrentEmployee();
      final employees = await db.getAllEmployees();
      final appointments = await db.getAllAppointments();
      final aiCases = await db.getAllAICases();
      final patients = await db.getAllEKeys();

      final resolvedName = currentEmployee?.name?.trim();
      final totalStaff = employees.where((e) => !e.isAdmin).length;
      final emergencyCount = aiCases.where((c) {
        final level = _parseEmergencyLevel(c.emergencyLevel);
        return level == 1 || level == 2;
      }).length;
      final patientNameByCpr = <String, String>{
        for (final p in patients)
          p.cpr: (p.name != null && p.name!.trim().isNotEmpty)
              ? p.name!.trim()
              : p.cpr,
      };

      if (!mounted) {
        return;
      }

      safeSetState(() {
        _adminName = (resolvedName == null || resolvedName.isEmpty)
            ? 'Admin'
            : resolvedName;
        _totalStaff = totalStaff;
        _totalEmployees = employees.length;
        _appointmentCount = appointments.length;
        _criticalEmergencyCount = emergencyCount;
        _previewEmployees = employees.take(3).toList();
        _previewAppointments = appointments.take(3).toList();
        _patientNameByCpr = patientNameByCpr;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      safeSetState(() => _isLoading = false);
    }
  }

  int _parseEmergencyLevel(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return -1;
    }
    final direct = int.tryParse(value);
    if (direct != null) {
      return direct;
    }
    final match = RegExp(r'\d+').firstMatch(value);
    if (match == null) {
      return -1;
    }
    return int.tryParse(match.group(0) ?? '') ?? -1;
  }

  String _initials(String? input) {
    final words = (input ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return 'NA';
    }
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  String _patientLabel(String cpr) {
    return _patientNameByCpr[cpr] ?? cpr;
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'done':
      case 'completed':
        return const Color.fromARGB(50, 98, 163, 101);
      case 'cancelled':
      case 'rejected':
        return const Color(0x1AE53935);
      case 'pending':
      default:
        return const Color(0x1AFFA726);
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'done':
      case 'completed':
        return const Color(0xFF43A047);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFE53935);
      case 'pending':
      default:
        return const Color(0xFFFFA726);
    }
  }

  Widget _metricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        height: 108.0,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 14.0,
              color: Color(0x1A7B5EA7),
              offset: Offset(0.0, 4.0),
            ),
          ],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: iconColor, size: 18.0),
              ),
              Text(
                value,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.interTight(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .fontStyle,
                      ),
                      color: const Color(0xFF2D2D3A),
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                    ),
              ),
              Text(
                label,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: const Color(0xFF8A8A9A),
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
            ].divide(const SizedBox(height: 4.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(BuildContext context, Employee employee, int index) {
    final palette = <Color>[
      const Color(0xFF7B5EA7),
      const Color(0xFF9B7EC8),
      const Color(0xFF5C8FD6),
    ];
    final color = palette[index % palette.length];
    final roleLabel = employee.isAdmin ? 'Admin' : 'Medical Staff';
    final subtitle = (employee.email != null && employee.email!.isNotEmpty)
        ? employee.email!
        : 'ID: ${employee.employeeId}';

    return Container(
      width: double.infinity,
      height: 72.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    _initials(employee.name),
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontStyle,
                          ),
                          color: Colors.white,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (employee.name == null || employee.name!.trim().isEmpty)
                          ? employee.employeeId
                          : employee.name!.trim(),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: const Color(0xFF2D2D3A),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                            ),
                            color: const Color(0xFF8A8A9A),
                            fontSize: 11.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelSmall
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              ].divide(const SizedBox(width: 12.0)),
            ),
            Container(
              decoration: BoxDecoration(
                color: employee.isAdmin
                    ? const Color(0x1A5C8FD6)
                    : const Color(0x1A7B5EA7),
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Text(
                roleLabel,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: employee.isAdmin
                          ? const Color(0xFF5C8FD6)
                          : const Color(0xFF7B5EA7),
                      fontSize: 11.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentRow(BuildContext context, Appointment appointment) {
    final status = (appointment.status ?? 'Pending').trim();
    final appointmentDate = (appointment.date ?? '').trim().isEmpty
        ? 'N/A'
        : appointment.date!.trim();
    final appointmentTime = (appointment.time ?? '').trim().isEmpty
        ? 'N/A'
        : appointment.time!.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patientLabel(appointment.cpr),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                Text(
                  (appointment.doctorName == null ||
                          appointment.doctorName!.trim().isEmpty)
                      ? 'Doctor not assigned'
                      : appointment.doctorName!.trim(),
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 11.0,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodySmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodySmall.fontStyle,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              appointmentDate,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              appointmentTime,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).bodySmall.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
            ),
          ),
          Container(
            width: 82.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: _statusBgColor(status),
              borderRadius: BorderRadius.circular(20.0),
            ),
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Text(
              status,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                    ),
                    color: _statusTextColor(status),
                    fontSize: 10.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelSmall.fontStyle,
                  ),
            ),
          ),
        ],
      ),
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
        backgroundColor: const Color(0xFFF5F3FF),
        drawer: Drawer(
          elevation: 16.0,
          child: wrapWithModel(
            model: _model.adminNotificationModel,
            updateCallback: () => safeSetState(() {}),
            child: const AdminNotificationWidget(),
          ),
        ),
        endDrawer: Drawer(
          elevation: 16.0,
          child: wrapWithModel(
            model: _model.adminThreeModel,
            updateCallback: () => safeSetState(() {}),
            child: const AdminThreeWidget(),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B5EA7), Color(0xFF9B7EC8)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(1.0, 1.0),
                    end: AlignmentDirectional(-1.0, -1.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 50.0, 20.0, 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PRE-DIAGNO',
                            style: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  color: const Color(0xCCFFFFFF),
                                  fontSize: 11.0,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                          ),
                          Text(
                            'Welcome, ${_adminName.split(" ")[0]}',
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  fontSize: 26.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                          ),
                          Text(
                            'Healthcare Management Dashboard',
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .fontStyle,
                                      ),
                                      color: const Color(0xCCFFFFFF),
                                      fontSize: 13.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState!.openDrawer();
                            },
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: const Color(0x33FFFFFF),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 22.0,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              scaffoldKey.currentState!.openEndDrawer();
                            },
                            child: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: const Color(0x33FFFFFF),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: const AlignmentDirectional(0.0, 0.0),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 22.0,
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _metricCard(
                                context: context,
                                icon: Icons.people_outline,
                                iconColor: const Color(0xFF7B5EA7),
                                iconBg: const Color(0x1A7B5EA7),
                                value: _totalStaff.toString(),
                                label: 'Total Staff',
                              ),
                              _metricCard(
                                context: context,
                                icon: Icons.event_available_outlined,
                                iconColor: const Color(0xFF00AA88),
                                iconBg: const Color(0x1A00AA88),
                                value: _appointmentCount.toString(),
                                label: 'Appointments',
                              ),
                              _metricCard(
                                context: context,
                                icon: Icons.emergency_outlined,
                                iconColor: const Color(0xFFFF5252),
                                iconBg: const Color(0x1AFF5252),
                                value: _criticalEmergencyCount.toString(),
                                label: 'Emergencies',
                              ),
                            ].divide(const SizedBox(width: 12.0)),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20.0,
                                  color: Color(0x1A7B5EA7),
                                  offset: Offset(0.0, 6.0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 36.0,
                                            height: 36.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0x1A7B5EA7),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            alignment:
                                                const AlignmentDirectional(
                                                    0.0, 0.0),
                                            child: const Icon(
                                              Icons.manage_accounts_outlined,
                                              color: Color(0xFF7B5EA7),
                                              size: 20.0,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Staff & Admin',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: const Color(
                                                              0xFF2D2D3A),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              Text(
                                                'Latest records (max 3)',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: const Color(
                                                              0xFF8A8A9A),
                                                          fontSize: 11.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelSmall
                                                                  .fontStyle,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ].divide(const SizedBox(width: 10.0)),
                                      ),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          context.replaceNamed(
                                              AddEmployeeWidget.routeName);
                                        },
                                        text: '+Add',
                                        options: FFButtonOptions(
                                          height: 32.0,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(14.0, 0.0, 14.0, 0.0),
                                          color: const Color(0xFF7B5EA7),
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                          elevation: 0.0,
                                          borderSide: const BorderSide(
                                              color: Colors.transparent),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 24.0,
                                    thickness: 1.0,
                                    color: Color(0xFFF0EBF8),
                                  ),
                                  if (_isLoading)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (_previewEmployees.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        'No staff/admin records found.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color: const Color(0xFF8A8A9A),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: List.generate(
                                        _previewEmployees.length,
                                        (index) => Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0,
                                                  index == 0 ? 0.0 : 8.0,
                                                  0.0,
                                                  0.0),
                                          child: _buildEmployeeRow(
                                            context,
                                            _previewEmployees[index],
                                            index,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 0.0),
                                    child: InkWell(
                                      onTap: () async {
                                        context.replaceNamed(
                                          StaffAdminManagementPageWidget
                                              .routeName,
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0EBF8),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.people_outline,
                                              color: Color(0xFF7B5EA7),
                                              size: 16.0,
                                            ),
                                            Text(
                                              ' View All $_totalEmployees Members',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color:
                                                        const Color(0xFF7B5EA7),
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 12.0,
                                  color: Color(0x0D000000),
                                  offset: Offset(0.0, 3.0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_note_outlined,
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            size: 20.0,
                                          ),
                                          Text(
                                            ' Appointments',
                                            style: FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 82.0,
                                        height: 28.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0x1A00AA88),
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        alignment: const AlignmentDirectional(
                                            0.0, 0.0),
                                        child: Text(
                                          '$_appointmentCount Total',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                fontSize: 11.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 18.0,
                                    thickness: 1.0,
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text('Patient')),
                                          Expanded(child: Text('Date')),
                                          Expanded(child: Text('Time')),
                                          SizedBox(
                                            width: 82.0,
                                            child: Text(
                                              'Status',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_isLoading)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (_previewAppointments.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      child: Text(
                                        'No appointment records found.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color: const Color(0xFF8A8A9A),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                      ),
                                    )
                                  else
                                    Column(
                                      children: List.generate(
                                        _previewAppointments.length,
                                        (index) {
                                          return Column(
                                            children: [
                                              _buildAppointmentRow(
                                                context,
                                                _previewAppointments[index],
                                              ),
                                              if (index !=
                                                  _previewAppointments.length -
                                                      1)
                                                Divider(
                                                  height: 1.0,
                                                  thickness: 1.0,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .alternate,
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 10.0),
                                  InkWell(
                                    onTap: () async {
                                      context.replaceNamed(
                                          ExtraAppointmetsWidget.routeName);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0EBF8),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.event_note_outlined,
                                            color: Color(0xFF7B5EA7),
                                            size: 16.0,
                                          ),
                                          Text(
                                            ' View All Appointments',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color:
                                                      const Color(0xFF7B5EA7),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
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
                        ],
                      ),
                    ),
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
