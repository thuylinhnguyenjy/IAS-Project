import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcURl = "HTTP://192.168.137.1:7545";
  final String _wsURl = "ws://192.168.137.1:7545/";
  final String _privateKey =
      "0d58d09ce62763635ed42bd5d53c112d8fb0b760378f35b6fc1c45c744c8e993";

  late Web3Client _client;
  late String _abiCode;

  late EthereumAddress _contractAddress;
  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _successCheckCount;
  late ContractFunction _apks;
  late ContractFunction _checkApk;
  late ContractEvent _checkSucceedEvent;

  late ContractFunction _yourName;

  bool isLoading = false;
  String? deployedName;

  ContractLinking() {
    initialSetup();
  }

  initialSetup() async {
    _client = Web3Client(_rpcURl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsURl).cast<String>();
    });
    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile =
        await rootBundle.loadString("src/contracts/CheckApk.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);

    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "CheckApk"), _contractAddress);
    // Extracting the functions, declared in contract.
    _successCheckCount = _contract.function("successCheckCount");
    _apks = _contract.function("apks");
    getResult();
  }

  checkApk(String taskNameData) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _checkApk,
            parameters: [taskNameData]));

    getResult();
  }

  Future<void> getResult() async {
    // Getting the current name declared in the smart contract.
    var currentApk = await _client
        .call(contract: _contract, function: _successCheckCount, params: []);
    deployedName = currentApk[0].toString();

    notifyListeners();
  }
}
