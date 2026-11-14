Educational project for the course Introduction to Finance. Not a real product, service or investment offer. Do not use with real funds.

# TicketTrust – local prototype

TicketTrust is a course-only Solidity prototype demonstrating organizer-controlled event registration and ticket issuance, holder-authorized transfers, organizer cancellation, scanner-only entry validation, and a pause control.

## Safety and scope
- Use only the local Hardhat development network and generated test accounts.
- Do not deploy to a public mainnet, connect real funds, issue real tickets, or use real personal data.
- The contract stores only a numeric event/ticket reference, holder address, and status. Production identity data and QR secrets would remain off-chain.
- This is a teaching prototype, not audited production software.

## Requirements
Node.js 20+ (Hardhat 2 compatible), npm.

## Setup
```bash
npm install
npx hardhat compile
npx hardhat test
```

## Local deployment
Terminal 1:
```bash
npx hardhat node
```
Terminal 2:
```bash
npx hardhat run scripts/deploy.js --network localhost
```
The deployment address is local and changes when the local chain is reset. Do not publish private keys.

## Tests
The suite checks organizer issuance, unauthorized issuance, valid transfer, rejection of non-holder transfer, scanner authorization and one-time use, cancellation restrictions, and pause behavior.

## Main use case
1. Admin grants organizer and scanner roles.
2. Organizer registers an event and issues a unique ticket to a buyer.
3. Current holder may transfer the ticket to another address while status is Valid.
4. Venue scanner checks the application’s off-chain QR/session token and calls `markUsed`.
5. A second scan is rejected because the ticket is already Used.

## Repository and demo
GitHub repository: (https://github.com/Polarbee-beep/Introduction_to_finance_Final)
Demo video (up to 3 minutes): https://youtu.be/dGJFQltRLJc
The report and title slide must show the same links. The project owner must test each link in a logged-out browser before submission.

## AI and open-source disclosure
OpenZeppelin Contracts is used for AccessControl and Pausable; retain its MIT licence notice and cite the library. ChatGPT (GPT-6) assisted with drafting and routine prototype scaffolding; the team must review, run, understand, and independently validate all code and calculations before submission.
