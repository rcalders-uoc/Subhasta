pragma solidity ^0.8.28;

import "./TestSubhastaActualitzableBase.t.sol";
import "../src/SubhastaUUPS.sol";
import "../src/SubhastaUUPSV2.sol";
import "../src/ISubhasta.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Test.sol";

contract TestSubhastaUUPS is TestSubhastaActualitzableBase {
    address private constant adradmin = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    function creaSubhasta() internal override {
        address admin = adradmin;
        vm.startPrank(adradmin);
        // Subhasta amb proxy UUPS
        SubhastaUUPS impluups = new SubhastaUUPS();

        bytes memory inituups = abi.encodeCall(SubhastaUUPS.initialize, (admin));
        ERC1967Proxy proxyuups = new ERC1967Proxy(address(impluups), inituups);

        subhasta = ISubhasta(address(proxyuups));
        vm.stopPrank();
    }

    function actualitzaSubhasta() internal override {
        address admin = adradmin;
        vm.startPrank(adradmin);

        SubhastaUUPSV2 novaImpl = new SubhastaUUPSV2();

        bytes memory initna = abi.encodeCall(SubhastaUUPSV2.initialize, (admin));

        // Fem crida baix nivell com es faria
        // en el proxy.
        address(novaImpl).call(initna);

        bytes memory data = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(novaImpl), bytes(""));

        (bool success, bytes memory returndata) = address(subhasta).call{value: 0}(data);
        require(success, "upgradeTo ha fallat");
        vm.stopPrank();
    }
}
