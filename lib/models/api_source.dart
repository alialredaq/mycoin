enum ApiProvider {
  coingecko,
  binance,
  custom,
}

class ApiSource {
  final String id;
  final String name;
  final ApiProvider provider;
  final String baseUrl;
  final String? apiKey;
  final bool isActive;

  ApiSource({
    required this.id,
    required this.name,
    required this.provider,
    required this.baseUrl,
    this.apiKey,
    this.isActive = true,
  });

  factory ApiSource.fromJson(Map<String, dynamic> json) {
    return ApiSource(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      provider: ApiProvider.values.firstWhere((e) => e.name == json['provider'], orElse: () => ApiProvider.coingecko),
      baseUrl: json['base_url'] ?? '',
      apiKey: json['api_key'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider.name,
      'base_url': baseUrl,
      'api_key': apiKey,
      'is_active': isActive,
    };
  }
}