import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileService {
  static Future<String?> saveFile({
    required List<int> bytes,
    required String fileName,
    required String fileExtension,
  }) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Tentar múltiplas localizações em ordem de preferência

        // 1ª tentativa: Pasta Downloads pública
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (await directory.exists()) {
            print('FileService: Usando pasta Downloads: ${directory.path}');
          } else {
            directory = null;
          }
        } catch (e) {
          print('FileService: Erro ao acessar Downloads: $e');
          directory = null;
        }

        // 2ª tentativa: Pasta Documents pública
        if (directory == null) {
          try {
            directory = Directory('/storage/emulated/0/Documents');
            if (await directory.exists()) {
              print('FileService: Usando pasta Documents: ${directory.path}');
            } else {
              // Criar Documents se não existir
              await directory.create(recursive: true);
              print('FileService: Criada pasta Documents: ${directory.path}');
            }
          } catch (e) {
            print('FileService: Erro ao acessar Documents: $e');
            directory = null;
          }
        }

        // 3ª tentativa: Diretório da aplicação (fallback)
        if (directory == null) {
          try {
            directory = await getApplicationDocumentsDirectory();
            print(
              'FileService: Usando diretório da aplicação (fallback): ${directory.path}',
            );
          } catch (e) {
            print('FileService: Erro ao acessar diretório da aplicação: $e');
            directory = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // Para iOS, usar Documents
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Para outras plataformas, usar Downloads se disponível
        directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Não foi possível acessar o diretório de downloads');
      }

      final fullFileName = '$fileName.$fileExtension';
      final file = File('${directory.path}/$fullFileName');

      // Verificar se já existe e criar nome único se necessário
      String finalPath = file.path;
      int counter = 1;
      while (await File(finalPath).exists()) {
        final nameWithoutExt = fileName;
        finalPath =
            '${directory.path}/${nameWithoutExt}_$counter.$fileExtension';
        counter++;
      }

      // Salvar o arquivo
      final finalFile = File(finalPath);
      await finalFile.writeAsBytes(bytes);

      print('FileService: Arquivo salvo em: $finalPath');
      return finalPath;
    } catch (e) {
      print('FileService: Erro ao salvar arquivo: $e');
      throw Exception('Erro ao salvar arquivo: $e');
    }
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android moderno, não precisamos de permissão para diretório da app
      // Mas podemos verificar se temos acesso ao storage externo
      try {
        final permission = await Permission.storage.status;
        if (permission.isGranted) {
          return true;
        }

        // Se não tiver permissão, ainda podemos usar o diretório da app
        final appDir = await getApplicationDocumentsDirectory();
        return appDir.existsSync();
      } catch (e) {
        print('FileService: Erro ao verificar permissões: $e');
        return true; // Assumir que podemos usar diretório da app
      }
    }
    return true; // iOS não precisa de permissão explícita para Documents
  }

  static String getFileNameWithTimestamp(String baseName) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return '${baseName}_$timestamp';
  }
}
