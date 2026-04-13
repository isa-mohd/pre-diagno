import '/flutter_flow/flutter_flow_util.dart';
import '/new_design/new_patient/patient_component_page/patient_component_page_widget.dart';
import '/settings/patient_three_dash/patient_three_dash_widget.dart';
import '/index.dart';
import 'patient_home_page_widget.dart' show PatientHomePageWidget;
import 'package:flutter/material.dart';

class PatientHomePageModel extends FlutterFlowModel<PatientHomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for PatientThreeDash component.
  late PatientThreeDashModel patientThreeDashModel;
  // Model for PatientComponentPage component.
  late PatientComponentPageModel patientComponentPageModel;

  @override
  void initState(BuildContext context) {
    patientThreeDashModel = createModel(context, () => PatientThreeDashModel());
    patientComponentPageModel =
        createModel(context, () => PatientComponentPageModel());
  }

  @override
  void dispose() {
    patientThreeDashModel.dispose();
    patientComponentPageModel.dispose();
  }
}
