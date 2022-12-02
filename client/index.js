const Web3 = require('web3');
const Fl = require('./contracts/federated_learning.json');

const init = async () => {
    const web3 = new Web3('http://127.0.0.1:9545/');
    const contract = await new web3.eth.Contract(Fl.abi, '0xc8e291fd4eb23f22c4Bc29CEbbC837191bCEaA95');
    const name = await contract.methods.getNumber().call();
    console.log(name);
}

init();