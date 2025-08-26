import 'package:chat_app/core/others/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

class ProfileViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  ProfileViewmodel(this._db);
}
