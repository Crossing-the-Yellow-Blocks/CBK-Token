import * as Constants from "./constants/index"

const web3 = new Web3(window.ethereum);


var F2M = new web3.eth.Contract(ABIF2M, address_f2m);
var ORACLE = new web3.eth.Contract(ABIORACLE, address_oracle);
var CBK = new web3.eth.Contract(ABIIERC20, address_cbk);
var USD = new web3.eth.Contract(ABIIERC20, address_usd);
var UNIPAIR = new web3.eth.Contract(ABIIERC20, address_usd);

var user;
var admin;

var buyPercentage;
var liquidityPercentage;
var minimumReserves;

var userBalanceCBK;
var userBalanceUSD;
var usdAllowanceToF2M;


async function startWeb3() {
	await window.ethereum.enable();
    user = ethereum.selectedAddress;
    
    getAllowance(user, address_f2m);
    getUserCBK(user);
    getUserUSD(user);

}


//CALL Functions

async function getAllowance(owner, spender) {
	await USD.methods.allowance(owner, spender).call().then(r => {
		usdAllowanceToF2M = Number(r);
	});
}

async function getUserCBK(address) {
	await CBK.methods.balanceOf(address).call().then(r => {
		userBalanceCBK = Number(r);
		document.getElementById('cbk_balance').innerHTML = Number((convert(userBalanceCBK, "wei", "ether")).toFixed(3));
	});
}

async function getUserUSD(address) {
	await USD.methods.balanceOf(address).call().then(r => {
		userBalanceUSD = Number(r);
		document.getElementById('usd_balance').innerHTML = Number((convert(userBalanceUSD, "wei", "ether")).toFixed(3));
	});
}


//SEND Functions

async function buyDefault(amount) {
	await F2M.methods.buyDefault(amount).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}

async function buy(amount, slippage, deadline) {
	await F2M.methods.buy(amount, slippage, deadline).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}

async function redeem(amount) {
	await F2M.methods.redeem(amount).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}

async function redeemCommunity(address, amount) {
	await F2M.methods.redeemCommunity(address, amount).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}

async function claimIfEnded(address) {
	await F2M.methods.claimDeposited(address).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}

async function approveRouterUSD(amount) {
	await USD.methods.approve(address_router, amount).send( {from: web3.givenProvider.selectedAddress}).on('receipt', function(receipt) {
		console.log(receipt);
	});
}


function update() {

		startWeb3();
}


window.onload = update();
