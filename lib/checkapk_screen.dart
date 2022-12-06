import 'dart:convert';
import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sklite/tree/tree.dart';
import 'package:http/http.dart' as http;
import 'package:demo/contract_linking.dart';

class CheckApkScreen extends StatefulWidget {
  const CheckApkScreen({Key? key}) : super(key: key);

  @override
  State<CheckApkScreen> createState() => _CheckApkScreenState();
}

class _CheckApkScreenState extends State<CheckApkScreen> {
  late DecisionTreeClassifier tree;

  File? selectedApk;
  String result = '';
  String filename = '';
  bool inPredict = false;
  bool inPick = false;

  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<ContractLinking>(context);
    //TextEditingController yourNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("IAS DEMO"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: contractLink.isLoading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Form(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hello ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 52),
                            ),
                            Text(
                              contractLink.deployedName.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 52,
                                  color: Colors.tealAccent),
                            ),
                          ],
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 29),
                        //   child: TextFormField(
                        //     controller: yourNameController,
                        //     decoration: const InputDecoration(
                        //         border: OutlineInputBorder(),
                        //         labelText: "Your Name",
                        //         hintText: "What is your name ?",
                        //         icon: Icon(Icons.drive_file_rename_outline)),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 30),
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       primary: Colors.green,
                        //     ),
                        //     onPressed: () {
                        //       contractLink.checkApk(yourNameController.text);

                        //       LogUtil.e(contractLink.deployedName);
                        //       yourNameController.clear();
                        //     },
                        //     child: const Text(
                        //       'Set Name',
                        //       style: TextStyle(fontSize: 30),
                        //     ),
                        //   ),
                        // ),
                        if (inPick == true)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_download),
                              Text(
                                filename,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        TextButton(
                          onPressed: pickApk,
                          child: const Text('Pick APK to check'),
                        ),

                        if (inPick == true)
                          ElevatedButton(
                            onPressed: () => predictApk(contractLink),
                            child: const Text('Predict from APK'),
                          ),
                        const SizedBox(height: 24),

                        if (inPredict == true)
                          const Text(
                            'Predict Result',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                        const SizedBox(height: 8),

                        if (result.contains('0'))
                          const Text(
                            'BENIGNWARE',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        else if (result.contains('1'))
                          const Text(
                            'MALWARE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

                        ElevatedButton(
                          onPressed: () => sendEthToContract(contractLink),
                          child: const Text(
                              'Transfer contributor eth to contract'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  uploadApk() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.137.1:5000/upload"));
    final headers = {
      "Content-Type":
          "multipart/form-data; boundary=<calculated when request is sent>"
    };
    request.files.add(http.MultipartFile(
        'apk', selectedApk!.readAsBytes().asStream(), selectedApk!.lengthSync(),
        filename: selectedApk!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();

    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);
    setState(() {
      filename = decodedMap['filename'];
    });

    return filename;
  }

  sendEthToContract(ContractLinking contractLink) async {
    contractLink.sendEthToContract(1);
  }

  pickApk() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      selectedApk = File(result.files.single.path ?? '');
    }
    uploadApk();

    setState(() {
      inPick = true;
    });
  }

  predictApk(ContractLinking contractLink) async {
    final response = await http.get(
      Uri.parse("http://192.168.137.1:5000/predict?filename=$filename"),
    );

    //check condition
    contractLink.withdrawFunds();

    setState(() {
      result = response.body;
      inPredict = true;
    });
  }
  // void pickApk() async {
  //   contractLink.checkApk();

  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     selectedApk = File(result.files.single.path ?? '');
  //   }
  //   uploadApk();

  //   setState(() {
  //     inPick = true;
  //   });
  // }

}
