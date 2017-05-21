/*
file:   PayableERC20.sol
ver:    0.3.0
updated:21-May-2017
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A payable ERC20 token where payments are split according to token holdings.

The supply of this token is a constant of 100,000,000 which can intuitively
represent 100.000000% to be distributed to holders

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release notes:
- Complied with WithdrawalInterface
- Changed `withdrawFor(address _addr); returns (bool)` to 
    `withdrawFor(address _addr uint _value) returns (bool);`
- Added `withdraw(uint _value) returns (bool);`
- Added `withdrawFrom(address _addr, uint _value) returns (bool);`
*/

pragma solidity ^0.4.10;

import "https://github.com/o0ragman0o/Withdrawable/contracts/WithdrawableInterface.sol";
import "https://github.com/o0ragman0o/ERC20/ERC20.sol";
import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";

contract PayableERC20Interface 
{
/* Constants */

    // 100.000000% supply
    uint constant TOTALSUPPLY = 100000000;
    // 0.2% awarded to creator
    uint constant CREATORTOKENS = 200000;

/* State Valiables */

    bool public acceptingPayments;

    // The total ether deposits up to when a holder last triggered a claim
    uint deposits;
    
    // The contract balance when a holder last triggered a claim
    uint lastBalance;
    
    // Ether balances of token holders
    mapping (address => uint) etherBalance;
    
    // The paymentsToDate at the time of last claim for each holder 
    mapping (address => uint) lastClaimedAt;
    
/* Events */

    // Triggered when the contract recieves a payment
    event Deposit(uint value);
    
    // Triggered upon a withdrawal
    event Withdrawal(uint value);
    
    // Triggered when accepting payment state changes
    event AcceptingPayments(bool accepting);

/* Modifiers */

/* Function Abstracts */

    /// @notice Set the token symbol to `_symbol`. This can only be done once!
    /// @param _symbol The required token symbol
    /// @return success
    function setSymbol(string _symbol) returns (bool);

    /// @param _addr an account address
    /// @return The calculated balance of ether for `_addr`
    function etherBalanceOf(address _addr) constant returns (uint);

    /// @notice withdraw `_value` from account `msg.sender`
    /// @param _value the value to withdraw
    /// @return success
    function withdraw(uint _value) returns (bool);
    
    /// @notice withdraw `_value` from account `_addr`
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFor(address _addr, uint _value) returns (bool);
    
    /// @notice Withdraw `_value` from external contract at `_addr` to this
    /// this contract
    /// @param _addr a holder address in the contract
    /// @param _value the value to withdraw
    /// @return success
    function withdrawFrom(address _addr, uint _value) returns (bool);

    /// @notice Change accept payments to `_accept`
    /// @param _accept a bool for the required acceptance state
    /// @return success
    function acceptPayments(bool _accept) returns (bool);
}

contract PayableERC20 is ERC20Token, RegBase, PayableERC20Interface
{
/* Constants */
    
    bytes32 public constant VERSION = "PayableERC20 v0.3.0";

/* Functions Public non-constant*/

    function PayableERC20(address _creator, bytes32 _regName, address _owner)
        RegBase(_creator, _regName, _owner)
        ERC20Token(100000000, "")
    {
        _creator = _creator == 0x0 ? owner : _creator;
        acceptingPayments = true;
        balance[owner] = TOTALSUPPLY - CREATORTOKENS;
        balance[_creator] += CREATORTOKENS;
    }

    function() 
        payable
    {
        require(acceptingPayments && msg.value > 0);
        Deposit(msg.value);
    }
    
    /// @notice Will selfdestruct the contract on the condition it has zero
    /// balance
    function destroy()
        public
        onlyOwner
    {
        // must flush all ether balances first. But remainders may have
        // accumulated  under 100,000,000 wei
        require(this.balance <= 100000000);
        selfdestruct(msg.sender);
    }

    function setSymbol(string _symbol)
        onlyOwner
        returns (bool)
    {
        require(bytes(symbol).length == 0);
        symbol = _symbol;
        return true;
    }

    function acceptPayments(bool _accept)
        public
        onlyOwner
        returns (bool)
    {
        acceptingPayments = _accept;
        return true;
    }

    // Overload the ERC20 xfer() to account for unclaimed ether
    function xfer(address _from, address _to, uint _value)
        internal
        returns (bool)
    {
        require(_value > 0 && _value <= balance[_from]);
        
        // Update party's outstanding claims
        claimPaymentsFor(_from);
        claimPaymentsFor(_to);
        
        // Transfer tokens
        balance[_from] -= _value;
        balance[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function etherBalanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return etherBalance[_addr] + claimablePayments(_addr);
    }
    
    // Withdraw an amount of the sender's ether balance
    function withdraw(uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(msg.sender, _value);
    }
    
    // Withdraw on behalf of a balance holder
    function withdrawFor(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(_addr, _value);
    }
    
    // Withdraw from an external contract in which this contract has a balance.
    // Reentry is prevented to all but the default function to recieve payment.
    function withdrawFrom(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return WithdrawableInterface(_addr).withdraw(_value);
    }
    
    function intlWithdraw(address _addr, uint _value)
        internal
        returns (bool)
    {
        // Cache state values manipulate rather than re-writes
        // across a number of functions
        uint lastBal = lastBalance;
        uint ethBal = etherBalance[_addr];
        uint claim;
        
        // Check for unprocessed deposits
        if (this.balance > lastBal) {
            deposits += this.balance - lastBal;
            lastBal = this.balance;
        }

        // claimPaymentsFor(_addr);
        ethBal += balance[_addr] * (deposits - lastClaimedAt[_addr]) /
            TOTALSUPPLY;
        lastClaimedAt[_addr] = deposits;

        // check balance and withdraw on valid amount
        require(_value <= ethBal);
        etherBalance[_addr] = ethBal - _value;
        // lastBalance = this.balance - _value;
        lastBalance = lastBal - _value;
        Withdrawal(_value);
        _addr.transfer(_value);
        return true;
    }

    function paymentsToDate()
        public
        constant
        returns (uint)
    {
        return deposits + (this.balance - lastBalance); 
    }

    function updateDeposits()
        internal
    {
        // Update recent deposits
        uint lb = lastBalance;
        if (this.balance > lb) {
            deposits += this.balance - lb;
            lastBalance = this.balance;
        }
    }
    
    function claimPaymentsFor(address _addr)
        internal
    {
        updateDeposits();
        // Update accounts ether balance
        uint claim = claimablePayments(_addr);
        lastClaimedAt[_addr] = deposits;
        if (claim > 0) {
            etherBalance[_addr] += claim;
        }
    }

    function claimablePayments(address _addr)
        internal
        constant
        returns (uint)
    {
        // token balance * amount since last claim / supply
        return (balance[_addr] * (paymentsToDate() - lastClaimedAt[_addr])) /
            TOTALSUPPLY;
    }
}



contract PayableERC20Factory is Factory
{
//
// Constants
//

    bytes32 constant public regName = "PayableERC20";
    bytes32 constant public VERSION = "PayableERC20Factory v0.3.0";

//
// Functions
//

    /// @param _creator The calling address passed through by a factory,
    /// typically msg.sender
    /// @param _regName A static name referenced by a Registrar
    /// @param _owner optional owner address if creator is not the intended
    /// owner
    /// @dev On 0x0 value for _owner or _creator, ownership precedence is:
    /// `_owner` else `_creator` else msg.sender
    function PayableERC20Factory(address _creator, bytes32 _regName, address _owner)
        Factory(_creator, _regName, _owner)
    {
        // nothing to construct
    }

    /// @notice Create a new product contract
    /// @param _regName A unique name if the the product is to be registered in
    /// a SandalStraps registrar
    /// @param _owner An address of a third party owner.  Will default to
    /// msg.sender if 0x0
    /// @return kAddr_ The address of the new product contract
    function createNew(bytes32 _regName, address _owner)
        payable
        feePaid
        returns(address kAddr_)
    {
        require(_regName != 0x0);
        _owner = _owner == 0x0 ? msg.sender : _owner;
        _regName = _regName == 0x0 ? regName | bytes32(now) : _regName;
        kAddr_ = address(new PayableERC20(owner, _regName, _owner));
        Created(msg.sender, _regName, kAddr_);
    }
}

