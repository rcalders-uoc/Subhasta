// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract SubhastaBase is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    struct Subhasta {
        address venedor;
        uint48 tempsFinal;
        address maximLicitador;
        uint256 maximaOferta;
        bool finalitzada;
        address contracteNFT;
        uint256 idToken;
    }

    struct SubhastaStorage {
        uint256 idSubhasta;
        mapping(uint256 => Subhasta) subhastes;
        mapping(uint256 => mapping(address => uint256)) devolucionsPendents;
    }

    // Numero de slot obtingut a partir de string "subhasta.base"
    // Script CalculSlot.s.sol

    function obteStorage() private pure returns (SubhastaStorage storage $) {
        assembly {
            $.slot := 0x64d06fe7cc5468c9110346d98bf957aae9cd9aab276781db020fba177b362e80
        }
    }

    // Esdeveniments

    event SubhastaCreada(
        uint256 idSubhasta,
        address venedor,
        address contracteNFT,
        uint256 idToken,
        uint48 tempsFinal
    );
    event OfertaRealitzada(
        uint256 idSubhasta,
        address licitador,
        uint256 oferta
    );
    event DevolucioFeta(uint256 idSubhasta, address licitador, uint256 oferta);

    event SubhastaFinalitzada(
        uint256 idSubhasta,
        address guanyador,
        uint256 oferta
    );
    event NFTTransferit(
        uint256 idSubhasta,
        address contracteNFT,
        uint256 idToken
    );

    // Funcions

    function initializeBase(address propietari) internal onlyInitializing {
        __Ownable_init(propietari == address(0) ? msg.sender : propietari);
        __ReentrancyGuard_init();
        obteStorage().idSubhasta = 1;
    }

    function novaSubhasta(
        address venedor,
        uint48 duradaSubhasta,
        address contracteNFT,
        uint256 idToken
    ) external nonReentrant returns (uint256 idSubhasta) {
        require(contracteNFT != address(0), "NFT no pot ser 0'");
        require(duradaSubhasta > 0, "durada no pot ser 0");

        SubhastaStorage storage $ = obteStorage();
        idSubhasta = $.idSubhasta++;

        Subhasta storage subhasta = $.subhastes[idSubhasta];
        subhasta.venedor = venedor == address(0) ? msg.sender : venedor;
        subhasta.tempsFinal = uint48(block.timestamp + duradaSubhasta);
        subhasta.contracteNFT = contracteNFT;
        subhasta.idToken = idToken;

        IERC721(contracteNFT).transferFrom(
            subhasta.venedor,
            address(this),
            idToken
        );

        emit SubhastaCreada(
            idSubhasta,
            subhasta.venedor,
            contracteNFT,
            idToken,
            subhasta.tempsFinal
        );
    }

    function novaOferta(uint256 idSubhasta) external payable nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        Subhasta storage subhasta = $.subhastes[idSubhasta];
        require(subhasta.contracteNFT != address(0), "subhasta no existeix");
        require(
            block.timestamp < subhasta.tempsFinal,
            "subhasta no finalitzada"
        );
        require(msg.value > subhasta.maximaOferta, "oferta massa baixa");

        if (subhasta.maximaOferta != 0) {
            $.devolucionsPendents[idSubhasta][
                subhasta.maximLicitador
            ] += subhasta.maximaOferta;
        }

        subhasta.maximLicitador = msg.sender;
        subhasta.maximaOferta = msg.value;

        emit OfertaRealitzada(idSubhasta, msg.sender, msg.value);
    }

    function devolucio(uint256 idSubhasta) external nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        uint256 oferta = $.devolucionsPendents[idSubhasta][msg.sender];
        require(oferta > 0, "res a retornar");
        $.devolucionsPendents[idSubhasta][msg.sender] = 0;
        (bool ok, ) = payable(msg.sender).call{value: oferta}("");
        require(ok, "devolucio ha fallat");
        emit DevolucioFeta(idSubhasta, msg.sender, oferta);
    }

    function finalitzacio(uint256 idSubhasta) external nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        Subhasta storage subhasta = $.subhastes[idSubhasta];
        require(subhasta.contracteNFT != address(0), "subhasta no trobada");
        require(!subhasta.finalitzada, "subhasta finalitzada");
        require(
            block.timestamp >= subhasta.tempsFinal,
            "subhasta encara activa"
        );

        subhasta.finalitzada = true;

        address destinacio = subhasta.maximLicitador == address(0)
            ? subhasta.venedor
            : subhasta.maximLicitador;
        IERC721(subhasta.contracteNFT).safeTransferFrom(
            address(this),
            destinacio,
            subhasta.idToken
        );
        if (subhasta.maximaOferta != 0) {
            (bool ok, ) = payable(subhasta.venedor).call{
                value: subhasta.maximaOferta
            }("");
            require(ok, "transferencia ETH ha fallat");
        }
        emit SubhastaFinalitzada(
            idSubhasta,
            subhasta.maximLicitador,
            subhasta.maximaOferta
        );
        emit NFTTransferit(idSubhasta, subhasta.contracteNFT, subhasta.idToken);
    }
}
