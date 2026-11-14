const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TicketTrust", function () {
  let ticketTrust, admin, organizer, scanner, buyer, buyer2, outsider;

  beforeEach(async function () {
    [admin, organizer, scanner, buyer, buyer2, outsider] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("TicketTrust");
    ticketTrust = await Factory.deploy(admin.address);
    await ticketTrust.waitForDeployment();
    await ticketTrust.grantOrganizer(organizer.address);
    await ticketTrust.grantScanner(scanner.address);
    await ticketTrust.connect(organizer).registerEvent(1001);
  });

  it("allows an approved organizer to issue a ticket", async function () {
    await ticketTrust.connect(organizer).issueTicket(1, 1001, buyer.address);
    const t = await ticketTrust.getStatus(1);
    expect(t.holder).to.equal(buyer.address);
    expect(t.status).to.equal(1); // Valid
  });

  it("rejects ticket issuance by an unapproved account", async function () {
    await expect(ticketTrust.connect(outsider).issueTicket(2, 1001, buyer.address))
      .to.be.reverted;
  });

  it("allows the current holder to transfer a valid ticket", async function () {
    await ticketTrust.connect(organizer).issueTicket(3, 1001, buyer.address);
    await ticketTrust.connect(buyer).transferTicket(3, buyer2.address);
    const t = await ticketTrust.getStatus(3);
    expect(t.holder).to.equal(buyer2.address);
  });

  it("rejects a transfer by a non-holder", async function () {
    await ticketTrust.connect(organizer).issueTicket(4, 1001, buyer.address);
    await expect(ticketTrust.connect(outsider).transferTicket(4, buyer2.address))
      .to.be.reverted;
  });

  it("allows only a scanner to mark a ticket as used and prevents reuse", async function () {
    await ticketTrust.connect(organizer).issueTicket(5, 1001, buyer.address);
    await expect(ticketTrust.connect(outsider).markUsed(5)).to.be.reverted;
    await ticketTrust.connect(scanner).markUsed(5);
    const t = await ticketTrust.getStatus(5);
    expect(t.status).to.equal(2); // Used
    await expect(ticketTrust.connect(scanner).markUsed(5)).to.be.reverted;
  });

  it("prevents cancelled tickets from being used or transferred", async function () {
    await ticketTrust.connect(organizer).issueTicket(6, 1001, buyer.address);
    await ticketTrust.connect(organizer).cancelTicket(6);
    await expect(ticketTrust.connect(scanner).markUsed(6)).to.be.reverted;
    await expect(ticketTrust.connect(buyer).transferTicket(6, buyer2.address))
      .to.be.reverted;
  });

  it("allows the admin to pause state-changing operations", async function () {
    await ticketTrust.connect(organizer).issueTicket(7, 1001, buyer.address);
    await ticketTrust.pause();
    await expect(ticketTrust.connect(buyer).transferTicket(7, buyer2.address))
      .to.be.reverted;
  });
});
