class LoginModel {
  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  ///Convert Object to Json POST
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}
