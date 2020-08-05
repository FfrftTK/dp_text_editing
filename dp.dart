import 'dart:math';
import 'package:meta/meta.dart';
void main() {
  // example
  const input = 'abcdcb';
  const target = 'bacecb';
  final editController = EditController(
    input: input,
    target: target, 
    insertCost: (_) => 1, 
    deleteCost: (_) => 1, 
    replaceCost: (x, y) => x == y ? 0 : 1,
    );
  print('input: ${editController.input}');
  print('target: ${editController.target}');
  final costTable = editController.getCostTableAfterCalc();
  final res = costTable.fold('', (v1, e1) => '$v1\n${e1.fold('', (v2, e2) => '$v2 $e2')}');
  print('res: ${res}');
}
class EditController {
  EditController({
    this.input = '', 
    this.target = '',
    this.initialCost = 0,
    @required this.insertCost,
    @required this.deleteCost,
    @required this.replaceCost,
    }){
      this._initCostTable();
    }
  final String input;
  final String target;
  final num initialCost;
  final num Function(String) insertCost;
  final num Function(String) deleteCost;
  final num Function(String, String) replaceCost;
  List<List<num>> _costTable = [[]];
  List<List<num>> getCostTable() => _costTable;
  void _initCostTable(){
    final inputCharacters = _splitTextToCharacters(input);
    final targetCharacters = _splitTextToCharacters(target);
    _costTable = inputCharacters.map((_) => 
      targetCharacters.map((_) => initialCost).toList()).toList();
  }
  List<List<num>> getCostTableAfterCalc(){
    _calcCost(
      input.length-1, 
      target.length-1, 
      (i, j, r) {
        _costTable[i][j] = r;
        },
      );
    return _costTable;
  }
  void calcEditingCost({Function(int idxInput, int idxTarget, num res) onCalc}){
    _calcCost(input.length-1, target.length-1, onCalc ?? (x, y, z) => {});
  }
  num _calcCost(
    int idxInput, 
    int idxTarget, 
    Function(int idxInput, int idxTarget, num res) onCalc,
    ){
    if(idxInput < 1){
      final res = idxTarget * insertCost(input[idxTarget]);
      onCalc(idxInput, idxTarget, res);
      return res;
    }
    if(idxTarget < 1){
      final res = idxInput * deleteCost(input[idxInput]);
      onCalc(idxInput, idxTarget, res);
      return res;
    }
    final costBeforeInsert = _calcCost(idxInput, idxTarget-1, onCalc) + insertCost(input[idxTarget]);
    final costBeforeDelete = _calcCost(idxInput-1, idxTarget, onCalc) + deleteCost(input[idxTarget]);
    final costBeforeReplace = _calcCost(idxInput-1, idxTarget-1, onCalc) + replaceCost(input[idxInput], target[idxTarget]);
    final res = [costBeforeDelete, costBeforeInsert, costBeforeReplace].reduce(min);
    onCalc(idxInput, idxTarget, res);
    return res;
  }
  List<String> _splitTextToCharacters(String text){
    return text.split('');
  }
}
