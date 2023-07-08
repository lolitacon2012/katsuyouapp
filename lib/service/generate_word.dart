import '../data/constants.dart';
import "dart:math";

class WordToLearn {
  String fromWord;
  String fromWordYomikata;
  String toWord;
  String toWordYomikata;
  String toType;

  WordToLearn(this.fromWord, this.fromWordYomikata, this.toWord,
      this.toWordYomikata, this.toType);
}

WordToLearn generateRandomWord(List<int> enabledKatsuyouIndexes) {
  final random = Random();
  if (enabledKatsuyouIndexes.length < 2) {
    throw Exception(
        'Must have at least 2 indexes passed in to generateRandomWord.');
  } else {
    var fromIndex =
        enabledKatsuyouIndexes[random.nextInt(enabledKatsuyouIndexes.length)];
    var toIndex =
        enabledKatsuyouIndexes[random.nextInt(enabledKatsuyouIndexes.length)];
    while (fromIndex == toIndex) {
      toIndex =
          enabledKatsuyouIndexes[random.nextInt(enabledKatsuyouIndexes.length)];
    }
    var randomWord =
        fullVerbsRootData[random.nextInt(fullVerbsRootData.length)];
    var conjuType = randomWord[3];
    var rootKanji = randomWord[0];
    var rootYomikata = randomWord[1];
    var rentaiPostfix = randomWord[2];

    var fromWordConjuPostfix =
        katsuyouRules[conjuType]?[rentaiPostfix]?[fromIndex];
    var toWordConjuPostfix = katsuyouRules[conjuType]?[rentaiPostfix]?[toIndex];
    var toType = katsuyouName[toIndex];

    var fromWord = rootKanji + (fromWordConjuPostfix ?? '');
    var fromWordYomikata = rootYomikata + (fromWordConjuPostfix ?? '');
    var toWord = rootKanji + (toWordConjuPostfix ?? '');
    var toWordYomikata = rootYomikata + (toWordConjuPostfix ?? '');
    return WordToLearn(
        fromWord, fromWordYomikata, toWord, toWordYomikata, toType);
  }
}
