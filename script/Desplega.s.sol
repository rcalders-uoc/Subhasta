// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../src/SubhastaTransparent.sol";
import "../src/SubhastaUUPS.sol";
import "../src/SubhastaNoActualitzable.sol";

contract VersioTransparent is Script {
    function run() external {
        vm.startBroadcast();

        // Subhasta amb proxy Transparent
        address admin = tx.origin;
        SubhastaTransparent impltransp = new SubhastaTransparent();

        bytes memory inittransp = abi.encodeCall(SubhastaTransparent.initialize, (admin));

        TransparentUpgradeableProxy proxytransp =
            new TransparentUpgradeableProxy(address(impltransp), admin, inittransp);

        vm.stopBroadcast();

        console2.log("Impl transp:", address(impltransp));
        console2.log("Proxy transp:", address(proxytransp));
    }
}

contract VersioUUPS is Script {
    function run() external {
        vm.startBroadcast();

        address admin = msg.sender;

        // Subhasta amb proxy UUPS
        SubhastaUUPS impluups = new SubhastaUUPS();

        bytes memory inituups = abi.encodeCall(SubhastaUUPS.initialize, (admin));
        ERC1967Proxy proxyuups = new ERC1967Proxy(address(impluups), inituups);

        // Subhasta sense proxy (no actualitzable)
        vm.stopBroadcast();

        console2.log("Impl uups:", address(impluups));
        console2.log("Proxy uups:", address(proxyuups));
    }
}

// Versió No-Actualitzable
// Servirà com a referència per mesurar l'overhead
// de les versions amb proxy.

contract VersioNA is Script {
    function run() external {
        vm.startBroadcast();

        address admin = msg.sender;

        // Subhasta amb proxy UUPS
        SubhastaNoActualitzable implna = new SubhastaNoActualitzable();

        bytes memory initna = abi.encodeCall(SubhastaNoActualitzable.initialize, (admin));

        // Fem crida baix nivell com es faria
        // en el proxy.
        address(implna).call(initna);

        // Subhasta sense proxy (no actualitzable)
        vm.stopBroadcast();

        console2.log("Impl na:", address(implna));
    }
}
