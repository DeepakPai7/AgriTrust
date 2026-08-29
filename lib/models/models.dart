// Models decoupling screen widgets from the raw JSON returned by the
// AgriTrust backend. Each maps 1:1 to a row returned by the API routes.

/// A deal row from GET /api/deals and /api/deals/:id.
class Deal {
  const Deal({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.productId,
    required this.quantity,
    required this.agreedPrice,
    required this.status,
    required this.buyerName,
    required this.farmerName,
    required this.productName,
    required this.unit,
    this.location,
    this.createdAt,
  });

  final int id;
  final int buyerId;
  final int farmerId;
  final int productId;
  final double quantity;
  final double agreedPrice;
  final String status;
  final String buyerName;
  final String farmerName;
  final String productName;
  final String unit;
  final String? location;
  final String? createdAt;

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: (json['id'] as num).toInt(),
      buyerId: (json['buyer_id'] as num?)?.toInt() ?? 0,
      farmerId: (json['farmer_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      agreedPrice: (json['agreed_price'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      buyerName: json['buyer_name'] as String? ?? 'Buyer',
      farmerName: json['farmer_name'] as String? ?? 'Farmer',
      productName: json['product_name'] as String? ?? 'Product',
      unit: json['unit'] as String? ?? '',
      location: json['location'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

/// Calculation row from GET /api/deals/:id/calculation.
class Calculation {
  const Calculation({
    required this.dealId,
    required this.grossAmount,
    required this.deductions,
    required this.netAmount,
    required this.effectivePrice,
  });

  final int dealId;
  final double grossAmount;
  final double deductions;
  final double netAmount;
  final double effectivePrice;

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      dealId: (json['deal_id'] as num?)?.toInt() ?? 0,
      grossAmount: (json['gross_amount'] as num?)?.toDouble() ?? 0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0,
      effectivePrice: (json['effective_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Settlement row from GET /api/deals/:id/settlement.
class Settlement {
  const Settlement({
    required this.dealId,
    required this.deliveredQuantity,
    required this.paymentAmount,
    required this.difference,
    required this.status,
  });

  final int dealId;
  final double deliveredQuantity;
  final double paymentAmount;
  final double difference;
  final String status;

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      dealId: (json['deal_id'] as num?)?.toInt() ?? 0,
      deliveredQuantity: (json['delivered_quantity'] as num?)?.toDouble() ?? 0,
      paymentAmount: (json['payment_amount'] as num?)?.toDouble() ?? 0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

/// Buyer request row from GET /api/requests.
class BuyerRequest {
  const BuyerRequest({
    required this.id,
    required this.quantity,
    required this.offeredPrice,
    required this.status,
    required this.buyerName,
    required this.productName,
    required this.productPrice,
    required this.unit,
    this.location,
    this.createdAt,
    this.farmerId,
    this.buyerId,
  });

  final int id;
  final double quantity;
  final double offeredPrice;
  final String status;
  final String buyerName;
  final String productName;
  final double productPrice;
  final String unit;
  final String? location;
  final String? createdAt;
  final int? farmerId;
  final int? buyerId;

  factory BuyerRequest.fromJson(Map<String, dynamic> json) {
    return BuyerRequest(
      id: (json['id'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      offeredPrice: (json['offered_price'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      buyerName: json['buyer_name'] as String? ?? 'Buyer',
      productName: json['product_name'] as String? ?? 'Product',
      productPrice: (json['product_price'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      location: json['location'] as String?,
      createdAt: json['created_at'] as String?,
      farmerId: (json['farmer_id'] as num?)?.toInt(),
      buyerId: (json['buyer_id'] as num?)?.toInt(),
    );
  }
}

/// Daily mandi market price row from GET /api/market-prices.
class MarketPrice {
  const MarketPrice({
    required this.commodity,
    required this.modalPrice,
    this.state,
    this.marketName,
    this.district,
    this.variety,
    this.grade,
    this.arrivalDate,
    this.minPrice,
    this.maxPrice,
  });

  final String commodity;
  final double modalPrice;
  final String? state;
  final String? marketName;
  final String? district;
  final String? variety;
  final String? grade;
  final String? arrivalDate;
  final double? minPrice;
  final double? maxPrice;

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      commodity: json['product_name'] as String? ?? 'Commodity',
      modalPrice: (json['modal_price'] as num?)?.toDouble() ?? 0,
      state: json['state'] as String?,
      marketName: json['market_name'] as String?,
      district: json['district'] as String?,
      variety: json['variety'] as String?,
      grade: json['grade'] as String?,
      arrivalDate: json['arrival_date'] as String?,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
    );
  }
}

/// Authenticated user returned by POST /api/auth/login and /api/auth/signup.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.location,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? location;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'farmer',
      location: json['location'] as String?,
    );
  }
}

/// A product listing created by a farmer.
class Product {
  const Product({
    required this.id,
    required this.farmerId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    this.location,
    this.notes,
    this.photo,
    this.createdAt,
    this.farmerName,
  });

  final int id;
  final int farmerId;
  final String productName;
  final double quantity;
  final String unit;
  final double price;
  final String? location;
  final String? notes;
  final String? photo;
  final String? createdAt;
  final String? farmerName;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      farmerId: (json['farmer_id'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? 'Product',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      photo: json['photo'] as String?,
      createdAt: json['created_at'] as String?,
      farmerName: json['farmer_name'] as String?,
    );
  }
}

/// Farmer profile row from GET/PUT /api/farmers/:id.
class FarmerProfile {
  const FarmerProfile({
    required this.id,
    this.name = '',
    this.email = '',
    this.location,
    this.phone,
    this.language,
    this.address,
    this.landArea,
    this.landUnit,
    this.soilType,
    this.crops = const [],
    this.irrigation,
    this.latitude,
    this.longitude,
    this.bankAccount,
    this.ifsc,
    this.settlementMethod,
  });

  final int id;
  final String name;
  final String email;
  final String? location;
  final String? phone;
  final String? language;
  final String? address;
  final String? landArea;
  final String? landUnit;
  final String? soilType;
  final List<String> crops;
  final String? irrigation;
  final String? latitude;
  final String? longitude;
  final String? bankAccount;
  final String? ifsc;
  final String? settlementMethod;

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    final cropsRaw = json['crops'] as String? ?? '';
    return FarmerProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      language: json['language'] as String?,
      address: json['address'] as String?,
      landArea: json['land_area'] as String?,
      landUnit: json['land_unit'] as String?,
      soilType: json['soil_type'] as String?,
      crops: cropsRaw
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList(),
      irrigation: json['irrigation'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      bankAccount: json['bank_account'] as String?,
      ifsc: json['ifsc'] as String?,
      settlementMethod: json['settlement_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'phone': phone,
      'language': language,
      'address': address,
      'land_area': landArea,
      'land_unit': landUnit,
      'soil_type': soilType,
      'crops': crops.join(', '),
      'irrigation': irrigation,
      'latitude': latitude,
      'longitude': longitude,
      'bank_account': bankAccount,
      'ifsc': ifsc,
      'settlement_method': settlementMethod,
    };
  }
}

/// Buyer profile row from GET/PUT /api/buyers/:id.
class BuyerProfile {
  const BuyerProfile({
    required this.id,
    this.name = '',
    this.email = '',
    this.location,
    this.companyName,
    this.gstPan,
    this.companyAddress,
    this.cropsInterested = const [],
    this.preferredLocations,
    this.contactPhone,
    this.paymentMethod,
    this.bankAccount,
    this.ifsc,
  });

  final int id;
  final String name;
  final String email;
  final String? location;
  final String? companyName;
  final String? gstPan;
  final String? companyAddress;
  final List<String> cropsInterested;
  final String? preferredLocations;
  final String? contactPhone;
  final String? paymentMethod;
  final String? bankAccount;
  final String? ifsc;

  factory BuyerProfile.fromJson(Map<String, dynamic> json) {
    final cropsRaw = json['crops_interested'] as String? ?? '';
    return BuyerProfile(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String?,
      companyName: json['company_name'] as String?,
      gstPan: json['gst_pan'] as String?,
      companyAddress: json['company_address'] as String?,
      cropsInterested: cropsRaw
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList(),
      preferredLocations: json['preferred_locations'] as String?,
      contactPhone: json['contact_phone'] as String?,
      paymentMethod: json['payment_method'] as String?,
      bankAccount: json['bank_account'] as String?,
      ifsc: json['ifsc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'company_name': companyName,
      'gst_pan': gstPan,
      'company_address': companyAddress,
      'crops_interested': cropsInterested.join(','),
      'preferred_locations': preferredLocations,
      'contact_phone': contactPhone,
      'payment_method': paymentMethod,
      'bank_account': bankAccount,
      'ifsc': ifsc,
    };
  }
}
