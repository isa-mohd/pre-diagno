import '/flutter_flow/flutter_flow_util.dart';
import '/new_design/new_admin/admin_notification/admin_notification_widget.dart';
import '/settings/admin_three/admin_three_widget.dart';
import '/index.dart';
import 'new_admin_home_page_widget.dart' show NewAdminHomePageWidget;
import 'package:flutter/material.dart';

class NewAdminHomePageModel extends FlutterFlowModel<NewAdminHomePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AdminThree component.
  late AdminThreeModel adminThreeModel;
  // Model for AdminNotification component.
  late AdminNotificationModel adminNotificationModel;

  @override
  void initState(BuildContext context) {
    adminThreeModel = createModel(context, () => AdminThreeModel());
    adminNotificationModel =
        createModel(context, () => AdminNotificationModel());
  }

  @override
  void dispose() {
    adminThreeModel.dispose();
    adminNotificationModel.dispose();
  }
}
