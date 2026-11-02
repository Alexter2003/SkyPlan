import '../../domain/entities/account_profile.dart';
import 'auth_user_model.dart';

class AccountProfileModel extends AccountProfile {
  const AccountProfileModel({
    required super.user,
    required super.mustChangePassword,
  });

  factory AccountProfileModel.fromJson(Map<String, dynamic> json) {
    return AccountProfileModel(
      user: AuthUserModel.fromJson(json),
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }
}
