import '/backend/local_db/local_database.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_employee_model.dart';
export 'add_employee_model.dart';

class AddEmployeeWidget extends StatefulWidget {
  const AddEmployeeWidget({super.key});

  static String routeName = 'AddEmployee';
  static String routePath = '/addEmployee';

  @override
  State<AddEmployeeWidget> createState() => _AddEmployeeWidgetState();
}

class _AddEmployeeWidgetState extends State<AddEmployeeWidget> {
  late AddEmployeeModel _model;
  final _formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSubmitting = false;
  String? _roleError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddEmployeeModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String field) {
    if ((value ?? '').trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(kTextValidatorEmailRegex);
    if (!regex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) {
      return 'Confirm password is required';
    }
    if (confirm != _model.textController4.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _createEmployee() async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    safeSetState(() {
      _formError = null;
      _roleError = null;
    });

    final role = _model.dropDownValue;
    if (role == null || role.isEmpty) {
      safeSetState(() => _roleError = 'Role is required');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final employeeId = _model.textController1.text.trim();
    final fullName = _model.textController2.text.trim();
    final email = _model.textController3.text.trim().toLowerCase();
    final password = _model.textController4.text;
    final isAdmin = role == 'Admin';

    safeSetState(() => _isSubmitting = true);
    try {
      final db = LocalDatabaseService.instance;

      final existingById = await db.getEmployeeById(employeeId);
      if (existingById != null) {
        safeSetState(() => _formError = 'Employee ID already exists');
        return;
      }

      final allEmployees = await db.getAllEmployees();
      final duplicateEmail = allEmployees.any(
        (e) => (e.email ?? '').trim().toLowerCase() == email,
      );
      if (duplicateEmail) {
        safeSetState(() => _formError = 'Email is already registered');
        return;
      }

      await db.insertEmployee(
        Employee(
          employeeId: employeeId,
          email: email,
          password: password,
          name: fullName,
          isAdmin: isAdmin,
        ),
      );

      if (!mounted) {
        return;
      }

      showSnackbar(context, 'Employee account created successfully');
      _model.textController1?.clear();
      _model.textController2?.clear();
      _model.textController3?.clear();
      _model.textController4?.clear();
      _model.textController5?.clear();
      _model.dropDownValueController?.value = null;
      safeSetState(() {
        _model.dropDownValue = null;
        _roleError = null;
        _formError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      safeSetState(() {
        _formError = 'Failed to create account. Please try again.';
      });
    } finally {
      if (mounted) {
        safeSetState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            color: const Color(0xFFBBAEDD),
            letterSpacing: 0.0,
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFD8C8F0),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFF7B5EA7),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).error,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14.0),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F4FF),
      contentPadding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF7B5EA7),
        size: 20.0,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
            ),
            color: const Color(0xFF7B5EA7),
            fontSize: 11.0,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
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
        backgroundColor: const Color(0xFFF3F0FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF3F0FF),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 22.0,
            buttonSize: 44.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF7B5EA7),
              size: 22.0,
            ),
            onPressed: () async {
              context.replaceNamed(NewAdminHomePageWidget.routeName);
            },
          ),
          title: Text(
            'Add New Account',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                  ),
                  color: const Color(0xFF7B5EA7),
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24.0,
                        color: Color(0x337B5EA7),
                        offset: Offset(0.0, 8.0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF7B5EA7), Color(0xFFA78BCA)],
                                stops: [0.0, 1.0],
                                begin: AlignmentDirectional(1.0, 1.0),
                                end: AlignmentDirectional(-1.0, -1.0),
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18.0),
                        _fieldLabel(context, 'EMPLOYEE ID'),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          decoration: _inputDecoration(
                            context: context,
                            hint: 'Enter employee ID',
                            icon: Icons.badge_outlined,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D1B69),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          validator: (v) =>
                              _requiredValidator(v, 'Employee ID'),
                        ),
                        const SizedBox(height: 14.0),
                        _fieldLabel(context, 'FULL NAME'),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            context: context,
                            hint: 'Enter full name',
                            icon: Icons.person_rounded,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D1B69),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          validator: (v) => _requiredValidator(v, 'Full name'),
                          inputFormatters: [
                            if (!isAndroid && !isiOS)
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                return TextEditingValue(
                                  selection: newValue.selection,
                                  text: newValue.text.toCapitalization(
                                      TextCapitalization.words),
                                );
                              }),
                          ],
                        ),
                        const SizedBox(height: 14.0),
                        _fieldLabel(context, 'EMAIL ADDRESS'),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            context: context,
                            hint: 'staff@prediagno.com',
                            icon: Icons.email_rounded,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D1B69),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 14.0),
                        _fieldLabel(context, 'PASSWORD'),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _model.textController4,
                          focusNode: _model.textFieldFocusNode4,
                          obscureText: !_model.passwordVisibility1,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: _inputDecoration(
                            context: context,
                            hint: 'Create a strong password',
                            icon: Icons.lock_rounded,
                            suffixIcon: InkWell(
                              onTap: () async {
                                safeSetState(() => _model.passwordVisibility1 =
                                    !_model.passwordVisibility1);
                              },
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 22,
                              ),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D1B69),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 14.0),
                        _fieldLabel(context, 'RE-ENTER PASSWORD'),
                        const SizedBox(height: 6.0),
                        TextFormField(
                          controller: _model.textController5,
                          focusNode: _model.textFieldFocusNode5,
                          obscureText: !_model.passwordVisibility2,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: _inputDecoration(
                            context: context,
                            hint: 'Confirm your password',
                            icon: Icons.lock_outline,
                            suffixIcon: InkWell(
                              onTap: () async {
                                safeSetState(() => _model.passwordVisibility2 =
                                    !_model.passwordVisibility2);
                              },
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 22,
                              ),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF2D1B69),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          validator: _confirmPasswordValidator,
                        ),
                        const SizedBox(height: 14.0),
                        _fieldLabel(context, 'SELECT ROLE'),
                        const SizedBox(height: 6.0),
                        Container(
                          width: double.infinity,
                          height: 54.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F4FF),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: const Color(0xFFD8C8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medical_services_rounded,
                                  color: Color(0xFF7B5EA7),
                                  size: 20.0,
                                ),
                                Expanded(
                                  child: FlutterFlowDropDown<String>(
                                    controller:
                                        _model.dropDownValueController ??=
                                            FormFieldController<String>(null),
                                    options: const ['Admin', 'Medical Staff'],
                                    onChanged: (val) => safeSetState(() {
                                      _model.dropDownValue = val;
                                      _roleError = null;
                                    }),
                                    height: 52.0,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: const Color(0xFF2D1B69),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    hintText: 'Choose a role...',
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF7B5EA7),
                                      size: 22.0,
                                    ),
                                    fillColor: Colors.transparent,
                                    elevation: 4.0,
                                    borderColor: Colors.transparent,
                                    borderWidth: 0.0,
                                    borderRadius: 14.0,
                                    margin:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 12.0, 0.0),
                                    hidesUnderline: true,
                                    isOverButton: true,
                                    isSearchable: false,
                                    isMultiSelect: false,
                                  ),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ),
                        ),
                        if (_roleError != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                4.0, 6.0, 4.0, 0.0),
                            child: Text(
                              _roleError!,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        if (_formError != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                4.0, 8.0, 4.0, 0.0),
                            child: Text(
                              _formError!,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        const SizedBox(height: 18.0),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B5EA7), Color(0xFFA78BCA)],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 1.0),
                              end: AlignmentDirectional(-1.0, -1.0),
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: FFButtonWidget(
                            onPressed: _isSubmitting ? null : _createEmployee,
                            text: _isSubmitting
                                ? 'Creating...'
                                : 'Create Employee Account',
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              size: 22.0,
                            ),
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 58.0,
                              color: Colors.transparent,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              elevation: 0.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 0.0,
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
