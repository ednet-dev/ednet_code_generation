library ednet_core_gen;

import 'dart:io';
import 'package:ednet_core/ednet_core.dart';

part 'doc_gen.dart';
part 'lib_gen.dart';
part 'test_gen.dart';
part 'web_gen.dart';

late String libraryName;
late String domainName;
late String modelName;

late Repository ednetCoreRepository;
late Domain ednetCoreDomain;
late Model ednetCoreModel;

late String modelJson;

String firstLetterToUpper(String text) {
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

Directory genDir(String path) {
  var dir = new Directory(path);
  if (dir.existsSync()) {
    print('directory ${path} exists already');
  } else {
    dir.createSync();
    print('directory created: ${path}');
  }
  return dir;
}

File genFile(String path) {
  File file = new File(path);
  if (file.existsSync()) {
    print('file ${path} exists already');
  } else {
    file.createSync();
    print('file created: ${path}');
  }
  return file;
}

void addText(File file, String text) {
  IOSink writeSink = file.openWrite();
  writeSink.write(text);
  writeSink.close();
}

File getFile(String path) {
  return genFile(path);
}

String readTextFromFile(File file) {
  String fileText = file.readAsStringSync();
  return fileText;
}

void genGitignore(File file) {
  var text = '''
.DS_Store
.pub
build
packages
pubspec.lock
*~
  ''';
  addText(file, text);
}

void genReadme(File file) {
  var text = '';
  text = '${text}# ${domainName}_${modelName} \n';
  text = '${text}\n';
  text = '${text}**Categories**: ednet_core, class models. \n';
  text = '${text}\n';
  text = '${text}## Description: \n';
  text = '${text}${domainName}_${modelName} project uses \n';
  text = '${text}[EDNetCore] (https://github.com/ednet-dev/ednet_core) for the model.';
  addText(file, text);
}

/*
void genPubspec(File file) {
  var text = '''
name: ${domainName}_${modelName}
version: 0.0.1
author: Your Name
description: ${domainName}_${modelName} application that uses ednet_core for its model.
homepage: http://ondart.me/
environment:
  sdk: ^1.10.0
documentation:
dependencies:
  browser: any
  ednet_core:
    git: https://github.com/ednet-dev/ednet_core.git
  ednet_core_default_app:
    git: https://github.com/dzenanr/ednet_core_default_app.git
  ''';
  addText(file, text);
}
*/

void genPubspec(File file) {
  var text = '''
name: ${domainName}_${modelName}
version: 0.0.1
author: Your Name
description: ${domainName}_${modelName} application that uses ednet_core for its model.
homepage: http://ondart.me/
environment:
  sdk: ^1.10.0
documentation:
dependencies:
  browser: any
  ednet_core: any
  ednet_core_default_app: any
  ''';
  addText(file, text);
}


void genProject(String gen, String projectPath) {
  if (gen == '--genall') {
    genDir(projectPath);
    genDoc(projectPath);
    genLib(gen, projectPath);
    genTest(projectPath, ednetCoreModel);
    genWeb(projectPath);
    File gitignore = genFile('${projectPath}/.gitignore');
    genGitignore(gitignore);
    File readme = genFile('${projectPath}/README.md');
    genReadme(readme);
    File pubspec = genFile('${projectPath}/pubspec.yaml');
    genPubspec(pubspec);
  } else if (gen == '--gengen') {
    genLib(gen, projectPath);
  } else {
    print('valid gen argument is either --genall or --gengen');
  }
}

void createDomainModel(String projectPath) {
  var modelJsonFilePath = '${projectPath}/model.json';
  File modelJsonFile = getFile(modelJsonFilePath);
  modelJson = readTextFromFile(modelJsonFile);
  if (modelJson.length == 0) {
    print('missing json of the model');
  } else {
    ednetCoreRepository = new Repository();
    ednetCoreDomain = new Domain(firstLetterToUpper(domainName));
    ednetCoreModel = fromJsonToModel(modelJson, ednetCoreDomain, 
        firstLetterToUpper(modelName));
    ednetCoreRepository.domains.add(ednetCoreDomain);
  }
}

void main(List<String> args) {
  // --genall C:/Users/ridjanod/dart/project domain model
  // --gengen C:/Users/ridjanod/dart/project domain model

  // --genall /home/dr/dart/project domain model
  // --gengen /home/dr/dart/project domain model
  if (args.length == 4 && (args[0] == '--genall' || args[0] == '--gengen')) {
    domainName = args[2];
    modelName = args[3];
    domainName =  domainName.toLowerCase();
    modelName = modelName.toLowerCase();
    if (domainName == modelName) {
      throw new EDNetException('domain and model names must be different');
    }
    if (domainName == 'domain') {
      throw new EDNetException('domain cannot be the domain name');
    }
    if (modelName == 'model') {
      throw new EDNetException('model cannot be the model name');
    }
    libraryName = '${domainName}_${modelName}';
    createDomainModel(args[1]); // project path as argument
    genProject(args[0], args[1]);
  } else {
    print('arguments are not entered properly in Run/Manage Launches of Dart Editor');
  }
}
