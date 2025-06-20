pragma solidity ^0.8.28;

import "./TestSubhastaBaseV2.t.sol";
import "../src/SubhastaNoActualitzableV2.sol";
import "../src/ISubhastaV2.sol";

contract TestSubhastaNoActualitzableV2 is TestSubhastaBaseV2 {
    function creaSubhasta() internal override returns (ISubhasta) {
        SubhastaNoActualitzableV2 subhasta = new SubhastaNoActualitzableV2();
        subhasta.initialize(address(this));

        return ISubhastaV2(address(subhasta));
    }
}
