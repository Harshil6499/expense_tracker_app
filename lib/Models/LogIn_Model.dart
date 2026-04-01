class LoginModel {
  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  ///Convert Data to Json
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
    };
  }
}
