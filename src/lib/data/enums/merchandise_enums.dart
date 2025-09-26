enum MerchandiseGroup {
  medical,
  almox,
}

MerchandiseGroup merchandiseGroupFromString(String value) {
  switch (value) {
    case 'Medical':
    case 'medical':
    case 'MEDICAL':
      return MerchandiseGroup.medical;
    case 'Almox':
    case 'almox':
    case 'ALMOX':
      return MerchandiseGroup.almox;
    default:
      throw Exception('Invalid MerchandiseGroup: $value');
  }
}

String merchandiseGroupToString(MerchandiseGroup group) {
  switch (group) {
    case MerchandiseGroup.medical:
      return 'Medical';
    case MerchandiseGroup.almox:
      return 'Almox';
  }
}

enum MerchandiseStatus {
  available,
  unavailable,
  reserved,
}

MerchandiseStatus merchandiseStatusFromString(String value) {
  switch (value) {
    case 'available':
      return MerchandiseStatus.available;
    case 'unavailable':
      return MerchandiseStatus.unavailable;
    case 'reserved':
      return MerchandiseStatus.reserved;
    default:
      throw Exception('Invalid MerchandiseStatus: $value');
  }
}
