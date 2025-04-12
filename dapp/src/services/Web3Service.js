// ABI -> Especificação do Smart Contract com o qual nos vamos querer conectar
import ABI from "./ABI.json";
import Web3 from "web3";

const CONTRACT_ADDRESS = "0xd9145CCE52D386f254917e481eB44e9943F39138"; // Endereço do contrato

export async function doLogin() {
    if(!window.ethereum) {
        throw new Error("MetaMask não está instalada");
    }

    const web3 = new Web3(window.ethereum);

    // Arrays de endereços de contas disponíveis na MetaMask
    const accounts = await web3.eth.requestAccounts();

    if(!accounts || !accounts.length) throw new Error("Nenhuma carteira encontrada/autorizada");

    localStorage.setItem("wallet", accounts[0]);
    return accounts[0];
}

function getContract() {
    const web3 = new Web3(window.ethereum);
    const from = localStorage.getItem("wallet");

    return new web3.eth.Contract(ABI, CONTRACT_ADDRESS, { from });
}

export async function addCampaign(campaign) {
    const contract = getContract();

    // Enviar requisição para a blockchain
    return contract.methods.addCampaign(campaign.title, campaign.description, campaign.videoUrl, campaign.imageUrl).send({ from: localStorage.getItem("wallet") })
}

export async function getLastCampaignId() {
    const contract = getContract();
    return contract.methods.nextId().call();
}

export async function getCampaign(id) {
    const contract = getContract();
    return contract.methods.campaigns(id).call();   
}

export async function donate(id, donation) {
    await doLogin();
    const contract = getContract();
    return contract.methods.donate(id).send({ from: localStorage.getItem("wallet"), value: Web3.utils.toWei(donation, "ether") });
}