class SignUp {
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String password;
  final String confirm_password;
  final String DOB;
  //final String profile_image;

  SignUp({

    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirm_password,
    required this.DOB,
    //required this.profile_image,

  });

  ///Convert Data to Json
  Map<String, dynamic> toJson() {
    return{
      "name": name,
      "surname": surname,
      "email": email,
      "phone": phone,
      "password": password,
      "confirm_password": confirm_password,
      "DOB": DOB,
      //"profile_image": profile_image,
    };
  }
}
