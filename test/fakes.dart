import 'package:agritrust/models/models.dart';
import 'package:agritrust/services/api_service.dart';

/// Returns demo data matching the strings the widget tests assert on, without
/// hitting the network. Stands in for [HttpApiService] during tests.
class FakeApiService implements ApiService {
  List<Deal> deals;
  List<BuyerRequest> requests;
  List<Product> products;
  List<MarketPrice> marketPrices;

  FarmerProfile farmerProfile = _defaultFarmerProfile();
  BuyerProfile buyerProfile = _defaultBuyerProfile();

  final List<String> updatedRequestStatuses = [];

  final List<Map<String, dynamic>> createdProducts = [];

  final List<int> createdDealRequestIds = [];

  int _nextRequestId = 1000;
  int _nextDealId = 9000;

  final String validEmail;
  final String validPassword;
  final String role;

  FakeApiService({
    List<Deal>? deals,
    List<BuyerRequest>? requests,
    List<Product>? products,
    List<MarketPrice>? marketPrices,
    this.validEmail = 'ravi@gmail.com',
    this.validPassword = '123456',
    this.role = 'farmer',
  })  : deals = deals ?? _defaultDeals(),
        requests = requests ?? _defaultRequests(),
        products = products ?? List.of(_defaultProducts()),
        marketPrices = marketPrices ?? _defaultPrices();

  @override
  Future<AuthUser> login(String email, String password,
      {String role = 'farmer'}) async {
    if (email.trim() == validEmail &&
        password == validPassword &&
        role == this.role) {
      return AuthUser(
        id: 1,
        name: role == 'buyer' ? 'Arjun Kumar' : 'Ravi Kumar',
        email: validEmail,
        role: role,
        location: 'Mysore',
      );
    }
    throw ApiException('Invalid email or password');
  }

  @override
  Future<AuthUser> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    String? location,
  }) async {
    return AuthUser(
      id: 100,
      name: name,
      email: email,
      role: role,
      location: location,
    );
  }

  static Deal _deal({
    required int id,
    required String product,
    required String buyer,
    required String farmer,
    double quantity = 50,
    double price = 2400,
    String unit = 'Qtl',
    String status = 'confirmed',
  }) {
    return Deal(
      id: id,
      buyerId: 2,
      farmerId: 1,
      productId: id,
      quantity: quantity,
      agreedPrice: price,
      status: status,
      buyerName: buyer,
      farmerName: farmer,
      productName: product,
      unit: unit,
      location: 'Mysore',
      createdAt: '2023-12-10T00:00:00',
    );
  }

  static List<Deal> _defaultDeals() => [
        _deal(
          id: 8492,
          product: 'Premium Wheat',
          buyer: 'AgriCorp India',
          farmer: 'Ramesh Gowda',
          price: 2400,
        ),
        _deal(
          id: 8104,
          product: 'Organic Soybeans',
          buyer: 'Green Valley Mills',
          farmer: 'Ramesh Gowda',
          price: 4800,
          quantity: 20,
        ),
        _deal(
          id: 8555,
          product: 'Sorghum (Jowar)',
          buyer: 'National Grain Co.',
          farmer: 'Ramesh Gowda',
          price: 2100,
          quantity: 100,
        ),
      ];

  static FarmerProfile _defaultFarmerProfile() => const FarmerProfile(
        id: 1,
        name: 'Ravi Kumar',
        email: 'ravi@gmail.com',
        location: 'Mysore',
        phone: '9876543210',
        language: 'English',
        address: '123, Green Meadows Farm, Near River Bend, Karnataka 570001',
        landArea: '15',
        landUnit: 'acres',
        soilType: 'Black Cotton Soil',
        crops: ['Paddy', 'Sugarcane', 'Maize'],
        irrigation: 'Borewell',
        bankAccount: '123456789',
        ifsc: 'SBIN0001234',
        settlementMethod: 'bank',
      );

  static BuyerProfile _defaultBuyerProfile() => const BuyerProfile(
        id: 1,
        name: 'Arjun Kumar',
        email: 'arjun@gmail.com',
        location: 'Bengaluru',
        companyName: 'GreenEarth Organics',
        gstPan: '29AAACG1234H1Z5',
        companyAddress: '142, APMC Yard, Yeshwanthpur, Bengaluru, Karnataka 560022',
        cropsInterested: ['Paddy', 'Maize', 'Wheat'],
        preferredLocations: 'Karnataka, Maharashtra',
        contactPhone: '9876543210',
        paymentMethod: 'bank_transfer',
        bankAccount: '30485769213',
        ifsc: 'SBIN0001234',
      );

  static List<BuyerRequest> _defaultRequests() => [
        BuyerRequest(
          id: 1,
          quantity: 50,
          offeredPrice: 2200,
          status: 'pending',
          buyerName: 'AgriCorp India',
          productName: 'Premium Wheat',
          productPrice: 2400,
          unit: 'Qtl',
          location: 'Mysore',
          createdAt: '2023-10-24T00:00:00',
          farmerId: 1,
          buyerId: 1,
        ),
        BuyerRequest(
          id: 2,
          quantity: 200,
          offeredPrice: 3150,
          status: 'pending',
          buyerName: 'Green Valley Mills',
          productName: 'Organic Rice',
          productPrice: 3300,
          unit: 'Qtl',
          location: 'Mysore',
          createdAt: '2023-10-23T00:00:00',
          farmerId: 1,
          buyerId: 1,
        ),
        BuyerRequest(
          id: 3,
          quantity: 120,
          offeredPrice: 4800,
          status: 'pending',
          buyerName: 'Sunfresh Produce',
          productName: 'Soybeans',
          productPrice: 5000,
          unit: 'Qtl',
          location: 'Mysore',
          createdAt: '2023-10-22T00:00:00',
          farmerId: 1,
          buyerId: 1,
        ),
        BuyerRequest(
          id: 4,
          quantity: 80,
          offeredPrice: 3500,
          status: 'pending',
          buyerName: 'Harvest Foods',
          productName: 'Jowar',
          productPrice: 3600,
          unit: 'Qtl',
          location: 'Hubli',
          createdAt: '2023-10-21T00:00:00',
          farmerId: 2,
          buyerId: 2,
        ),
      ];

  static List<Product> _defaultProducts() => const [
        Product(
          id: 101,
          farmerId: 1,
          productName: 'Premium Wheat',
          quantity: 500,
          unit: 'Qtl',
          price: 2400,
          location: 'Mysore',
          farmerName: 'Ravi Kumar',
          createdAt: '2023-10-20T00:00:00',
        ),
        Product(
          id: 102,
          farmerId: 1,
          productName: 'Organic Rice',
          quantity: 300,
          unit: 'Qtl',
          price: 3300,
          location: 'Mysore',
          farmerName: 'Ravi Kumar',
          createdAt: '2023-10-21T00:00:00',
        ),
        Product(
          id: 103,
          farmerId: 2,
          productName: 'Jowar',
          quantity: 200,
          unit: 'Qtl',
          price: 3600,
          location: 'Hubli',
          farmerName: 'Sharma Farmer',
          createdAt: '2023-10-22T00:00:00',
        ),
      ];

  static List<MarketPrice> _defaultPrices() => const [
        MarketPrice(
          commodity: 'Tomato',
          modalPrice: 2900,
          state: 'Karnataka',
          marketName: 'Bangalore APMC',
          arrivalDate: '29/08/2026',
        ),
        MarketPrice(
          commodity: 'Onion',
          modalPrice: 1850,
          state: 'Karnataka',
          marketName: 'Hubli Market',
          arrivalDate: '29/08/2026',
        ),
        MarketPrice(
          commodity: 'Wheat',
          modalPrice: 2400,
          state: 'Karnataka',
          marketName: 'Mysore Mandi',
          arrivalDate: '29/08/2026',
        ),
      ];

  @override
  Future<List<Deal>> fetchDeals({int? farmerId, int? buyerId}) async {
    Iterable<Deal> result = deals;
    if (farmerId != null) result = result.where((d) => d.farmerId == farmerId);
    if (buyerId != null) result = result.where((d) => d.buyerId == buyerId);
    return result.toList();
  }

  @override
  Future<Deal> fetchDeal(int dealId) async =>
      deals.firstWhere((d) => d.id == dealId);

  @override
  Future<List<Product>> fetchProducts({int? farmerId}) async {
    if (farmerId == null) return List.of(products);
    return products.where((p) => p.farmerId == farmerId).toList();
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
    createdProducts.add({
      'farmer_id': farmerId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'location': location,
      'created_at': harvestDate,
      'notes': notes,
      'photo': photo,
    });
  }

  @override
  Future<Calculation?> fetchCalculation(int dealId) async {
    final deal = deals.firstWhere((d) => d.id == dealId);
    final gross = deal.agreedPrice * deal.quantity;
    return Calculation(
      dealId: dealId,
      grossAmount: gross,
      deductions: 0,
      netAmount: gross,
      effectivePrice: deal.agreedPrice,
    );
  }

  @override
  Future<Settlement?> fetchSettlement(int dealId) async => null;

  @override
  Future<List<BuyerRequest>> fetchRequests({int? farmerId, int? buyerId}) async {
    Iterable<BuyerRequest> result = requests;
    if (farmerId != null) result = result.where((r) => r.farmerId == farmerId);
    if (buyerId != null) result = result.where((r) => r.buyerId == buyerId);
    return result.toList();
  }

  @override
  Future<BuyerRequest> createRequest({
    required int buyerId,
    required int productId,
    required double quantity,
    double? offeredPrice,
  }) async {
    final product = products.firstWhere((p) => p.id == productId);
    final id = _nextRequestId++;
    final request = BuyerRequest(
      id: id,
      quantity: quantity,
      offeredPrice: offeredPrice ?? product.price,
      status: 'pending',
      buyerName: 'Arjun Kumar',
      productName: product.productName,
      productPrice: product.price,
      unit: product.unit,
      location: product.location,
      createdAt: DateTime.now().toIso8601String(),
      farmerId: product.farmerId,
      buyerId: buyerId,
    );
    requests.add(request);
    return request;
  }

  @override
  Future<void> updateRequestStatus(int requestId, String status) async {
    updatedRequestStatuses.add('$requestId:$status');
    final i = requests.indexWhere((r) => r.id == requestId);
    if (i >= 0) {
      requests[i] = BuyerRequest(
        id: requests[i].id,
        quantity: requests[i].quantity,
        offeredPrice: requests[i].offeredPrice,
        status: status,
        buyerName: requests[i].buyerName,
        productName: requests[i].productName,
        productPrice: requests[i].productPrice,
        unit: requests[i].unit,
        location: requests[i].location,
        createdAt: requests[i].createdAt,
      );
    }
  }

  @override
  Future<Deal> createDeal({
    required int requestId,
    double? quantity,
    double? agreedPrice,
  }) async {
    createdDealRequestIds.add(requestId);
    final request = requests.firstWhere((r) => r.id == requestId);
    final product = products
        .firstWhere((p) => p.productName == request.productName, orElse: () => products.first);
    final deal = Deal(
      id: _nextDealId++,
      buyerId: request.buyerId ?? 0,
      farmerId: request.farmerId ?? 0,
      productId: product.id,
      quantity: quantity ?? request.quantity,
      agreedPrice: agreedPrice ?? request.offeredPrice,
      status: 'confirmed',
      buyerName: request.buyerName,
      farmerName: 'Ravi Kumar',
      productName: request.productName,
      unit: request.unit,
      location: request.location,
      createdAt: '2023-10-25T00:00:00',
    );
    deals = [...deals, deal];
    return deal;
  }

  @override
  Future<List<MarketPrice>> fetchMarketPrices() async => List.of(marketPrices);

  @override
  Future<void> updateDealStatus(int dealId, String status) async {
    final i = deals.indexWhere((d) => d.id == dealId);
    if (i < 0) return;
    final d = deals[i];
    deals[i] = Deal(
      id: d.id,
      buyerId: d.buyerId,
      farmerId: d.farmerId,
      productId: d.productId,
      quantity: d.quantity,
      agreedPrice: d.agreedPrice,
      status: status,
      buyerName: d.buyerName,
      farmerName: d.farmerName,
      productName: d.productName,
      unit: d.unit,
      location: d.location,
      createdAt: d.createdAt,
    );
  }

  @override
  Future<void> createOrUpdateSettlement(
    int dealId, {
    required double deliveredQuantity,
    required double paymentAmount,
    String? status,
  }) async {}

  @override
  Future<FarmerProfile> fetchFarmerProfile(int id) async => farmerProfile;

  @override
  Future<FarmerProfile> updateFarmerProfile(
      int id, FarmerProfile profile) async {
    farmerProfile = profile;
    return profile;
  }

  @override
  Future<BuyerProfile> fetchBuyerProfile(int id) async => buyerProfile;

  @override
  Future<BuyerProfile> updateBuyerProfile(int id, BuyerProfile profile) async {
    buyerProfile = profile;
    return profile;
  }
}
