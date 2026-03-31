class Driver {
  final long? driverID;
  final String name;
  final String phoneNumber;
  final String email;
  final String password;

  Driver({
    this.driverID,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'driverID': driverID,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  // Crear instancia desde JSON
  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      driverID: json['driverID'],
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  // Copiar con cambios
  Driver copyWith({
    long? driverID,
    String? name,
    String? phoneNumber,
    String? email,
    String? password,
  }) {
    return Driver(
      driverID: driverID ?? this.driverID,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
