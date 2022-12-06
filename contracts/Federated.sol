pragma solidity >=0.4.22 <0.9.0;

contract Federated {

  mapping (address => string) models;
  address[] public trainers;

  function request_training(string memory _modelHash) public payable returns (uint256) {
    require(msg.value > 0, "You must send some ether!");

    address trainer = msg.sender;

    models[trainer] = _modelHash;
    trainers.push(trainer);

    return trainers.length;
  }

}

