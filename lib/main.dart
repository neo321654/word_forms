import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Merger',
      home: FileMergerScreen(),
    );
  }
}

class FileMergerScreen extends StatelessWidget {
  final TextEditingController _file1Controller = TextEditingController();
  final TextEditingController _file2Controller = TextEditingController();

  Future<void> _openFile1() async {
    // Логика для открытия первого файла (например, через диалог выбора файла)
    String? path = await _selectFile();
    if (path != null) {
      _file1Controller.text = path;
    }
  }

  Future<void> _openFile2() async {
    // Логика для открытия второго файла
    String? path = await _selectFile();
    if (path != null) {
      _file2Controller.text = path;
    }
  }

  Future<void> _createMergedFile() async {
    String file1Path = _file1Controller.text;
    String file2Path = _file2Controller.text;

    if (file1Path.isEmpty || file2Path.isEmpty) {
      print("Выберите оба файла перед объединением.");
      return;
    }

    try {
      String content1 = await File(file1Path).readAsString();
      String content2 = await File(file2Path).readAsString();

      String mergedContent = content1 + '\n' + content2;

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String mergedFilePath = '${appDocDir.path}/merged_file.txt';
      await File(mergedFilePath).writeAsString(mergedContent);

      print('Файл успешно создан: $mergedFilePath');
    } catch (e) {
      print('Ошибка при создании файла: $e');
    }
  }

  Future<String?> _selectFile() async {
    // Здесь должна быть логика выбора файла (например, через диалоговое окно)
    // Для упрощения примера вернем фиксированный путь
    return '/path/to/your/file.txt'; // Замените на реальный путь к файлу
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Объединение файлов')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _file1Controller,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Файл 1'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openFile1,
              child: Text('Открыть файл 1'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _file2Controller,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Файл 2'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openFile2,
              child: Text('Открыть файл 2'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createMergedFile,
              child: Text('Создать объединенный файл'),
            ),
          ],
        ),
      ),
    );
  }
}