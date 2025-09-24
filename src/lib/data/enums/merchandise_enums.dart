enum MerchandiseGroup {
  groupA,
  groupB,
  groupC,
}

MerchandiseGroup merchandiseGroupFromString(String value) {
  switch (value) {
    case 'groupA':
      return MerchandiseGroup.groupA;
    case 'groupB':
      return MerchandiseGroup.groupB;
    case 'groupC':
      return MerchandiseGroup.groupC;
    default:
      throw Exception('Invalid MerchandiseGroup: $value');
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
