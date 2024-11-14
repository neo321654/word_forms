import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  String _fileContent = '';

  Future<void> _pickFile() async {
    try {
      String? path = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      ).then((result) => result?.files.first.path);

      if (path != null) {
        final file = File(path);
        final content = await file.readAsString();
        setState(() {
          _fileContent = content;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word forms'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(

            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('Выберите файл с текстом'),
                  ),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Выбрать исходный файл'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Выбрать файл с правилами'),
              ),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Создать файл с результатом'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(indent: 40,endIndent: 40,),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(child: Text(_fileContent)),
          )),
        ],
      ),
    );
  }
}
