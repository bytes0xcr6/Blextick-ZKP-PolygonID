async function main() {
  const amountToMint = 1;
  const priceTicket = 2;
  const EventAddress = "0xd467b7797059e968cB837a46F98F869687152BbC";
  let eventVerifier = await hre.ethers.getContractAt("Event", EventAddress);

  await eventVerifier.buyTicket(amountToMint, {
    value: amountToMint * priceTicket,
  });

  console.log(`${amountToMint}NFT minted`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
