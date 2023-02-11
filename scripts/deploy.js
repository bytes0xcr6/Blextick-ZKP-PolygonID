async function main() {
  const verifierName = "zkEventTickets";
  const verifierSymbol = "zkTickets";
  const date = "1000000000000000";
  const price = "15";
  const maxSupply = "1000";
  const maxTicketUser = "2";
  const baseURI = "http://";
  const organizer = "0x";
  const Event = await ethers.getContractFactory("Event");
  const event = await Event.deploy(
    verifierName,
    verifierSymbol,
    date,
    price,
    maxSupply,
    maxTicketUser,
    baseURI,
    organizer
  );

  await event.deployed();
  console.log(event, " tx hash:", event.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
