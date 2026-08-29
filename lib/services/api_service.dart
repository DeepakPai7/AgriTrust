import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Abstract API boundary. Screens depend on this so tests can substitute a
/// fake implementation instead of hitting the network. The real
/// implementation ([HttpApiService]) talks to the Express backend.
abstract class ApiService {
  Future<AuthUser> login(String email, String password, {String role = 'farmer'});
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? location,
  });
  Future<List<Deal>> fetchDeals({int? farmerId, int? buyerId});
  Future<Deal> fetchDeal(int dealId);
  Future<Deal> createDeal({
    required int requestId,
    double? quantity,
    double? agreedPrice,
  });
  Future<List<Product>> fetchProducts({int? farmerId});
  Future<void> createProduct({
    required int farmerId,
    required String productName,
    required double quantity,
    required String unit,
    required double price,
    String? location,
    String? harvestDate,
    String? notes,
    String? photo,
  });
  Future<Calculation?> fetchCalculation(int dealId);
  Future<Settlement?> fetchSettlement(int dealId);
  Future<List<BuyerRequest>> fetchRequests({int? farmerId, int? buyerId});
  Future<void> updateRequestStatus(int requestId, String status);
  Future<BuyerRequest> createRequest({
    required int buyerId,
    required int productId,
    required double quantity,
    double? offeredPrice,
  });
  Future<List<MarketPrice>> fetchMarketPrices();
  Future<void> updateDealStatus(int dealId, String status);
  Future<void> createOrUpdateSettlement(
    int dealId, {
    required double deliveredQuantity,
    required double paymentAmount,
    String? status,
  });
  Future<FarmerProfile> fetchFarmerProfile(int id);
  Future<FarmerProfile> updateFarmerProfile(int id, FarmerProfile profile);
  Future<BuyerProfile> fetchBuyerProfile(int id);
  Future<BuyerProfile> updateBuyerProfile(int id, BuyerProfile profile);
}

/// Thin wrapper over [http.Client] pointing at the AgriTrust backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = defaultBaseUrl})
      : _client = client ?? http.Client();

  static const String defaultBaseUrl = 'http://172.20.10.2:3000/api';

  final http.Client _client;
  final String baseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _client.get(Uri.parse('$baseUrl$path'));
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? const {}),
    );
    return _decode(res);
  }

  Map<String, dynamic> _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    String message = 'Request failed (${res.statusCode})';
    try {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      final serverMessage = decoded['message'];
      if (serverMessage is String && serverMessage.isNotEmpty) {
        message = serverMessage;
      }
    } catch (_) {
      // Keep the generic message if the body is not JSON.
    }
    throw ApiException(message);
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Real [ApiService] backed by [ApiClient] hitting the Express server.
class HttpApiService implements ApiService {
  HttpApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  @override
  Future<AuthUser> login(String email, String password, {String role = 'farmer'}) async {
    final json = await _client.post('/auth/login', body: {
      'email': email,
      'password': password,
      'role': role,
    });
    return AuthUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? location,
  }) async {
    final json = await _client.post('/auth/signup', body: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'location': ?location,
    });
    return AuthUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  @override
  Future<List<Deal>> fetchDeals({int? farmerId, int? buyerId}) async {
    final query = <String>[];
    if (farmerId != null) query.add('farmer_id=$farmerId');
    if (buyerId != null) query.add('buyer_id=$buyerId');
    final suffix = query.isEmpty ? '' : '?${query.join('&')}';
    final json = await _client.get('/deals$suffix');
    final list = (json['deals'] as List? ?? const []);
    return list
        .map((e) => Deal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Deal> fetchDeal(int dealId) async {
    final json = await _client.get('/deals/$dealId');
    return Deal.fromJson(json['deal'] as Map<String, dynamic>);
  }

  @override
  Future<Deal> createDeal({
    required int requestId,
    double? quantity,
    double? agreedPrice,
  }) async {
    final json = await _client.post('/deals', body: {
      'request_id': requestId,
      'quantity': ?quantity,
      'agreed_price': ?agreedPrice,
    });
    return Deal.fromJson(json['deal'] as Map<String, dynamic>);
  }

  @override
  Future<List<Product>> fetchProducts({int? farmerId}) async {
    final path = farmerId == null ? '/products' : '/products?farmer_id=$farmerId';
    final json = await _client.get(path);
    final list = (json['products'] as List? ?? const []);
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createProduct({
    required int farmerId,
    required String productName,
    required double quantity,
    required String unit,
    required double price,
    String? location,
    String? harvestDate,
    String? notes,
    String? photo,
  }) async {
    await _client.post('/products', body: {
      'farmer_id': farmerId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'location': ?location,
      'created_at': ?harvestDate,
      'notes': ?notes,
      'photo': ?photo,
    });
  }

  @override
  Future<Calculation?> fetchCalculation(int dealId) async {
    try {
      final json = await _client.get('/deals/$dealId/calculation');
      final calc = json['calculation'];
      if (calc == null) return null;
      return Calculation.fromJson(calc as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  @override
  Future<Settlement?> fetchSettlement(int dealId) async {
    try {
      final json = await _client.get('/deals/$dealId/settlement');
      final settlement = json['settlement'];
      if (settlement == null) return null;
      return Settlement.fromJson(settlement as Map<String, dynamic>);
    } on ApiException {
      return null;
    }
  }

  @override
  Future<List<BuyerRequest>> fetchRequests({int? farmerId, int? buyerId}) async {
    final query = <String>[];
    if (farmerId != null) query.add('farmer_id=$farmerId');
    if (buyerId != null) query.add('buyer_id=$buyerId');
    final suffix = query.isEmpty ? '' : '?${query.join('&')}';
    final json = await _client.get('/requests$suffix');
    final list = (json['requests'] as List? ?? const []);
    return list
        .map((e) => BuyerRequest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateRequestStatus(int requestId, String status) async {
    await _client.put('/requests/$requestId', body: {'status': status});
  }

  @override
  Future<BuyerRequest> createRequest({
    required int buyerId,
    required int productId,
    required double quantity,
    double? offeredPrice,
  }) async {
    final json = await _client.post('/requests', body: {
      'buyer_id': buyerId,
      'product_id': productId,
      'quantity': quantity,
      'offered_price': ?offeredPrice,
    });
    return BuyerRequest.fromJson(
      json['request'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<MarketPrice>> fetchMarketPrices() async {
    final json = await _client.get('/market-prices');
    final list = (json['market_prices'] as List? ?? const []);
    return list
        .map((e) => MarketPrice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateDealStatus(int dealId, String status) async {
    await _client.put('/deals/$dealId', body: {'status': status});
  }

  @override
  Future<void> createOrUpdateSettlement(
    int dealId, {
    required double deliveredQuantity,
    required double paymentAmount,
    String? status,
  }) async {
    await _client.put('/deals/$dealId/settlement', body: {
      'delivered_quantity': deliveredQuantity,
      'payment_amount': paymentAmount,
      'status': ?status,
    });
  }

  @override
  Future<FarmerProfile> fetchFarmerProfile(int id) async {
    final json = await _client.get('/farmers/$id');
    return FarmerProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  @override
  Future<FarmerProfile> updateFarmerProfile(int id, FarmerProfile profile) async {
    final json = await _client.put('/farmers/$id', body: profile.toJson());
    return FarmerProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  @override
  Future<BuyerProfile> fetchBuyerProfile(int id) async {
    final json = await _client.get('/buyers/$id');
    return BuyerProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }

  @override
  Future<BuyerProfile> updateBuyerProfile(int id, BuyerProfile profile) async {
    final json = await _client.put('/buyers/$id', body: profile.toJson());
    return BuyerProfile.fromJson(json['profile'] as Map<String, dynamic>);
  }
}
