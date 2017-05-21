# PayableERC20 - A payments Distributor
A Payable ERC20 Token

&copy; 2017 Darryl Morris 

License: MIT

## Overview

PayableERC20 is a payment distributor implimenting the ERC20 token standard. Payments recieved are distributed to token holders proportional to their holding at the time of payment.

It has a fixed supply of 100,000,000 tokens which can be represented as 100.000000% making transfers and holding balances more intutive.

Upon creation, the total supply is granted to the owner who can then transfer to parties accordingly.

Payments sent to the default function can be sent with minimum transaction gas as no state processing is required.

Withdrawals can be made at any time and a `withdrawFrom()` function is implimented to call `withdraw()` of an external contract where the current
instance may be a value holder.

## Fee
A fee of 0.2% tokens is awared to the creator of the contract.  This is typically the contract's [SandalStraps](https://github.com/o0ragman0o/SandalStraps) factory.

### ABI
```
[{"constant":false,"inputs":[{"name":"_resource","type":"bytes32"}],"name":"changeResource","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"etherBalanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"regName","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"acceptingPayments","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"resource","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_addr","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_accept","type":"bool"}],"name":"acceptPayments","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"withdrawFor","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"paymentsToDate","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"changeOwner","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_symbol","type":"string"}],"name":"setSymbol","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining_","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"VERSION","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"inputs":[{"name":"_creator","type":"address"},{"name":"_regName","type":"bytes32"},{"name":"_owner","type":"address"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"uint256"}],"name":"Deposit","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"uint256"}],"name":"Withdrawal","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"accepting","type":"bool"}],"name":"AcceptingPayments","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"oldOwner","type":"address"},{"indexed":true,"name":"newOwner","type":"address"}],"name":"ChangedOwner","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"resource","type":"bytes32"}],"name":"ChangedResource","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}]
```

## Functions

This contract extends the [ERC20 API](https://github.com/o0ragman0o/ERC20) with the following functions

### PayableERC (constructor)
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

### acceptingPayaments
```
bool public acceptingPayments;
```
Returns the boolean state of whether the contract accepts payments.

### setSymbol
```
function setSymbol(string _symbol) returns (bool);
```
Set the token symbol to `_symbol`. This can only be done once!

`_symbol` The required token symbol.

Returns success


### etherBalanceOf(address _addr) constant returns (uint);
```
function etherBalanceOf(address _addr) constant returns (uint);
```
`_addr` an account address.

Returns the calculated balance of ether for `_addr`

### withdraw
```
function withdraw(uint _value) returns (bool);
```
Withdraws a value of ether from the sender's balance.

`_value` the value to withdraw.

Return success
    
### withdrawFor
```
    function withdrawFor(address _addr, uint _value) returns (bool);
```
Withdraws a value of ether from a balance holder to their address.

`_addr` a holder address in the contract.

`_value` the value to withdraw.

Returns success
 
### withdrawFrom
```
function withdrawFrom(address _addr, uint _value) returns (bool);
```
Call `withdraw()` of an external contract.

`_addr` An external contract with a `withdraw()` function.

`_value` the value to withdraw.

Return success

### acceptPayments
```
function acceptPayments(bool _accept) returns (bool);
```
Change accept payments to `_accept`.

`_accept` a bool for the required acceptance state.

Returns success.
    
## Events

### Deposit;
```
event Deposit
```
Triggered when the contract recieves a payment of `value`
    
### Withdrawal
```
event Withdrawal(uint value);
```
Triggered upon a withdrawalof `value`.

### AcceptingPayments;
```
AcceptingPayments(bool accepting);
```
Triggered when accepting payment state changes.

