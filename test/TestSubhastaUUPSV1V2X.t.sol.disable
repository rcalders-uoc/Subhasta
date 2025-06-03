pragma solidity ^0.8.28;

import "./TestSubhastaBaseActualitzacio.t.sol";
import "../src/SubhastaUUPS.sol";
import "../src/SubhastaUUPSV2X.sol";
import "../src/ISubhasta.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Test.sol";

contract TestSubhastaUUPS is TestSubhastaBaseActualitzacio {
    address private constant adradmin = 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720;

    function creaSubhasta() internal override returns (ISubhasta) {
        address admin = adradmin;
        vm.startPrank(adradmin);
        // Subhasta amb proxy UUPS
        SubhastaUUPS impluups = new SubhastaUUPS();

        bytes memory inituups = abi.encodeCall(SubhastaUUPS.initialize, (admin));
        ERC1967Proxy proxyuups = new ERC1967Proxy(address(impluups), inituups);

        vm.stopPrank();
        return ISubhasta(address(proxyuups));
    }

    function actualitzaSubhasta() internal override {
        address admin = adradmin;
        vm.startPrank(adradmin);

        SubhastaUUPSV2X novaImpl = new SubhastaUUPSV2X();

        bytes memory data = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", address(novaImpl), bytes(""));

        (bool success, bytes memory returndata) = address(subhasta).call{value: 0}(data);
        require(success, "upgradeTo ha fallat");
        vm.stopPrank();
    }
}
