import '/backend/local_db/local_database.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'requested_appointmets_model.dart';
export 'requested_appointmets_model.dart';

class RequestedAppointmetsWidget extends StatefulWidget {
  const RequestedAppointmetsWidget({super.key});

  static String routeName = 'RequestedAppointmets';
  static String routePath = '/requestedAppointmets';

  @override
  State<RequestedAppointmetsWidget> createState() =>
      _RequestedAppointmetsWidgetState();
}

class _RequestedAppointmetsWidgetState
    extends State<RequestedAppointmetsWidget> {
  late RequestedAppointmetsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _isUpdating = false;

  List<Appointment> _appointments = const [];
  Map<String, String> _patientNameByCpr = const {};
  Map<String, AICase> _caseByCpr = const {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RequestedAppointmetsModel());
    _loadRequestedAppointments();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadRequestedAppointments() async {
    safeSetState(() => _isLoading = true);
    try {
      final db = LocalDatabaseService.instance;
      final allAppointments = await db.getAllAppointments();
      final ekeys = await db.getAllEKeys();
      final cases = await db.getAllAICases();

      final requestedAppointments = allAppointments.where((a) {
        final status = (a.status ?? '').trim().toLowerCase();
        return status.isEmpty || status == 'pending' || status == 'requested';
      }).toList();

      final patientNameByCpr = <String, String>{
        for (final p in ekeys)
          p.cpr: (p.name != null && p.name!.trim().isNotEmpty)
              ? p.name!.trim()
              : p.cpr,
      };

      final caseByCpr = <String, AICase>{};
      for (final aiCase in cases) {
        caseByCpr.putIfAbsent(aiCase.cpr, () => aiCase);
      }

      if (!mounted) {
        return;
      }

      safeSetState(() {
        _appointments = requestedAppointments;
        _patientNameByCpr = patientNameByCpr;
        _caseByCpr = caseByCpr;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      safeSetState(() => _isLoading = false);
    }
  }

  String _patientName(String cpr) {
    return _patientNameByCpr[cpr] ?? cpr;
  }

  String _normalize(String? value, {String fallback = '-'}) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? fallback : v;
  }

  String _dateText(Appointment appointment) {
    return _normalize(appointment.date, fallback: 'N/A');
  }

  String _timeText(Appointment appointment) {
    return _normalize(appointment.time, fallback: 'N/A');
  }

  Future<void> _updateAppointmentStatus(
    Appointment appointment,
    String status,
  ) async {
    if (_isUpdating) {
      return;
    }

    safeSetState(() => _isUpdating = true);
    try {
      await LocalDatabaseService.instance.updateAppointment(
        appointment.copyWith(status: status),
      );
      if (!mounted) {
        return;
      }
      showSnackbar(
        context,
        status == 'accepted' ? 'Appointment accepted' : 'Appointment rejected',
      );
      await _loadRequestedAppointments();
    } catch (_) {
      if (!mounted) {
        return;
      }
      showSnackbar(context, 'Failed to update appointment status');
    } finally {
      if (mounted) {
        safeSetState(() => _isUpdating = false);
      }
    }
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
        backgroundColor: const Color(0xFFF0F4F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5B8DB8),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderRadius: 22.0,
            buttonSize: 44.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24.0,
            ),
            onPressed: () async {
              context.replaceNamed(MedHomeWidget.routeName);
            },
          ),
          title: Text(
            'Requested Appointments',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                  ),
                  color: Colors.white,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 6.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B8DB8), Color(0xFFF0F4F8)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadRequestedAppointments,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _appointments.isEmpty
                          ? ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Center(
                                    child: Text(
                                      'No requested appointments found.',
                                      style: FlutterFlowTheme.of(context)
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
                                            color: const Color(0xFF6A7785),
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
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 16.0, 16.0, 24.0),
                              itemCount: _appointments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14.0),
                              itemBuilder: (context, index) {
                                final appointment = _appointments[index];
                                final aiCase = _caseByCpr[appointment.cpr];
                                final sex = _normalize(aiCase?.gender);
                                final age = _normalize(aiCase?.age);

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 12.0,
                                        color: Color(0x1A5B8DB8),
                                        offset: Offset(0.0, 4.0),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5B8DB8),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Case No. ${_normalize(appointment.appointmentId)}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0x33FFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 5.0),
                                                child: Text(
                                                  _normalize(
                                                    appointment.status,
                                                    fallback: 'pending',
                                                  ),
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
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          _patientName(appointment.cpr),
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
                                                color: const Color(0xFF1A2E42),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Sex: $sex',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Age: $age',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Date: ${_dateText(appointment)}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Time: ${_timeText(appointment)}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6.0),
                                        Text(
                                          'Doctor: ${_normalize(appointment.doctorName, fallback: 'Unassigned')}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 12.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: _isUpdating
                                                    ? null
                                                    : () async {
                                                        await _updateAppointmentStatus(
                                                          appointment,
                                                          'accepted',
                                                        );
                                                      },
                                                text: 'Accept',
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  color:
                                                      const Color(0xFF2E9E6B),
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: _isUpdating
                                                    ? null
                                                    : () async {
                                                        await _updateAppointmentStatus(
                                                          appointment,
                                                          'rejected',
                                                        );
                                                      },
                                                text: 'Reject',
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  color:
                                                      const Color(0xFFE05252),
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 12.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
