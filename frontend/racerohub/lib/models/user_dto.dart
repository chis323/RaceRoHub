class UserDto {
  final String name;
  final String password;

  const UserDto({required this.name, required this.password});

  Map<String, dynamic> toJson() => {
        'name': name,
        'password': password,
      };
}
