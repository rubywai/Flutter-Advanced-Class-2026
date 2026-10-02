class CustomerAddress {
  const CustomerAddress({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.state = '',
    this.postcode = '',
    this.country = '',
  });

  factory CustomerAddress.fromJson(Object? value) {
    final json = value is Map ? Map<String, dynamic>.from(value) : const {};
    String text(String key) => json[key]?.toString() ?? '';
    return CustomerAddress(
      firstName: text('first_name'),
      lastName: text('last_name'),
      email: text('email'),
      phone: text('phone'),
      address1: text('address_1'),
      address2: text('address_2'),
      city: text('city'),
      state: text('state'),
      postcode: text('postcode'),
      country: text('country'),
    );
  }

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;

  Map<String, String> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'address_1': address1,
    'address_2': address2,
    'city': city,
    'state': state,
    'postcode': postcode,
    'country': country,
  };

  Map<String, String> toShippingJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'address_1': address1,
    'address_2': address2,
    'city': city,
    'state': state,
    'postcode': postcode,
    'country': country,
  };
}

class Customer {
  const Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.billing,
    required this.shipping,
    this.avatarUrl,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: int.tryParse('${json['id']}') ?? 0,
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      billing: CustomerAddress.fromJson(json['billing']),
      shipping: CustomerAddress.fromJson(json['shipping']),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final CustomerAddress billing;
  final CustomerAddress shipping;
  final String? avatarUrl;

  Map<String, dynamic> toUpdateJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'billing': billing.toJson(),
    'shipping': shipping.toShippingJson(),
  };
}
