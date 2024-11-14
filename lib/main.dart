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
  String _path_input = '';
  String _path_rules = '';
  String _path_final_result = '';

  Future<void> _pickFile() async {


    try {

      String path = await _getPath();
        final file = File(path);
        final content = await file.readAsString();
        setState(() {
          _path_input = '...${path.substring(path.length-26,)}';
          _fileContent = content;
        });

    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<String> _getPath()async{
    try {
      String? path = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      ).then((result) => result?.files.first.path);

      if (path != null) {
      return path;
      }
    } catch (e) {
      print('Error picking file: $e');
    }
    return 'empty';

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
          const Divider(
            indent: 40,
            endIndent: 40,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.spaceBetween,
            spacing: 20,
            children: [
              Column(
                children: [
                   Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(_path_input),
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
          const Divider(
            indent: 40,
            endIndent: 40,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(child: Text(_fileContent)),
          )),
        ],
      ),
    );
  }
}
