class AuthTokensDto {
  const AuthTokensDto({required this.token, required this.refreshToken});

  final String token;
  final String refreshToken;

  factory AuthTokensDto.fromJson(Map<String, dynamic> json) => AuthTokensDto(
    token: json['token'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
