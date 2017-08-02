/*
file:   PayableERC20.sol
ver:    0.4.0
updated:2-Aug-2017
author: Darryl Morris
email:  o0ragman0o AT gmail.com

A payable ERC20 token where payments are split according to token holdings.

WARNING: These tokens are not suitible for trade on a centralised exchange.
Doing so will result in permanent loss of ether.

The supply of this token is a constant of 100,000,000 which can intuitively
represent 100.000000% to be distributed to holders.


This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release notes
-------------
* Solidity 0.4.13
* Beaking Code
* Introduce orphaned token claiming
* Restructured holder data into struct
* Using Sandalstraps v0.3.0
* Using Withdrawable v0.2.0

*/

pragma solidity ^0.4.13;

import "https://github.com/o0ragman0o/Math/Math.sol";
import "https://github.com/o0ragman0o/ERC20/ERC20.sol";
import "https://github.com/o0ragman0o/SandalStraps/contracts/Factory.sol";
import "https://github.com/o0ragman0o/Withdrawable/contracts/Withdrawable.sol";

contract PayableERC20Abstract is ERC20Interface, WithdrawableAbstract
{
/* Constants */

    // 100.000000% supply
    uint64 constant TOTALSUPPLY = 100000000;
    
    // 0.1% of tokens are awarded to creator
    uint64 constant CREATORTOKENS = 100000;
    
    // Tokens untouched for 1 year can be redistributed
    uint64 public constant ORPHANED_PERIOD = 3 years;

/* Structs */
    struct Holder {
        // Token balance.
        uint64 balance;
        
        // Last time the account was touched.
        uint64 lastTouched;
        
        // The totalDeposits at the time of last claim.
        uint lastSumDeposits;
        
        // Ether balance
        uint etherBalance;
        
        // Thirdparty sender allownaces
        mapping (address => uint) allowed;
    }
    
/* Events */

    // Triggered upon a redistribution of untouched tokens
    event OrphanedTokensClaim(
        address indexed _from,
        address indexed _to,
        uint _amount,
        uint _value);

/* Modifiers */

/* Function Abstracts */

    /// @dev Deposits only receivable by the default account. Minimum gas is
    /// required as no state is mutated. 
    function() payable;

    /// @notice Set the token symbol to `_symbol`. This can only be done once!
    /// @param _symbol The chosen token symbol
    /// @return success
    function setSymbol(string _symbol) public returns (bool);
    
    /// @return Timestamp when an account is considered orphaned
    function orphanedAfter(address _addr) public constant returns (uint64);

    /// @notice Claim tokens of orphaned account `_addr`
    /// @param _addr Address of orphaned account
    /// @return _bool
    function salvageOrphanedTokens(address _addr) public returns (bool);
    
    /// @notice Refresh the time to orphan of holder account `_addr`
    /// @param _addr the address of a holder
    /// @return success
    function touch(address _addr) public returns (bool);

    /// @notice Transfer `_value` tokens from ERC20 contract at `_addr`
    /// @param _addr Address of and external ERC20 contract
    /// @param _value number of tokens to be transferred
    function transferAnyERC20Tokens(address _addr, uint _value)
        public returns (bool);

}


contract PayableERC20 is ReentryProtected, RegBase, PayableERC20Abstract
{
    using Math for uint;
    using Math64 for uint64;
    
/* Constants */
    
    bytes32 public constant VERSION = "PayableERC20 v0.4.0";

/* State Valiables */

    bool public acceptingDeposits;

    // The summation of ether deposited up to when a holder last triggered a 
    // claim
    uint sumDeposits;
    
    // The contract balance at last claim (transfer or withdraw)
    uint lastBalance;
    
    // Optional trading symbol
    string sym;

    // Mapping of holder accounts
    mapping (address => Holder) holders;

/* Functions Public non-constant*/

    // This is a SandalStraps Framework compliant constructor
    function PayableERC20(address _creator, bytes32 _regName, address _owner)
        RegBase(_creator, _regName, _owner)
    {
        _creator = _creator == 0x0 ? owner : _creator;
        acceptingDeposits = true;
        holders[owner].balance = TOTALSUPPLY.sub(CREATORTOKENS);
        holders[owner].lastTouched = uint64(now);
        holders[_creator].balance = holders[_creator].balance.add(CREATORTOKENS);
        holders[_creator].lastTouched = uint64(now);
    }

    /// @dev Deposits only receivable by the default account. Minimum gas is
    /// required as no state is mutated. 
    function() 
        payable
    {
        require(acceptingDeposits && msg.value > 0);
        Deposit(msg.sender, msg.value);
    }
    
//
// Contract managment functions
//

    /// @notice Owner can selfdestruct the contract on the condition it has
    /// near zero balance
    function destroy()
        public
        onlyOwner
    {
        // must flush all ether balances first. But imprecision may have
        // accumulated  under 100,000,000 wei
        require(this.balance <= 100000000);
        selfdestruct(msg.sender);
    }

    /// @notice Set the token symbol to `_symbol`. This can only be done once
    /// @param _symbol The token symbol
    function setSymbol(string _symbol)
        onlyOwner
        noReentry
        returns (bool)
    {
        require(bytes(sym).length == 0);
        sym = _symbol;
        return true;
    }
    
//
// Getters
//

    // Standard ERC20 Trading symbol getter
    function symbol()
        public
        constant
        returns (string)
    {
        return sym;
    }
    
    // Standard ERC20 token supply getter
    function totalSupply()
        public
        constant
        returns (uint)
    {
        return TOTALSUPPLY;
    }
    
    // Standard ERC20 token balance getter
    function balanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return holders[_addr].balance;
    }
    
    // Account specific ethereum balance getter
    function etherBalanceOf(address _addr)
        public
        constant
        returns (uint)
    {
        return holders[_addr].etherBalance.add(claimableEther(holders[_addr]));
    }

    // Standard ERC20 3rd party sender allowance getter
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint remaining_)
    {
        return holders[_owner].allowed[_spender];
    }

    function orphanedAfter(address _addr)
        public
        constant
        returns (uint64)
    {
        return holders[_addr].lastTouched.add(ORPHANED_PERIOD);
    }
    
    function isOrphaned(address _addr)
        public
        constant
        returns (bool)
    {
        return now > holders[_addr].lastTouched.add(ORPHANED_PERIOD);
    }

//
// ERC20 and Orphaned Tokens Functions
//

    // ERC20 standard tranfer. Send _value amount of tokens to address _to
    // Reentry protection prevents attacks upon the state
    function transfer(address _to, uint _amount)
        public
        noReentry
        returns (bool)
    {
        xfer(msg.sender, _to, uint64(_amount));
        return true;
    }

    // ERC20 standard tranferFrom. Send _value amount of tokens from address 
    // _from to address _to
    // Reentry protection prevents attacks upon the state
    function transferFrom(address _from, address _to, uint _amount)
        public
        noReentry
        returns (bool)
    {
        // Validate and adjust allowance
        uint64 amount = uint64(_amount);
        require(amount <= holders[_from].allowed[msg.sender]);
        
        // Adjust spender allowance
        holders[_from].allowed[msg.sender] = 
            holders[_from].allowed[msg.sender].sub(amount);
        
        xfer(_from, _to, amount);
        return true;
    }

    // Overload the ERC20 xfer() to account for unclaimed ether
    function xfer(address _from, address _to, uint64 _amount)
        internal
    {
        // Cache holder structs from storage to memory to avoid excessive SSTORE
        Holder memory from = holders[_from];
        Holder memory to = holders[_to];
        
        // Cannot transfer to self or the contract
        require(_from != _to);
        require(_to != address(this));

        // Validate amount
        require(_amount > 0 && _amount <= from.balance);
        
        // Update party's outstanding claims
        claimEther(from);
        claimEther(to);
        
        // Transfer tokens
        from.balance = from.balance.sub(_amount);
        to.balance = to.balance.add(_amount);

        // Commit changes to storage
        holders[_from] = from;
        holders[_to] = to;

        // Transfer(_from, _to, _amount);
    }

    // Approves a third-party spender
    // Reentry protection prevents attacks upon the state
    function approve(address _spender, uint _amount)
        public
        noReentry
        returns (bool)
    {
        require(holders[msg.sender].balance != 0);
        
        holders[msg.sender].allowed[_spender] = uint64(_amount);
        // Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice Refresh the shelflife of account `_addr`
    /// @param _addr The address of a holder
    function touch(address _addr)
        noReentry
        returns (bool)
    {
        require(holders[msg.sender].balance > 0);
        holders[_addr].lastTouched = uint64(now);
        return true;
    }

    /// @notice Claim tokens and ther of `_addr`
    /// @param _addr The holder address of orphaned tokens
    function salvageOrphanedTokens(address _addr)
        public
        noReentry
        returns(bool)
    {
        // Claim ownership if owner address itself has been orphaned
        if (now > orphanedAfter(owner)) {
            ChangedOwner(owner, msg.sender);
            owner = msg.sender;
        }
        // Caller must be owner
        require(msg.sender == owner);
        
        // Orphan account must have exceeded shelflife
        require(now > orphanedAfter(_addr));
        
        // Log claim
        OrphanedTokensClaim(
            _addr,
            msg.sender,
            holders[_addr].balance,
            holders[_addr].etherBalance);

        // Transfer orphaned tokens
        xfer(_addr, msg.sender, holders[_addr].balance);
        
        // Transfer ether. Orphaned ether was claimed during token transfer.
        holders[msg.sender].etherBalance = 
            holders[msg.sender].etherBalance.add(holders[_addr].etherBalance);
        
        // Delete ophaned account
        delete holders[_addr];

        return true;
    }
    
    /// @notice Transfer ERC20 tokens from `_addr` owned by this address to the
    /// owner of this contract
    /// @param _addr Address of an ERC20 token contract
    function transferAnyERC20Tokens(address _addr, uint _value)
        public
        onlyOwner
        returns(bool)
    {
        return ERC20Interface(_addr).transfer(msg.sender, _value);
    }

//
// Deposit processing function
//

    // Returns total deposits to date
    function deposits()
        public
        constant
        returns (uint)
    {
        return sumDeposits.add(this.balance - lastBalance); 
    }
    
    // Owner operated switch to accept/decline deposits to the contract
    function acceptDeposits(bool _accept)
        public
        noReentry
        onlyOwner
        returns (bool)
    {
        acceptingDeposits = _accept;
        AcceptingDeposits(_accept);
        return true;
    }

//
// Withdrawal processing functions
//

    // Withdraw an amount of the sender's ether balance
    function withdraw(uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(msg.sender, _value);
    }
    
    // Withdraw a value of ether sending it to the specified address
    function withdrawTo(address _to, uint _value)
        public
        returns (bool)
    {
        require(etherBalanceOf(msg.sender) >= _value);
        Withdrawal(msg.sender, _value);
        _to.transfer(_value);
        return true;
    }
    
    // Withdraw on behalf of a balance holder
    function withdrawFor(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return intlWithdraw(_addr, _value);
    }
    
    // Pull payment from an external contract in which this contract has a
    // balance.
    // Reentry is prevented to all but the default function to recieve payment.
    function withdrawFrom(address _addr, uint _value)
        public
        preventReentry
        returns (bool)
    {
        return WithdrawableAbstract(_addr).withdraw(_value);
    }
    
    // Account withdrawl function
    function intlWithdraw(address _addr, uint _value)
        internal
        returns (bool)
    {
        Holder memory holder = holders[_addr];
        claimEther(holder);
        
        // check balance and withdraw on valid amount
        require(_value <= holder.etherBalance);
        holder.etherBalance = holder.etherBalance.sub(_value);
        holders[_addr] = holder;
        
        // snapshot adjusted contract balance
        lastBalance = lastBalance.sub(_value);
        
        // Withdrawal(_addr, _value);
        _addr.transfer(_value);
        return true;
    }

//
// Payment distribution functions
//

    // Ether balance delta for holder's unclaimed ether
    // function claimableDeposits(address _addr)
    function claimableEther(Holder holder)
        internal
        constant
        returns (uint)
    {
        return uint(holder.balance).mul(
            deposits().sub(holder.lastSumDeposits)
            ).div(TOTALSUPPLY);
    }
    
    // Claims share of ether deposits
    // before withdrawal or change to token balance.
    function claimEther(Holder holder)
        internal
        returns(Holder)
    {
        // Update unprocessed deposits
        if (lastBalance != this.balance) {
            sumDeposits = sumDeposits.add(this.balance.sub(lastBalance));
            lastBalance = this.balance;
        }

        // Claim share of deposits since last claim
        holder.etherBalance = holder.etherBalance.add(claimableEther(holder));
        
        // Snapshot deposits summation
        holder.lastSumDeposits = sumDeposits;

        // touch
        holder.lastTouched = uint64(now).add(ORPHANED_PERIOD);

        return holder;
    }
}


contract PayableERC20Factory is Factory
{
//
// Constants
//

    bytes32 constant public regName = "payableerc20";
    bytes32 constant public VERSION = "PayableERC20Factory v0.4.0";

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
        // kAddr_ = address(new PayableERC20(owner, _regName, _owner));
        Created(msg.sender, _regName, kAddr_);
    }
}

