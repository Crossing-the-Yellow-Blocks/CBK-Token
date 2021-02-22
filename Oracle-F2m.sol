// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

import 'F2M-Libraries.sol';

contract OracleF2M {
    using FixedPoint for *;

    uint public period;

    IUniswapV2Pair public pair;
    address public token0;
    address public token1;
    address public admin;

    uint    public price0CumulativeLast;
    uint    public price1CumulativeLast;
    uint32  public blockTimestampLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    constructor(address _pair, address _token0, address _token1, uint256 _price0CumulativeLast, uint256 _price1CumulativeLast, uint32 _blockTimestampLast, uint _period) {
        pair = IUniswapV2Pair(_pair);
        token0 = _token0;
        token1 = _token1;
        price0CumulativeLast = _price0CumulativeLast; // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = _price1CumulativeLast; // fetch the current accumulated price value (0 / 1)
        admin = msg.sender;
        blockTimestampLast = _blockTimestampLast;
        period = _period;
    }
    
    modifier _onlyOwner() {
        require(msg.sender == admin);
        _;
    }
    
    function setPeriod(uint _newPeriod) public _onlyOwner {
        period = _newPeriod;
    }

    function newAdmin(address _newAdmin) public _onlyOwner {
        admin = _newAdmin;
    }

    function update() external {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pair));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // ensure that at least one full period has passed since the last update
        require(timeElapsed >= period, 'Oracle: PERIOD_NOT_ELAPSED');

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(address token, uint amountIn) external view returns (uint amountOut) {
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            require(token == token1, 'Oracle: INVALID_TOKEN');
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}


