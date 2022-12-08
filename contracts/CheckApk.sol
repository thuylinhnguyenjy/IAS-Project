pragma solidity >=0.4.22 <0.9.0;


contract CheckApk {
    address public owner;

    mapping(address => uint256) public balance;

    uint256 public myBalance;

    constructor() public {
        owner = msg.sender;
        myBalance = address(msg.sender).balance;
    }

    modifier ownerOnly {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this operation"
        );
        _;
    }

    function giveEthToContract() public payable {
      balance[msg.sender] += msg.value;
    }

//rut tien
    function withdrawEth(uint256 _amount) external {
        require(
            balance[msg.sender] >= _amount,
            "Withdrawal amount exceeds balance"
        );
        balance[msg.sender] = balance[msg.sender] - _amount;
        myBalance = address(msg.sender).balance;
        address payable recipient = payable(msg.sender);
        recipient.transfer(_amount);
    }

    // function balanceOf() public view returns (uint256) {return address(msg.sender).balance;}

}