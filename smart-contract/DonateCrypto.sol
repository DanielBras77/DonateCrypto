// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17; // funciona com versões acima de 8.17

struct Campaign {
    address author;
    string title;
    string description;
    string videoUrl;
    string imageUrl;
    uint256 balance; // por default é 0
    bool active;
}

contract DonateCrypto {

    uint256 public fee = 100;//whei - menor fração da moeda Ether
    uint256 public nextId = 0;

    mapping(uint256 => Campaign) public campaigns; //campaignId => campaign (id para cada campanha)

    // calldata = dado temporário apenas de leitura
    // memory = dado temporário que permite escrita

    function addCampaign(
        string calldata title,
        string calldata description,
        string calldata videoUrl,
        string calldata imageUrl
    ) public {
        Campaign memory newCampaign;
        newCampaign.title = title;
        newCampaign.description = description;
        newCampaign.videoUrl = videoUrl;
        newCampaign.imageUrl = imageUrl;
        // msg -> objeto que possui dados sobre a requisição feita à blockchain
        newCampaign.author = msg.sender;
        newCampaign.active = true;

        nextId++;
        campaigns[nextId] = newCampaign;
    }

    // payabale - chamada da função com um pagamento

    function donate(uint256 campaignId) public payable {

        // require - validação, possui 2 parâmetros: condição de sucesso (doação > 0) e mensagem
        require(msg.value > 0, "You must send a donation value > 0");
        require(campaigns[campaignId].active == true, "Cannot donate to this campaign");
        
        campaigns[campaignId].balance += msg.value;
    }

    function withdraw(uint256 campaignId) public {

        Campaign memory campaign = campaigns[campaignId];
        require(campaign.author == msg.sender,"You do not have permission");
        require(campaign.active == true, "The campaign is closed");
        require(campaign.balance > fee, "This campaign does not have enough balance");

        // Criamos uma variável adress payable
        address payable recipient = payable(campaign.author);
        (bool success, ) = recipient.call{value: campaign.balance - fee}("");

        require(success == true, "Failed to withdraw");
        campaigns[campaignId].active = false;
    }

}