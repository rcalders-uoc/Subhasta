// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

abstract contract SubhastaBaseV2X is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    enum EstatSubhasta {
        Activa,
        CancelladaOwner,
        CancelladaVenedor,
        Finalitzada
    }

    struct Subhasta {
        address venedor;        // Camp de la V1
        uint48 tempsFinal;      // Camp de la V1
        address maximLicitador; // Camp de la V1
        uint256 maximaOferta;   // Camp de la V1
        bool finalitzada;       // Camp de la V1
        address contracteNFT;   // Camp de la V1
        // S'ha alterat la ordenació respecte de la versió 1.
        uint256 preuReserva;    // Camp de la V2 
        EstatSubhasta estat;    // Camp de la V2
        uint256 idToken;        // Camp de la V1
    }

    struct SubhastaStorage {
        uint256 idSubhasta;
        mapping(uint256 => Subhasta) subhastes;
        mapping(uint256 => mapping(address => uint256)) devolucionsPendents;
        // Percentatge mínim amb un decimal, per exemple 25 per a 2,5%.
        uint256 minIncrementOfertaPercentual;
    }

    // Numero de slot obtingut a partir de string "subhasta.base"
    // Script CalculSlot.s.sol

    function obteStorage() private pure returns (SubhastaStorage storage $) {
        assembly {
            $.slot := 0x64d06fe7cc5468c9110346d98bf957aae9cd9aab276781db020fba177b362e80
        }
    }

    // Esdeveniments

    event SubhastaCreada(uint256 idSubhasta, address venedor, address contracteNFT, uint256 idToken, uint48 tempsFinal);
    event OfertaRealitzada(uint256 idSubhasta, address licitador, uint256 oferta);
    event DevolucioFeta(uint256 idSubhasta, address licitador, uint256 oferta);

    event SubhastaFinalitzada(uint256 idSubhasta, address guanyador, uint256 oferta);
    event NFTTransferit(uint256 idSubhasta, address contracteNFT, uint256 idToken);

    event SubhastaCancellada(uint256 subhastaId, EstatSubhasta estat);

    function initializeBase(address initialOwner) internal onlyInitializing {
        __Ownable_init(initialOwner == address(0) ? msg.sender : initialOwner);
        __ReentrancyGuard_init();
        obteStorage().idSubhasta = 1;
    }

    function novaSubhastaPreuReserva(
        address venedor,
        uint48 duradaSubhasta,
        address contracteNFT,
        uint256 idToken,
        uint256 preuReserva
    ) public nonReentrant returns (uint256 idSubhasta) {
        require(contracteNFT != address(0), "NFT no pot ser 0'");
        require(duradaSubhasta > 0, "durada no pot ser 0");

        SubhastaStorage storage $ = obteStorage();
        idSubhasta = $.idSubhasta++;

        Subhasta storage subhasta = $.subhastes[idSubhasta];
        subhasta.venedor = venedor == address(0) ? msg.sender : venedor;
        subhasta.tempsFinal = uint48(block.timestamp + duradaSubhasta);
        subhasta.contracteNFT = contracteNFT;
        subhasta.idToken = idToken;
        subhasta.preuReserva = preuReserva;

        IERC721(contracteNFT).transferFrom(subhasta.venedor, address(this), idToken);

        emit SubhastaCreada(idSubhasta, subhasta.venedor, contracteNFT, idToken, subhasta.tempsFinal);
    }

    // Compatibilitat DApp versió anterior
    // S'elimina nonreentrant.

    function novaSubhasta(address venedor, uint48 duradaSubhasta, address contracteNFT, uint256 idToken)
        external
        returns (uint256 idSubhasta)
    {
        idSubhasta = novaSubhastaPreuReserva(venedor, duradaSubhasta, contracteNFT, idToken, 0);
    }

    function novaOferta(uint256 idSubhasta) external payable nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        Subhasta storage subhasta = $.subhastes[idSubhasta];
        require(subhasta.contracteNFT != address(0), "subhasta no existeix");
        require(block.timestamp < subhasta.tempsFinal, "subhasta no finalitzada");
        require(msg.value > subhasta.maximaOferta, "oferta massa baixa");
        require(msg.value > subhasta.preuReserva, "oferta inferior reserva");

        if (subhasta.maximaOferta > 0) {
            uint256 incrementMinim = (subhasta.maximaOferta * $.minIncrementOfertaPercentual) / 1000;
            require(msg.value >= subhasta.maximaOferta + incrementMinim, "increment massa petit");
        }

        if (subhasta.maximaOferta != 0) {
            $.devolucionsPendents[idSubhasta][subhasta.maximLicitador] += subhasta.maximaOferta;
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
        (bool ok,) = payable(msg.sender).call{value: oferta}("");
        require(ok, "devolucio ha fallat");
        emit DevolucioFeta(idSubhasta, msg.sender, oferta);
    }

    function finalitzacio(uint256 idSubhasta) external nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        Subhasta storage subhasta = $.subhastes[idSubhasta];
        require(subhasta.contracteNFT != address(0), "subhasta no trobada");
        require(!subhasta.finalitzada, "subhasta finalitzada");
        require(block.timestamp >= subhasta.tempsFinal, "subhasta encara activa");

        subhasta.finalitzada = true;

        address destinacio = subhasta.maximLicitador == address(0) ? subhasta.venedor : subhasta.maximLicitador;
        IERC721(subhasta.contracteNFT).safeTransferFrom(address(this), destinacio, subhasta.idToken);
        if (subhasta.maximaOferta != 0) {
            (bool ok,) = payable(subhasta.venedor).call{value: subhasta.maximaOferta}("");
            require(ok, "transferencia ETH ha fallat");
        }
        emit SubhastaFinalitzada(idSubhasta, subhasta.maximLicitador, subhasta.maximaOferta);
        emit NFTTransferit(idSubhasta, subhasta.contracteNFT, subhasta.idToken);
    }

    function cancellacioSubhastaVenedor(uint256 idSubhasta) external nonReentrant {
        SubhastaStorage storage $ = obteStorage();
        Subhasta storage subhasta = $.subhastes[idSubhasta];

        require(!subhasta.finalitzada, "ja finalitzada");
        require(subhasta.venedor == msg.sender, "cal ser-ne venedor");
        require(subhasta.maximaOferta == 0, "ja hi ha una oferta");

        subhasta.finalitzada = true;
        subhasta.estat = EstatSubhasta.CancelladaVenedor;
        IERC721(subhasta.contracteNFT).safeTransferFrom(address(this), subhasta.venedor, subhasta.idToken);

        emit SubhastaCancellada(idSubhasta, EstatSubhasta.CancelladaVenedor);
    }

    function estableixIncrementMinim(uint256 percentatge) external onlyOwner {
        require(percentatge > 0, "percentatge ha de ser > 0");
        obteStorage().minIncrementOfertaPercentual = percentatge;
    }
}
