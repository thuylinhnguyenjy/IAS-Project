pragma solidity >=0.4.22 <0.9.0;

contract CheckApk {

    uint256 public successCheckCount;

    struct SuspiciousApk {
        uint id;
        bool isSuccessTraining;
    }

    mapping (uint256 => SuspiciousApk) public apks;

    event CheckSucceed(uint id);

    constructor() {
        apks[0] = SuspiciousApk(0, true);
        successCheckCount = 1;
    }

    function checkApk(bool _isSuccess) public {
        uint256 _id = successCheckCount - 1;
        apks[successCheckCount++] = SuspiciousApk(_id, _isSuccess);
        emit CheckSucceed(_id);
    }
}