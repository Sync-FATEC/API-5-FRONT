enum MerchandiseGroup {
  expediente,
  limpeza,
  almoxVirtual,
  permanente,
}

MerchandiseGroup merchandiseGroupFromString(String value) {
  switch (value) {
    case 'expediente':
      return MerchandiseGroup.expediente;
    case 'limpeza':
      return MerchandiseGroup.limpeza;
    case 'Almox Virtual':
      return MerchandiseGroup.almoxVirtual;
    case 'permanente':
      return MerchandiseGroup.permanente;
    default:
      throw Exception('Invalid MerchandiseGroup: $value');
  }
}

String merchandiseGroupToString(MerchandiseGroup group) {
  switch (group) {
    case MerchandiseGroup.expediente:
      return 'expediente';
    case MerchandiseGroup.limpeza:
      return 'limpeza';
    case MerchandiseGroup.almoxVirtual:
      return 'Almox Virtual';
    case MerchandiseGroup.permanente:
      return 'permanente';
  }
}

// Helper para obter o display name dos grupos
String merchandiseGroupDisplayName(MerchandiseGroup group) {
  switch (group) {
    case MerchandiseGroup.expediente:
      return 'Expediente';
    case MerchandiseGroup.limpeza:
      return 'Limpeza';
    case MerchandiseGroup.almoxVirtual:
      return 'Almox Virtual';
    case MerchandiseGroup.permanente:
      return 'Permanente';
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
