import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/backend/local_db/local_database.dart';
import '/backend/local_db/patient_session.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_booking_page_model.dart';
export 'new_booking_page_model.dart';

/// Generate a premium Appointment Booking Page for Pre-Diagno using the same
/// soft blush pink and coral style (#E8735A) as the patient interface.
///
/// Add a top section with a bold title “Book Your Appointment”, a short
/// subtitle, and a soft decorative blush-to-coral gradient header to make the
/// page feel elegant and polished.
///
/// In the body, create a single large rounded white or soft pink booking card
/// with coral-tinted shadows and generous spacing. Inside, add these stacked
/// fields in order: Department dropdown, Doctor dropdown, Date field, Time
/// field, and Reason for Visit text field. Use clear labels above each field,
/// subtle icons, dark readable text, and modern rounded inputs.
///
/// At the bottom, add a standout rounded Confirm Appointment button in coral.
/// Below the form, add a small elegant summary box previewing the selected
/// doctor, date, and time. Keep the page bright, clean, luxurious, and fully
/// readable with 16px padding, responsive layout, and Theme Variables only
/// for Light/Dark mode.
class NewBookingPageWidget extends StatefulWidget {
  const NewBookingPageWidget({super.key});

  static String routeName = 'NewBookingPage';
  static String routePath = '/newBookingPage';

  @override
  State<NewBookingPageWidget> createState() => _NewBookingPageWidgetState();
}

class _NewBookingPageWidgetState extends State<NewBookingPageWidget> {
  late NewBookingPageModel _model;
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _submitAppointment() async {
    if (_isSubmitting) {
      return;
    }

    final cpr = await PatientSessionService.getCurrentPatientCpr();
    if (cpr == null) {
      showSnackbar(context, 'Please login again to continue.');
      return;
    }

    final doctor = _model.dropDownValue1?.trim();
    final time = _model.dropDownValue2?.trim();
    final reason = _model.textController.text.trim();

    if (doctor == null || doctor.isEmpty) {
      showSnackbar(context, 'Doctor field is required.');
      return;
    }
    if (_selectedDate == null) {
      showSnackbar(context, 'Preferred date is required.');
      return;
    }
    if (time == null || time.isEmpty) {
      showSnackbar(context, 'Preferred time is required.');
      return;
    }

    safeSetState(() => _isSubmitting = true);
    try {
      final appointment = Appointment(
        appointmentId: 'APT-${DateTime.now().millisecondsSinceEpoch}',
        cpr: cpr,
        doctorName: doctor,
        date: dateTimeFormat('y-MM-dd', _selectedDate),
        time: time,
        reson: reason.isEmpty ? null : reason,
        status: 'pending',
      );

      await LocalDatabaseService.instance.insertAppointment(appointment);
      if (!mounted) {
        return;
      }
      showSnackbar(context, 'Appointment requested successfully.');
      safeSetState(() {
        _model.dropDownValueController1?.value = null;
        _model.dropDownValue1 = null;
        _model.dropDownValueController2?.value = null;
        _model.dropDownValue2 = null;
        _selectedDate = null;
        _model.textController?.clear();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      showSnackbar(context, 'Could not request appointment. Please try again.');
    } finally {
      if (mounted) {
        safeSetState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewBookingPageModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
        backgroundColor: const Color(0xFFFFF5F0),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 200.0,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFDDD5), Color(0xFFE8735A)],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(1.0, 1.0),
                    end: AlignmentDirectional(-1.0, -1.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 0.0, 24.0, 50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            12.0, 0.0, 12.0, 0.0),
                        child: FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 20.0,
                          buttonSize: 40.0,
                          fillColor: const Color(0x33FFFFFF),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22.0,
                          ),
                          onPressed: () async {
                            context
                                .replaceNamed(PatientHomePageWidget.routeName);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 6.0),
                        child: Text(
                          'Book Your Appointment',
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .displaySmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .fontStyle,
                                lineHeight: 1.2,
                              ),
                        ),
                      ),
                      Text(
                        'Schedule a visit with our expert specialists',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: const Color(0xCCFFFFFF),
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.normal,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24.0,
                        color: Color(0x1AE8735A),
                        offset: Offset(
                          0.0,
                          8.0,
                        ),
                      )
                    ],
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8D5CF),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFFE8735A),
                                  size: 18.0,
                                ),
                                Text(
                                  'Doctor',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                        ),
                                        color: const Color(0xFF5C5C5C),
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                            FlutterFlowDropDown<String>(
                              controller: _model.dropDownValueController1 ??=
                                  FormFieldController<String>(null),
                              options: const [
                                'Dr. Amelia Carter',
                                'Dr. James Holloway',
                                'Dr. Priya Nair',
                                'Dr. Lucas Fernandez'
                              ],
                              onChanged: (val) => safeSetState(
                                  () => _model.dropDownValue1 = val),
                              width: double.infinity,
                              height: 52.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              hintText: 'Select Doctor',
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFFE8735A),
                                size: 22.0,
                              ),
                              fillColor: const Color(0xFFFFF5F0),
                              elevation: 0.0,
                              borderColor: const Color(0xFFE8D5CF),
                              borderWidth: 1.5,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              hidesUnderline: true,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8D5CF),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: Color(0xFFE8735A),
                                  size: 18.0,
                                ),
                                Text(
                                  'Preferred Date',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                        ),
                                        color: const Color(0xFF5C5C5C),
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                final today = DateTime.now();
                                final firstDate = DateTime(
                                    today.year, today.month, today.day);
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: firstDate,
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  safeSetState(
                                      () => _selectedDate = pickedDate);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5F0),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: const Color(0xFFE8D5CF),
                                    width: 1.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedDate != null
                                            ? dateTimeFormat(
                                                "yMMMd",
                                                _selectedDate,
                                              )
                                            : 'Select a date',
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
                                              color: _selectedDate != null
                                                  ? const Color(0xFF2D2D2D)
                                                  : const Color(0xFF9E9E9E),
                                              fontSize: 15.0,
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
                                      const Icon(
                                        Icons.event_rounded,
                                        color: Color(0xFFE8735A),
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  color: Color(0xFFE8735A),
                                  size: 18.0,
                                ),
                                Text(
                                  'Preferred Time',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                        ),
                                        color: const Color(0xFF5C5C5C),
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                            FlutterFlowDropDown<String>(
                              controller: _model.dropDownValueController2 ??=
                                  FormFieldController<String>(null),
                              options: const [
                                '09:00 AM',
                                '10:00 AM',
                                '11:00 AM',
                                '01:00 PM',
                                '02:30 PM',
                                '04:00 PM'
                              ],
                              onChanged: (val) => safeSetState(
                                  () => _model.dropDownValue2 = val),
                              width: double.infinity,
                              height: 52.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D2D2D),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              hintText: 'Select Time Slot',
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFFE8735A),
                                size: 22.0,
                              ),
                              fillColor: const Color(0xFFFFF5F0),
                              elevation: 0.0,
                              borderColor: const Color(0xFFE8D5CF),
                              borderWidth: 1.5,
                              borderRadius: 12.0,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              hidesUnderline: true,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8D5CF),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Icon(
                                  Icons.edit_note_rounded,
                                  color: Color(0xFFE8735A),
                                  size: 18.0,
                                ),
                                Text(
                                  'Reason for Visit',
                                  style: FlutterFlowTheme.of(context)
                                      .labelLarge
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelLarge
                                                  .fontStyle,
                                        ),
                                        color: const Color(0xFF5C5C5C),
                                        fontSize: 13.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelLarge
                                            .fontStyle,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 8.0)),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText:
                                      'Briefly describe your symptoms or reason...',
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
                                        color: const Color(0xFF9E9E9E),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE8D5CF),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE8735A),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFFFF5F0),
                                  contentPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          16.0, 14.0, 16.0, 14.0),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      color: const Color(0xFF2D2D2D),
                                      fontSize: 15.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  if (!isAndroid && !isiOS)
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      return TextEditingValue(
                                        selection: newValue.selection,
                                        text: newValue.text.toCapitalization(
                                            TextCapitalization.sentences),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ].divide(const SizedBox(height: 8.0)),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            await _submitAppointment();
                          },
                          showLoadingIndicator: _isSubmitting,
                          text: 'Request Appointment',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 56.0,
                            padding: const EdgeInsets.all(8.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: const Color(0xFFE8735A),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                            elevation: 0.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.0,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ].divide(const SizedBox(height: 20.0)),
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
