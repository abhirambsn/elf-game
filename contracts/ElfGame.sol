// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract ElfGame is ERC721 {
    struct Character {
        uint256 characterIdx;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    struct Villain {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    Villain public villain;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    Character[] defaultCharacters;

    mapping(uint256 => Character) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIdx);
    event AttackComplete(address sender, uint256 newVillainHp, uint256 newPlayerHp);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string memory villainName,
        string memory villainImageURI,
        uint256 villainHp,
        uint256 villainAttackDamage
    ) ERC721("ElfGame", "ELFG") {
        villain = Villain({
            name: villainName,
            imageURI: villainImageURI,
            hp: villainHp,
            maxHp: villainHp,
            attackDamage: villainAttackDamage
        });

        console.log(
            "Done initializing villain %s w/ HP %s, img %s",
            villain.name,
            villain.hp,
            villain.imageURI
        );

        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                Character({
                    characterIdx: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i]
                })
            );
            Character memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
            _tokenIds.increment();
        }
    }

    function mintCharacter(uint256 _charIdx) external {
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = Character({
            characterIdx: _charIdx,
            name: defaultCharacters[_charIdx].name,
            imageURI: defaultCharacters[_charIdx].imageURI,
            hp: defaultCharacters[_charIdx].hp,
            maxHp: defaultCharacters[_charIdx].maxHp,
            attackDamage: defaultCharacters[_charIdx].attackDamage
        });
        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _charIdx
        );
        nftHolders[msg.sender] = newItemId;
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _charIdx);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        Character memory charAttr = nftHolderAttributes[_tokenId];
        string memory strHp = Strings.toString(charAttr.hp);
        string memory strMaxHp = Strings.toString(charAttr.maxHp);
        string memory strAttackDamage = Strings.toString(charAttr.attackDamage);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttr.name,
                " -- NFT #: ",
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Elf Jujutsu!", "image": "',
                charAttr.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,
                "} ]}"
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function attackVillain() public {
        uint256 nftTokenOfPlayer = nftHolders[msg.sender];
        Character storage player = nftHolderAttributes[nftTokenOfPlayer];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Villain %s has %s HP and %s AD",
            villain.name,
            villain.hp,
            villain.attackDamage
        );

        require(
            player.hp > 0,
            "Error: character must have HP to attack villain."
        );
        require(
            villain.hp > 0,
            "Error: villain must have HP to attack player."
        );

        if (villain.hp < player.attackDamage) {
            villain.hp = 0;
        } else {
            villain.hp = villain.hp - player.attackDamage;
        }

        if (player.hp < villain.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - villain.attackDamage;
        }

        // Console for ease.
        console.log("Player attacked villain. New villain hp: %s", villain.hp);
        console.log("Villain attacked player. New player hp: %s\n", player.hp);
        emit AttackComplete(msg.sender, villain.hp, player.hp);
    }

    function checkIfUserHasNFT() public view returns (Character memory) {
        uint256 nftTokenId = nftHolders[msg.sender];
        if (nftTokenId > 0) {
            return nftHolderAttributes[nftTokenId];
        } else {
            Character memory empty;
            return empty;
        }
    }

    function getDefaultCharacters() public view returns (Character[] memory) {
        return defaultCharacters;
    }

    function getVillain() public view returns (Villain memory) {
        return villain;
    }
}
