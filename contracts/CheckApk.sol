pragma solidity >=0.4.22 <0.9.0;


contract CheckApk {
    address public owner;

    mapping(address => uint256) public tokens;
    uint256 public totalTokens;

    // Eth withdrawable for each account.
    // The owner's balance is the stake which is released to trainers.
    mapping(address => uint256) public balance;

    // The non-owner addresses with non-zero balance.
    address[] public payableAddresses;

    // hash of models sent to the network, index on owner's address
    mapping (address => string) models;

    // record model owners
    address[] public dataScientists;

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this operation"
        );
        _;
    }

    function request_training(string memory _modelHash) public payable {
      require(msg.value > 0, "You must send some ether!");

      address dataScientist = msg.sender;

      models[dataScientist] = _modelHash;
      dataScientists.push(dataScientist);

      balance[dataScientist] += msg.value;
    }

    function giveTokens(address recipient, uint256 _numTokens) payable
        external
        ownerOnly()
    {
        totalTokens = totalTokens + _numTokens;
        if (tokens[recipient] == 0) {
            payableAddresses.push(recipient);
        }
        tokens[recipient] = tokens[recipient] + _numTokens;
    }

    function releaseFunds() external ownerOnly() {
        if (totalTokens > balance[owner]) {
            uint256 tokensPerWei = totalTokens / balance[owner];
            for (uint256 i = 0; i < payableAddresses.length; i++) {
                address recipient = payableAddresses[i];
                uint256 amount = tokens[recipient] / tokensPerWei;
                giveFunds(recipient, amount);
            }
        } else {
            uint256 weiPerToken = balance[owner] / totalTokens;
            for (uint256 i = 0; i < payableAddresses.length; i++) {
                address recipient = payableAddresses[i];
                uint256 amount = tokens[recipient] * weiPerToken;
                giveFunds(recipient, amount);
            }
        }
    }

    function Receive() public payable {
      balance[msg.sender] += msg.value;
    }

//rut tien
    function withdrawFunds(uint256 _amount) external {
        require(
            balance[msg.sender] >= _amount,
            "Withdrawal amount exceeds balance"
        );
        balance[msg.sender] = balance[msg.sender] - _amount;
        address payable recipient = payable(msg.sender);
        recipient.transfer(_amount);
    }

    function giveFunds(address recipient, uint256 _amount)
        // internal
        // ownerOnly()
        public
    {
        require(
            balance[msg.sender] >= _amount,
            "Payment amount exceeds balance"
        );
        balance[owner] = balance[owner] - _amount;
        balance[recipient] = balance[recipient] + _amount;
    }
}


// pragma solidity >=0.4.22 <0.9.0;

// contract CheckApk {

//     address public owner;

//     address payable [] public recipients;

//     address payable [] public _addrss;

//     uint256 public successCheckCount;
    
//     modifier onlyOwner() {
//         require(msg.sender == owner, "You're not the smart contract owner!");
//         _;
//     }

//     // struct SuspiciousApk {
//     //     uint id;
//     //     bool isSuccessTraining;
//     // }

//     // mapping (uint256 => SuspiciousApk) public apks;

//     mapping(address => uint256) public balance;

//     event CheckSucceed(uint id);

//     event TransferReceived(address _from, uint _amount);

//     event Deposited(address from, uint amount);

  


//     constructor() {
// // address[] memory markets = new address[](1)
// // markets[0] = address(cdaitoken)
    
//         // apks[0] = SuspiciousApk(0, true);
//         // successCheckCount = 1;
//     address _addr1 = 0x4eF87b6306aCD3F7E5d9Dd7b77C5B378497e4aB5;
//     address _addr2 = 0xB0BAC582099Bcd3BbD3A287447184769C7f26C52;
//     address _addr3 = 0xb4DF523eF4dB21344cbD6888d8b9De4945c24f56;
//         owner = msg.sender;

//         // for (uint i=0; i<_addrs.length; i++){
//         //     recipients.push(_addrs[i]);
//         // }
//         recipients.push(payable(_addr1));
//               recipients.push(payable(_addr2));
//          recipients.push(payable(_addr3));
//  // recipients.push(_addr2);
//         // recipients.push(_addr3);
//     }

//     function checkApk(bool _isSuccess) public {
//         // uint256 _id = successCheckCount - 1;
//         // apks[successCheckCount++] = SuspiciousApk(_id, _isSuccess);
//     //    if (_isSuccess == true) {receive() }
//         // emit CheckSucceed(_id);
//     }

//     function Receive() public payable {
//       balance[msg.sender] += msg.value;
//     }

//     receive() payable external {
//         uint256 share = msg.value;
//         for(uint i=0; i < recipients.length; i++){
//             recipients[i].transfer(share);
//         }    
//         emit TransferReceived(msg.sender, msg.value);
//     }  
  
// }