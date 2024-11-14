import 'dart:io';

// void main() async {
void mainLogic({required String inputPath, required rulePath,}) async {

  final rulesList = await getAllRulesFromFile(rulePath);
  final inputData = inputPath;
  final allInputs = File(inputData).readAsLinesSync();

  String input = allInputs[2];

  final List<Map<String, String>> firstListRules = rulesList[0]['data'];

  final listToEdit = getInputList(input);

  // print(listToEdit);
  // print(firstListRules);

  ///добавляю приставки
  List<String> listPrefixes =
      getRuleByNumber(key: '1', listRules: firstListRules)?.split(',') ?? [];
  List<List<String>> listWithPrefixes = [];

  listPrefixes.forEach((prefix) {
    prefix = prefix.toUpperCase().trim();

    listWithPrefixes.add(addPrefix(listToEdit, prefix));
  });

  ///добавляю окончания
  List<String> listEndings =
      getRuleByNumber(key: '2', listRules: firstListRules)?.split(',') ?? [];
  List<List<String>> listWithEndings = [];

  listEndings.forEach((endings) {
    endings = endings.toUpperCase().trim();

    listWithEndings.add(addEndings(listToEdit, endings));
  });

  ///проверяю есть ли метки если нет добавляю в список
  List<String> listMarksAdd =
      getRuleByNumber(key: '3', listRules: firstListRules)?.split(',') ?? [];
  List<String> listWithAddedMarks = [];

  listMarksAdd.forEach((markToAdd) {
    ///создаётся список без повторений, но нужно протестировать получше
    listWithAddedMarks.addAll(addMarksToList(listToEdit, markToAdd));
  });

  ///проверяю есть ли метки если есть удаляю  их из списка
  List<String> listMarksDelete =
      getRuleByNumber(key: '4', listRules: firstListRules)?.split(',') ?? [];
  List<String> listWithDeletedMarks = [];

  listWithDeletedMarks.addAll(deleteMarksFromList(listToEdit, listMarksDelete));

  ///пункт 6 ударение, проверяю текущее ударение, оно на ок/осн
  ///если если оно на ок и проверка на ок , тогда ничего не меняю
  ///если нет удаляю старое ударение, нахожу последнюю гласную,
  ///проверяю слева гласная или нет, ищу слева гласную и ставлю после него ударение,
  ///если наоборот то через одну гласную
  List<String> listEmphasis =
      getRuleByNumber(key: '6', listRules: firstListRules)?.split(',') ?? [];
  List<String> listWithEditedEmphasis = [];

  listWithEditedEmphasis.addAll(setEmphasis(listToEdit, listEmphasis));

  print('//// ${listToEdit}');
  print('//// ${listEmphasis}');
  print('//// ${listWithEditedEmphasis}');
}


List<String> setEmphasis(
    List<String> listToEdit, List<String> listMarksDelete) {
  List<String> resultList = listToEdit.map((graf) {
    listMarksDelete.forEach((markToDelete) {
      if (markToDelete != '_' || markToDelete != ' ' || markToDelete != '') {
        if (graf.trim().contains(markToDelete.trim())) {
          // print('222  $graf');

          final List tempList = graf.split(' ');

          final editedList = [];
          // print('qqq$tempList');

          tempList.forEach((element) {
            if (!element.trim().contains(markToDelete.trim())) {
              editedList.add(element);
            }
          });

          // print('qqqqww$editedList');

          graf = editedList.join(' ');
        }
      }
    });

    return graf;
  }).toList();

  return resultList;
}

// =1= Номер операции (Записывается порядковый номер операции преобразования. Операции производятся программой последовательно).
// 1.Добавление приставки ... - буквы приставки, либо пустое поле, если приставка не добавляется.
// 2.Окончание исходного слова - последние буквы исходного слова в разделителях ¦ ¦, либо пустое поле, если окончание слова - любое.
// 3.Метки в строке со словом, которые должны быть - ..., ..., либо пустое поле, если возможны любые метки.
// 4.Метки в строке со словом, которых НЕ должно быть - ..., ..., либо пустое поле, если проверка не нужна.
// 5.Изменения в графе: (¦¦ / т-0,т0 / везде (в этом случае окончание для леммы отмечаются знаком ¦) ).
// 6.Ударение исходного слова (на основу/на окончание). На окончание означает, что на последнюю гласную в слове. Всё остальное - на основу.
// 7.Только для окончаний корня* на: ..., ..., - буквы или _ , если окончания корня могут быть любые.
// 8.Кроме окончаний корня на: ..., ..., - буквы или _ , если подобных ограничений нет.
// 9.Замена окончаний корня (например, г-ж, х-ш значит, что г в окончании корня заменяется на ж, х - на ш. Знак _ означает отсутсвие подобных операций).
// 10.Замена меток строки после преобразования (запись сщ-гл, ед-_, _-с р означает, что метка "сщ" в исходной строке после преобразованя меняется на метку "гл", метка "ед" после преобразования удаляется из строки (вместе с замыкающим пробелом, чтобы формат записи меток не нарушался), а метка с р добавляется (в любую графу с метками).
// 11.Перечень усечений и надставлений для каждой словоформы (усечение и надставление для леммы отмечается знаком ¦ ). Записывается в следующем формате:
// число усекаемых букв/надставляемые буквы (могут иметь знак ударения ('), который всегда переносится в словоформу)/величина смещения ударения (может быть 2 значения)/номер слога от конца слова, в которое переносится ударение.
// Если значения в графах 2-4 дублируются, знак ударения ставится в месте дублировки всё равно только один. В словоформе же может быть несколько знаков ударений (в разных слогах).
// Если в третьей графе стоит _ , то ударение в исходном слове удаляется.


List<String> deleteMarksFromList(
    List<String> listToEdit, List<String> listMarksDelete) {
  List<String> resultList = listToEdit.map((graf) {
    listMarksDelete.forEach((markToDelete) {
      if (markToDelete != '_' || markToDelete != ' ' || markToDelete != '') {
        if (graf.trim().contains(markToDelete.trim())) {
          // print('222  $graf');

          final List tempList = graf.split(' ');

          final editedList = [];
          // print('qqq$tempList');

          tempList.forEach((element) {
            if (!element.trim().contains(markToDelete.trim())) {
              editedList.add(element);
            }
          });

          // print('qqqqww$editedList');

          graf = editedList.join(' ');
        }
      }
    });

    return graf;
  }).toList();

  return resultList;
}

List<String> addMarksToList(List<String> listToEdit, String markToAdd) {
  int countMark = 0;
  final lissst = listToEdit.map((graf) {
    if (markToAdd == '_' || markToAdd == ' ' || markToAdd == '') {
      return graf;
    }

    if ((graf.trim()).contains(markToAdd.trim())) {
      countMark++;
    }

    return graf;
  }).toList();

  if (countMark == 0) {
    lissst.add('$markToAdd /');
  }

  return lissst;
}

List<String> addEndings(List<String> listToEdit, String endings) {
  return listToEdit.map((graf) {
    if (endings == '_' || endings == ' ' || endings == '') {
      return graf;
    }

    if (graf.contains('¦')) {
      //todo в отдельную функцию
      graf = graf.substring(0, graf.length - 4) +
          endings +
          graf.substring(graf.length - 4);
    }
    if (graf.contains('//')) {
      graf = graf.substring(0, graf.length - 4) +
          endings +
          graf.substring(graf.length - 4);
    }
    return graf;
  }).toList();
}

List<String> addPrefix(List<String> listToEdit, String prefix) {
  return listToEdit.map((graf) {
    if (prefix == '_' || prefix == ' ') {
      return graf;
    }

    if (graf.contains('¦')) {
      //todo в отдельную функцию
      graf = graf.substring(0, 2) + prefix + graf.substring(2, graf.length);
    }
    if (graf.contains('//')) {
      graf = graf.substring(0, 2) + prefix + graf.substring(2, graf.length);
    }
    return graf;
  }).toList();
}

Future<List<Map<String, dynamic>>> getAllRulesFromFile(String filePath) async {
  String content = await File(filePath).readAsString();

  // Разделяем содержимое на секции по символу '='
  List<String> sections = content.split(RegExp(r'=\d+='));

  // Создаем список для хранения результатов
  List<Map<String, dynamic>> allResults = [];

  // Обрабатываем каждую секцию
  for (String section in sections) {
    if (section.trim().isNotEmpty) {
      List<Map<String, String>> result = [];
      List<String> lines = section.split('\n');

      // Обрабатываем каждую строку в секции
      for (String line in lines) {
        line = line.trim(); // Убираем лишние пробелы

        if (line.isNotEmpty) {
          // Разделяем строку на ключ и значение по первому символу '.'
          int dotIndex = line.indexOf('.');
          if (dotIndex != -1) {
            String key = line.substring(0, dotIndex).trim();
            String value = line.substring(dotIndex + 1).trim();

            // Добавляем объект в список результатов
            result.add({key: value});
          }
        }
      }

      // Добавляем результаты секции в общий список
      allResults
          .add({'operation': '=${sections.indexOf(section)}=', 'data': result});
    }
  }

  // Выводим результаты
  // for (var section in allResults) {
  //   print(section);
  // }

  return allResults;
}

List<String> getInputList(String input) {
  RegExp regExp = RegExp(r'[^/]+? /\s*|— т-0 —/|- т0 -/|/ [^/]+ //');
  List<String> results = [];
  // Ищем все совпадения в строке
  Iterable<RegExpMatch> matches = regExp.allMatches(input);
  // Добавляем найденные совпадения в список
  for (var match in matches) {
    results.add(match.group(0)?.trim() ?? '');
  }
  // print(results.join('\n'));
  return results;
}

String? getRuleByNumber(
    {required String key, required List<Map<String, String>> listRules}) {
  for (var entry in listRules) {
    if (entry.containsKey(key)) {
      return entry[key];
    }
  }
  return null; // Возвращаем null, если ключ не найден
}
