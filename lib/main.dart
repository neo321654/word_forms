import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'logic.dart';

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

  Future<void> _pickInputFile() async {
    try {
      String path = await _getPath();
      final file = File(path);
      final content = await file.readAsString();
      setState(() {
        _path_input = path;
        _fileContent = 'Входящие данные для обработки.\n \n \n $content';
      });
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickRulesFile() async {
    try {
      String path = await _getPath();
      final file = File(path);
      final content = await file.readAsString();
      setState(() {
        _path_rules = path;
        _fileContent = 'Правила для обработки.\n \n \n $content';
      });
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  String _getShortFileName(String path) {
    if (path.length < 26) return path;
    return '...${path.substring(
      path.length - 26,
    )}';
  }

  Future<String> _getPath() async {
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

  void _onResult(String result){
    setState(() {
      _fileContent = result;
    });
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
                    child: Text(_getShortFileName(_path_input)),
                  ),
                  ElevatedButton(
                    onPressed: _pickInputFile,
                    child: const Text('Выбрать исходный файл'),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(_getShortFileName(_path_rules)),
                  ),
                  ElevatedButton(
                    onPressed: _pickRulesFile,
                    child: const Text('Выбрать файл с правилами'),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(_getShortFileName(_path_input)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      mainLogic(inputPath: _path_input, rulePath: _path_rules,onResult: _onResult);
                    },
                    child: const Text('Создать файл с результатом'),
                  ),
                ],
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
