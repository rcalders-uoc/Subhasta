pragma solidity ^0.8.28;

import "./TestSubhastaBase.t.sol";
import "../src/SubhastaUUPS.sol";
import "../src/ISubhasta.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract TestSubhastaUUPS is TestSubhastaBase {
    function creaSubhasta() internal override returns (ISubhasta) {
        address admin = tx.origin;

        // Subhasta amb proxy UUPS
        SubhastaUUPS impluups = new SubhastaUUPS();

        bytes memory inituups = abi.encodeCall(SubhastaUUPS.initialize, (admin));
        ERC1967Proxy proxyuups = new ERC1967Proxy(address(impluups), inituups);

        return ISubhasta(address(proxyuups));
    }
}
