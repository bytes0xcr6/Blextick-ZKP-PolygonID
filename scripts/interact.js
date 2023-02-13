async function main() {
  const EventAddress = "0x3797d01e950182d3fA5D03a0985466758B9548c5";
  let eventVerifier = await hre.ethers.getContractAt("Event", EventAddress);

  await eventVerifier.buyTicket(1, { value: 1 });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
