// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/SubhastaTransparent.sol";
import "../src/SubhastaTransparentV2.sol";
import "../src/SubhastaUUPS.sol";
import "../src/SubhastaUUPSV2.sol";

import "../src/SubhastaNoActualitzable.sol";
interface FuncionsProxyAdmin {
    function upgradeAndCall(
        address proxy,
        address implementation,
        bytes calldata data
    ) external;
}
contract ActualitzaVersioTransparent is Script {
    address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");

    function run() external {
        vm.startBroadcast();
        // Subhasta amb proxy Transparent
       SubhastaTransparentV2 novaImpl = new SubhastaTransparentV2();

        // Llegim l'adreça de l'admin del proxy (contracte ProxyAdmin)
        bytes32 ADMIN_SLOT = bytes32(
            uint256(keccak256("eip1967.proxy.admin")) - 1
        );
        address adrecaProxyAdmin = address(
            uint160(uint256(vm.load(subhastaProxy, ADMIN_SLOT)))
        );

        console2.log("ProxyAdmin:", adrecaProxyAdmin);

        FuncionsProxyAdmin proxyAdmin = FuncionsProxyAdmin(adrecaProxyAdmin);
        proxyAdmin.upgradeAndCall(subhastaProxy, address(novaImpl), bytes(""));

        vm.stopBroadcast();

        console2.log("Impl transp:", address(novaImpl));
    }
}

contract ActualitzaVersioUUPS is Script {
   
    function run() external {
           vm.startBroadcast();
        address admin = tx.origin;

        address subhastaProxy = vm.envAddress("ADRECA_SUBHASTA");
          console2.log("Proxy:", subhastaProxy);
        SubhastaUUPSV2 novaImpl = new SubhastaUUPSV2();

      bytes memory initna = abi.encodeCall(
            SubhastaUUPSV2.initialize,
            (admin)
        );

        // Fem crida baix nivell com es faria
        // en el proxy.
        address(novaImpl).call(initna);

        bytes memory data = abi.encodeWithSignature(
            "upgradeToAndCall(address,bytes)",
            address(novaImpl), bytes("")
        );
     
        (bool success, bytes memory returndata) = subhastaProxy.call{value: 0}(data);
        require(success, "upgradeTo ha fallat");
        vm.stopBroadcast();
    }
}
