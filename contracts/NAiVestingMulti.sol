// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";  // import SafeERC20
import "@openzeppelin/contracts/access/Ownable.sol";

contract NAiVestingMulti is Ownable {
    using SafeERC20 for IERC20;  // sử dụng thư viện SafeERC20 cho IERC20

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimed;
    }

    IERC20 public immutable token;
    mapping(address => VestingSchedule) public vestings;

    event BeneficiaryAdded(address indexed beneficiary, uint256 amount);
    event Claimed(address indexed beneficiary, uint256 amount);

    constructor(address _token) {
        require(_token != address(0), "Invalid token");
        token = IERC20(_token);
    }

    function addBeneficiary(
        address beneficiary,
        uint256 amount,
        uint256 startTime,
        uint256 cliff,
        uint256 duration
    ) external onlyOwner {
        require(beneficiary != address(0), "Invalid address");
        require(vestings[beneficiary].totalAmount == 0, "Already exists");
        require(duration > 0, "Duration must be > 0");

        vestings[beneficiary] = VestingSchedule({
            totalAmount: amount,
            startTime: startTime,
            cliff: cliff,
            duration: duration,
            claimed: 0
        });

        emit BeneficiaryAdded(beneficiary, amount);
    }

    function claim() external {
        VestingSchedule storage vest = vestings[msg.sender];
        require(vest.totalAmount > 0, "No vesting");

        uint256 vested = _vestedAmount(vest);
        uint256 claimable = vested - vest.claimed;
        require(claimable > 0, "Nothing to claim");

        vest.claimed += claimable;
        token.safeTransfer(msg.sender, claimable);  // dùng safeTransfer thay cho transfer

        emit Claimed(msg.sender, claimable);
    }

    function _vestedAmount(VestingSchedule memory vest) internal view returns (uint256) {
        if (block.timestamp < vest.startTime + vest.cliff) {
            return 0;
        }

        uint256 elapsed = block.timestamp - (vest.startTime + vest.cliff);
        if (elapsed >= vest.duration) {
            return vest.totalAmount;
        }

        return (vest.totalAmount * elapsed) / vest.duration;
    }

    function vestedOf(address beneficiary) external view returns (uint256) {
        return _vestedAmount(vestings[beneficiary]);
    }

    function claimableOf(address beneficiary) external view returns (uint256) {
        VestingSchedule memory vest = vestings[beneficiary];
        return _vestedAmount(vest) - vest.claimed;
    }

    function recoverWrongToken(address _token, uint256 amount) external onlyOwner {
        require(_token != address(token), "Can't recover vested token");
        IERC20(_token).safeTransfer(owner(), amount);  // dùng safeTransfer
    }
}
