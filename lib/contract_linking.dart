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
      "bbe9b8075c17c26b9d1bfcfbca68e0214cfb0dcbc2c283b0cd729a7aa7ab2cf0";

  late Web3Client _client;
  late String _abiCode;

  late EthereumAddress _contractAddress;
  late Credentials _credentials;

  late DeployedContract _contract;
  late ContractFunction _successCheckCount;
  late ContractFunction _giveEthToContract;
  late ContractFunction _withdrawEth;
  late ContractFunction _balanceOf;
  late ContractFunction _checkApk;
  late ContractFunction _myBalance;

  late ContractEvent _checkSucceedEvent;

  String? balanceOfSender;

  bool isLoading = false;

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
    _myBalance = _contract.function("myBalance");
    _giveEthToContract = _contract.function("giveEthToContract");
    _withdrawEth = _contract.function("withdrawEth");
    getBalance();
  }

  sendEthToContract(int eth) async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _giveEthToContract,
        parameters: [],
        value: EtherAmount.fromUnitAndValue(
          EtherUnit.ether,
          1,
        ),
      ),
    );
    print('sendEthToContract succeed');
  }

  withdrawEth() async {
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _withdrawEth,
        parameters: [BigInt.from(300000000000000000)],
      ),
    );
    getBalance();
    print('withdrawFunds succeed');
  }

  getBalance() async {
    var res = await _client
        .call(contract: _contract, function: _myBalance, params: []);

    balanceOfSender = res[0].toString();
    notifyListeners();

    print('get balance succeed');
  }

  // checkApk() async {
  //   isLoading = true;
  //   notifyListeners();

  //   // await _client.sendTransaction(
  //   //     _credentials,
  //   //     Transaction.callContract(
  //   //         contract: _contract, function: _checkApk, parameters: [true]));

  //   getResult();
  // }

  // Future<void> getResult() async {
  //   var currentApk = await _client
  //       .call(contract: _contract, function: _successCheckCount, params: []);
  //   deployedName = currentApk[0].toString();

  //   notifyListeners();
  // }
}
