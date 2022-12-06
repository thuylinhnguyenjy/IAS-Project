import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcURl = "HTTP://192.168.137.1:7545";
  final String _wsURl = "ws://192.168.137.1:7545/";
  final String _privateKey =
      "f63294adad1ac12c7512f2ee273d1d623d8f563404454ac29835103afa3f898e";

  late Web3Client _client;
  late String _abiCode;

  late EthereumAddress _contractAddress;
  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _successCheckCount;
  late ContractFunction _receive;
  late ContractFunction _withdrawFunds;

  late ContractFunction _checkApk;

  late ContractEvent _checkSucceedEvent;

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
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "CheckApk"), _contractAddress);
    _receive = _contract.function("Receive");
    _withdrawFunds = _contract.function("withdrawFunds");
    getResult();
  }

  sendEthToContract(int eth) async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _receive,
        parameters: [],
        value: EtherAmount.fromUnitAndValue(
          EtherUnit.ether,
          1,
        ),
      ),
    );
    print('sendEthToContract succeed');
  }

  withdrawFunds() async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _withdrawFunds,
        parameters: [BigInt.from(200000000000000000)],
      ),
    );
    print('withdrawFunds succeed');
  }

  checkApk() async {
    isLoading = true;
    notifyListeners();

    // await _client.sendTransaction(
    //     _credentials,
    //     Transaction.callContract(
    //         contract: _contract, function: _checkApk, parameters: [true]));

    getResult();
  }

  Future<void> getResult() async {
    // var currentApk = await _client
    //     .call(contract: _contract, function: _successCheckCount, params: []);
    // deployedName = currentApk[0].toString();

    notifyListeners();
  }
}
