//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProofOfTwitter is AccessControl {
    /*
     *  Events
     */
    event DailyLimitChange(uint indexed dailyLimit);
    event SetAddress(string indexed twitterId, address indexed correspondingAddress);

    /*
     *  Storage
     */
    uint public dailyLimit;
    uint public lastDay;
    uint public calledToday;
    bytes32 public constant CLOUD_ROLE = keccak256("CLOUD");
    mapping(string => address) public twitterIdToAddresses;

    /// @dev Add `owner` to the admin role as a member.
    constructor (address owner, uint256 _dailyLimit) 
    {
        _setupRole(DEFAULT_ADMIN_ROLE, owner);
        _setRoleAdmin(CLOUD_ROLE, DEFAULT_ADMIN_ROLE);
        dailyLimit = _dailyLimit;
    }

    /// @dev Restricted to members of the default role.
    modifier onlyAdmin()
    {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Restricted to cloud account.");
        _;
    }

    /// @dev Restricted to members of the cloud role.
    modifier onlyCloud()
    {
        require(hasRole(CLOUD_ROLE, msg.sender), "Restricted to cloud account.");
        _;
    }

    function setAddress(string memory _twitterId, address _address) external onlyCloud {
        require(isUnderLimit(), "Daily limit exceeded.");
        twitterIdToAddresses[_twitterId] = _address;
        emit SetAddress(_twitterId, _address);
    }

    /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.
    /// @param _dailyLimit Amount in wei.
    function changeDailyLimit(uint _dailyLimit)
        public
        onlyAdmin
    {
        dailyLimit = _dailyLimit;
        emit DailyLimitChange(_dailyLimit);
    }

    /*
     * Internal functions
     */
    /// @dev Returns if amount is within daily limit and resets calledToday after one day.
    /// @return Returns if amount is under daily limit.
    function isUnderLimit()
        internal
        returns (bool)
    {
        if (block.timestamp > lastDay + 24 hours) {
            lastDay = block.timestamp;
            calledToday = 0;
        }
        
        if (++calledToday > dailyLimit) return false;

        return true;
    }

}
