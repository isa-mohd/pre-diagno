import '/flutter_flow/flutter_flow_util.dart';
import '/settings/med_three/med_three_widget.dart';
import '/index.dart';
import 'actions_widget.dart' show ActionsWidget;
import 'package:flutter/material.dart';

class ActionsModel extends FlutterFlowModel<ActionsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MedThree component.
  late MedThreeModel medThreeModel;

  @override
  void initState(BuildContext context) {
    medThreeModel = createModel(context, () => MedThreeModel());
  }

  @override
  void dispose() {
    medThreeModel.dispose();
  }
}
