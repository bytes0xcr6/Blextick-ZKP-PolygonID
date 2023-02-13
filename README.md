# Blextick ZKP - Polygon ID

♾️ This is our repo for the ETHFORALL Hackathon project ♾️

- **Team:** Ethereum Ninjas 🥷
- Smart Contract (Polygon Mumbai): 0xecf178144ccec09417412d66e2ecc8a2841ee228

- Polygon ID Workshop: https://www.youtube.com/watch?v=PNIOt-ii2Xk&list=PLar2Ti_Qchk6aRRWs0gc4yc10yV6b8em4&index=7
- Docs Polygon ID: https://0xpolygonid.github.io/tutorials/verifier/on-chain-verification/overview/

The protocol uses [Hardhat](https://hardhat.org/) as a development environment and Polygon Mumbai testnet as the network.

## Flowchart
![Flow chart](https://user-images.githubusercontent.com/102038261/218479615-b664c0aa-94e2-4546-b55f-8a5a78f0ab6e.jpg)

## Smart contracts

- Events Fabric contract. (Passing requirements from the organizer to create the Event contract)
- Event contract. (NFT tickets to sell to verified users)

## Workflow Organizer 🏟
1. Request Schema OrganizationPass provided by a Official institution.
2. Polygon ID verifies or refuses if the wallet has the OrganizationPass. If verified the company address will be added to the contract as Organizer.
3. The Organizer can call the function createNewEvent from the EventFabric contract & Pass the Event requirements.
4. The new contract will be listed in our Website for the NFT/Ticket sale.
5. The Organizer verifies that the User owns the NFT/Ticket at the Event gate.

## Workflow User 🙋‍♂

1. Request Schema OrganizationPass provided by a Official institution.
<img width="480" alt="e" src="https://user-images.githubusercontent.com/102038261/218482231-f1b56ba9-ecd8-46e2-b3fd-465099ffe33c.png">

2. Access to Blextick website & the user connects his wallet.
3. The website will check in the contract if he has already passed the KYC. (It means he has already shown he passed KYC in Polygon ID  previously)
4. Chooses the event he wants to go.
5. If he is already an user he will be logged in & he will be able to purchase the ticket event. (No KYC verification needed)
6. If he is not an user, a Polygon ID QR code will pop up and he will need to authenticate he has the KYC Schema. Once he verifies he has passed the KYC, he won´t need to user Polygon ID QR again in our platform.

![Imagen de WhatsApp 2023-02-13 a las 14 59 08](https://user-images.githubusercontent.com/102038261/218482469-62d4c803-9ec0-4709-b02f-4f58ac2799d5.jpg)

7. The user can confirm the purchase. The ticket price will be transferred to the contract and the user will get the NFT.


## Polygon ID Wallet setup

1. Download the Polygon ID mobile app on the [Google Play](https://play.google.com/store/apps/details?id=com.polygonid.wallet) or [Apple app store](https://apps.apple.com/us/app/polygon-id/id1629870183)

2. Open the app and set a pin for security

3. Follow the [Issue a Polygon ID claim](https://polygontechnology.notion.site/Issue-yourself-a-KYC-Age-Credential-claim-a06a6fe048c34115a3d22d7d1ea315ea) doc to issue yourself a KYC Age Credential attesting your date of birth.
