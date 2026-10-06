class RegisterRequestDto {
  final String email;
  final String password;
  final String fullName;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
      };
}
