pragma solidity ^0.8.28;

import "./TestSubhastaBaseV2.t.sol";
import "../src/SubhastaNoActualitzableV2Y.sol";
import "../src/ISubhastaV2.sol";

contract TestSubhastaNoActualitzableV2 is TestSubhastaBaseV2 {
    function creaSubhasta() internal override returns (ISubhasta) {
        SubhastaNoActualitzableV2Y subhasta = new SubhastaNoActualitzableV2Y();
        subhasta.initialize(address(this));

        return ISubhastaV2(address(subhasta));
    }
}
