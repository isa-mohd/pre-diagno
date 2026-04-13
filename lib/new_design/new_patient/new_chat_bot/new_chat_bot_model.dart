import '/flutter_flow/flutter_flow_util.dart';
import '/settings/patient_three_dash/patient_three_dash_widget.dart';
import '/index.dart';
import 'new_chat_bot_widget.dart' show NewChatBotWidget;
import 'package:flutter/material.dart';

class NewChatBotModel extends FlutterFlowModel<NewChatBotWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Model for PatientThreeDash component.
  late PatientThreeDashModel patientThreeDashModel;

  @override
  void initState(BuildContext context) {
    patientThreeDashModel = createModel(context, () => PatientThreeDashModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    patientThreeDashModel.dispose();
  }
}
