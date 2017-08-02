# PayableERC20 - A payments Distributor
v0.4.0

A Payable ERC20 Token

WARNING: This codebase is not yet production ready.  It has not been fullt tested or audited.

NOTE: These tokens are not suitable for trading on a centralised exchange or where the token owner cannot call the contract to withdraw.
Attemping to do so will result in permanent loss of funds.

&copy; 2017 Darryl Morris 

License: MIT

## Overview

PayableERC20 is a payment distributor implimenting the ERC20 token standard. Payments recieved are distributed to token holders proportional to their holding at the time of payment.

It has a fixed supply of 100,000,000 tokens which can be represented as 100.000000% making transfers and holding balances more intutive.

Upon creation, the total supply is granted to the owner who can then transfer to parties accordingly.

Payments sent to the default function can be sent with minimum transaction gas as no state processing is required.

Withdrawals can be made at any time and a `withdrawFrom()` function is implimented to call `withdraw()` of an external contract where the current
instance may be a value holder.

To mitigate the risk of lost payments due to orphaned accounts, the owner can salvage orphaned tokens and funds is an account has not been touched
for a period specified by the ORPHANED_PERIOD (nominally 3 years).  If the owner account itself is orphaned, then anyone can claim orphaned tokens and ownership of the contract.

These tokens are not suitible to be traded on a centralised exchange given that the `withdraw()` functions will typically not be accessible.
In these cases, funds allocated to the account cannot be retrieved by the owner.

In cases where a third party, such as an exchange, holds tokens in trust as IOU's, they may call the `withdrawTo(address _to, uint _value)` function in order to transfer accumulated funds to the intended ethereum address.

## Fee
A fee of 0.1% tokens is awared to the creator of the contract.  This is typically the contract's [SandalStraps](https://github.com/o0ragman0o/SandalStraps) factory.

___
## ABI
```
[{"constant":false,"inputs":[{"name":"_resource","type":"bytes32"}],"name":"changeResource","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_amount","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"etherBalanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"regName","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"withdrawTo","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"}],"name":"withdraw","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"deposits","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"},{"name":"_value","type":"uint256"}],"name":"TransferAnyERC20Tokens","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"resource","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"orphanedAfter","outputs":[{"name":"","type":"uint64"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"acceptOwnership","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_accept","type":"bool"}],"name":"acceptDeposits","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"},{"name":"_value","type":"uint256"}],"name":"withdrawFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"changeOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"isOrphaned","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_symbol","type":"string"}],"name":"setSymbol","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"salvageOrphanedTokens","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"newOwner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"},{"name":"_value","type":"uint256"}],"name":"withdrawFor","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining_","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"acceptingDeposits","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"VERSION","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"touch","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"inputs":[{"name":"_creator","type":"address"},{"name":"_regName","type":"bytes32"},{"name":"_owner","type":"address"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"eth","type":"uint256"}],"name":"OrphanedTokensClaim","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_accept","type":"bool"}],"name":"AcceptingDeposits","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Withdrawal","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"WithdrawnFrom","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_newOwner","type":"address"}],"name":"ChangeOwnerTo","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_oldOwner","type":"address"},{"indexed":true,"name":"_newOwner","type":"address"}],"name":"ChangedOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_resource","type":"bytes32"}],"name":"ChangedResource","type":"event"}]
```

___
## Functions

This contract extends the [ERC20 API](https://github.com/o0ragman0o/ERC20) with the following functions

### PayableERC20 (constructor)
```
function PayableERC20(address _creator, bytes32 _regName, address _owner)
```
A [SandalStraps](https://github.com/o0ragman0o/SandalStraps) compliant constructor. This constructor will award 0.2% of tokens to `_creator`.

`_creator` Typically the creating factory address. Can be "" if deployed manually.

`_regName` A unique registrar name for indexing in a SandalStraps registrar. Can be "" if deployed manually.

`_owner` The address of a third party owner if `msg.sender` is not the intended owner. Can be "" to default to `msg.sender` is intended owner.


### *default function*
```
function () payable;
```
The default function is payable only if `acceptingPayments` is `true` and is the only `payable` function of the contract.
This function does not process state variables and so can recieve transactions with minimal gas.

### RegBase Functions
### regName
```
function regName() constant returns(bytes32 regName_);
```
Returns the register name of the contract. Can be made human readable using:

`web3.toUtf8(<contract>.regName())`

### owner
```
function owner() constant returns (address owner_);
```
Returns the contract owner address

### newOwner
```
function newOwner() constant returns (address);
```
Returns an address permissioned to accept contract ownership.

### changeOwner
```
function changeOwner(address _owner);
```
To change the contract owner

`owner_` The address to transfer ownership to

### acceptOwnership
```
function acceptOwnership() public returns (bool);
```
Finalise change of ownership to newOwner

### destroy
```
function destroy() public onlyOwner
```
Owner can selfdestruct the contract on the condition it has near zero balance

### VERSION
```
function VERSION() constant returns (bytes32 version_);
```
Returns the version string constant

`web3.toUtf8(<contract>.VERSION())`

### resource (optional)
```
function resource() constant returns(bytes32 resource_);
``` 
Returns general purpose 32 byte resource.  This may be use for storing short
informational text or used as an index/key/hash into such as a string mapping
for front end URL discovery

### acceptingDeposits
```
bool public acceptingDeposits;
```
Returns the boolean state of whether the contract accepts payments.

### deposits
```
function deposits() public constant returns (uint)
```
Returns total deposits to date.

### symbol
```
function symbol() public constant returns (string)
```
Standard ERC20 Trading symbol getter

### totalSupply
```
function totalSupply() public constant returns (uint)
```
Standard ERC20 token supply getter.
    
### balanceOf
```
function balanceOf(address _addr) public constant returns (uint)
```
Standard ERC20 token balance getter.

### etherBalanceOf(address _addr) constant returns (uint);
```
function etherBalanceOf(address _addr) constant returns (uint);
```
`_addr` a holder address.

Returns the calculated balance of ether for `_addr`.

### allowance
```
function allowance(address _owner, address _spender) public constant returns (uint remaining_)
```
Standard ERC20 3rd party sender allowance getter.

### ORPHANED_PERIOD
```
function ORPHANED_PERIOD() public constant returns (uint64);
```
Returns number of seconds before an account is considered orphaned.

### orphanedAfter
```
function orphanedAfter(address _addr) public constant returns (uint64)
```
The timestamp after which a holder's tokens are orphaned if that account is not touched,
transferred or withdrawn from.

`_addr` a holder address.

Returns Unix timestamp in seconds.

### isOrphaned
```
function isOrphaned(address _addr) public constant returns (bool)
```
Returns a boolean orphaned state of the account.

`_addr` a holder address.

### setSymbol
```
function setSymbol(string _symbol) returns (bool);
```
Set the token symbol to `_symbol`. This can only be done once!

`_symbol` The required token symbol.

Returns success boolean.

### transfer
```
function transfer(address _to, uint _amount) public returns (bool)
```
ERC20 standard tranfer.

`_to` An ethereum address to transfer token ownership to.

`_amount` amount of tokens to transfer

Returns success boolean

### transferFrom
```
function transferFrom(address _from, address _to, uint _amount) public returns (bool)
```
ERC20 standard tranferFrom.

`_from` An address where sender is permission to transfer token ownership from

`_to` An ethereum address to transfer token ownership to.

`_amount` amount of tokens to transfer

Returns success boolean

### approve
``` 
function approve(address _spender, uint _amount) public returns (bool)
```
ERC20 standard approve

`_spender` An ethereum address

`_amount` An amount of tokens the spender is approved to transfer

Returns success boolean

### touch
```
function touch(address _addr)
```
Refresh the orphaned period of account `_addr`

`_addr` The address of a holder
    
### withdraw
```
function withdraw(uint _value) returns (bool);
```
Withdraws a value of ether from the sender's balance.

`_value` the value to withdraw.

Returns success boolean
    
### withdrawTo
```
function withdrawTo(address _to, uint _value) returns (bool)
```

Withdraws a value of ether from the contract sending it to a thirdparty address.

`_to` a recipient address
`_value` the value to withdraw
Returns success boolean

### withdrawFor
```
function withdrawFor(address _addr, uint _value) returns (bool);
```
Withdraws a value of ether from a balance holder to their address.

`_addr` a holder address in the contract.

`_value` the value to withdraw.

Returns success boolean
 
### withdrawFrom
```
function withdrawFrom(address _addr, uint _value) returns (bool);
```
Call `withdraw()` of an external contract.

`_addr` An external contract with a `withdraw()` function.

`_value` the value to withdraw.

Return success boolean

### acceptDeposits
```
function acceptDeposits(bool _accept) returns (bool);
```
Change `acceptDeposits` to `_accept`.

`_accept` a bool for the required acceptance state.

Returns success boolean

### salvageOrphanedTokens
```
function salvageOrphanedTokens(address _addr) public returns(bool);
```
Recover orphanded tokens and associated funds.
If the owner account itself has been orphaned, contract ownership transferred to the caller.

`_addr` The holder address of orphaned tokens

### transferAnyERC20Tokens
```
function transferAnyERC20Tokens(address _addr, uint _amount) public onlyOwner returns(bool);
```
Allows the owner to sweep ERC20 tokens held by the contract address to the owner address.

`_addr` Address of and ERC20 contract at which this instance may hold tokens

`_amount` An amount of tokens to transfer.

Returns success boolean

___
## Events

### AcceptingDeposits;
```
event AcceptingDeposits(bool _accepting);
```
Triggered when accepting payment state changes.

### Deposit
```
event Deposit(address indexed _from, uint _value);
```
Triggered upon receiving a deposit
    
### Transfer
```
event Transfer(address indexed _from, address indexed _to, uint256 _value);`
```
Triggered when tokens are transferred.

### Approval
```
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
```
Triggered whenever approve(address _spender, uint256 _value) is called.

### Withdrawal
```
event Withdrawal(uint _value);
```
Triggered upon a withdrawal of `value`.

### WithdrawFrom

`event WithdrawnFrom(address indexed _from, uint _value)`

Trigger when a call to withdrawl from an external contract

### ChangeOwnerTo
```
event ChangeOwnerTo(address indexed _newOwner);
```
Triggered on initiation of change owner address

### ChangedOwner
```
event ChangedOwner(address indexed _oldOwner, address indexed _newOwner);
```
Triggered on change of owner address

### OrphanedTokensClaim
```
event OrphanedTokensClaim(address indexed _from, address indexed _to, uint _amount, uint _value);
```
Triggered upon reclaiming orphaned tokens
    


