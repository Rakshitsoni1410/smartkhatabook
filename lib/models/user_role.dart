enum UserRole {
  owner,
  wholesaler,
  retailer,
  customer,
}

UserRole parseUserRole(dynamic value) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';

  switch (normalized) {
    case 'owner':
      return UserRole.owner;
    case 'wholesaler':
      return UserRole.wholesaler;
    case 'retailer':
      return UserRole.retailer;
    case 'customer':
      return UserRole.customer;
    default:
      throw Exception('Invalid user role: $value');
  }
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.wholesaler:
        return 'Wholesaler';
      case UserRole.retailer:
        return 'Retailer';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get dashboardTitle {
    switch (this) {
      case UserRole.owner:
        return 'Owner Dashboard';
      case UserRole.wholesaler:
        return 'Wholesaler Dashboard';
      case UserRole.retailer:
        return 'Retailer Dashboard';
      case UserRole.customer:
        return 'Customer Dashboard';
    }
  }
}