pragma solidity ^0.8.28;

import "./TestSubhastaBaseActualitzacioV2.t.sol";
import "../src/SubhastaUUPSV2X.sol";
import "../src/ISubhasta.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Test.sol";

contract TestSubhastaUUPS is TestSubhastaBaseActualitzacioV2 {
    function creaSubhasta() internal override returns (ISubhasta) {
        address admin = tx.origin;
        vm.startPrank(admin);
        // Subhasta amb proxy UUPS
        SubhastaUUPSV2X impluups = new SubhastaUUPSV2X();

        bytes memory inituups = abi.encodeCall(SubhastaUUPSV2X.initialize, (admin));
        ERC1967Proxy proxyuups = new ERC1967Proxy(address(impluups), inituups);

        vm.stopPrank();
        return ISubhasta(address(proxyuups));
    }

    function actualitzaSubhasta() internal override {
        address admin = tx.origin;
        vm.startPrank(admin);

        SubhastaUUPSV2X novaImpl = new SubhastaUUPSV2X();

        bytes memory data = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(novaImpl), bytes(""));

        (bool success, bytes memory returndata) = address(subhasta).call{value: 0}(data);
        require(success, "upgradeTo ha fallat");
        vm.stopPrank();
    }
}
