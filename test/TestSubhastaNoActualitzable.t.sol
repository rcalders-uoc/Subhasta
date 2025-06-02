pragma solidity ^0.8.28;

import "./TestSubhastaBase.t.sol";
import "../src/SubhastaNoActualitzable.sol";
import "../src/ISubhasta.sol";

contract TestSubhastaNoActualitzable is TestSubhastaBase {
    function creaSubhasta() internal override returns (ISubhasta) {
        SubhastaNoActualitzable subhasta = new SubhastaNoActualitzable();
        subhasta.initialize(address(this));

        return ISubhasta(address(subhasta));
    }
}
