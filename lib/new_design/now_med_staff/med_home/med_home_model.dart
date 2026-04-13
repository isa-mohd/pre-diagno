import '/flutter_flow/flutter_flow_util.dart';
import '/new_design/now_med_staff/med_notifications_component/med_notifications_component_widget.dart';
import '/settings/med_three/med_three_widget.dart';
import '/index.dart';
import 'med_home_widget.dart' show MedHomeWidget;
import 'package:flutter/material.dart';

class MedHomeModel extends FlutterFlowModel<MedHomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MedThree component.
  late MedThreeModel medThreeModel;
  // Model for MedNotificationsComponent component.
  late MedNotificationsComponentModel medNotificationsComponentModel;

  @override
  void initState(BuildContext context) {
    medThreeModel = createModel(context, () => MedThreeModel());
    medNotificationsComponentModel =
        createModel(context, () => MedNotificationsComponentModel());
  }

  @override
  void dispose() {
    medThreeModel.dispose();
    medNotificationsComponentModel.dispose();
  }
}
