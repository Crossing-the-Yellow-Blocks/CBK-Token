pragma solidity ^0.6.0;

import './CBK.sol';

contract TheYellowShop {

    CBK public CBKERC20;

    address payable public admin;

    event Withdrawn(uint toAdmin, uint burnt);

    constructor (address _CBK) public {
        CBKERC20 = CBK(_CBK);
        admin = msg.sender;
    }

    //Only the admin can interact with functions that include this modifier
    modifier onlyOwner() {
        require(msg.sender == admin, "Only the owner is allowed to access this function.");
        _;
    }

    function approveShop(uint amount) public onlyOwner {
        CBKERC20.increaseAllowance(address(this), amount);
    }

    function withdraw() public onlyOwner {
        uint burnAmount = CBKERC20.balanceOf(address(this))/10;
        CBKERC20.burnFrom(address(this), burnAmount);
        uint shopRedeemed = CBKERC20.balanceOf(address(this));
        CBKERC20.transferFrom(address(this), msg.sender, shopRedeemed);
        emit Withdrawn(shopRedeemed, burnAmount);
    }
}
