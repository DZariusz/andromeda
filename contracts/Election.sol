pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/ReentrancyGuard.sol";
import "sancus/contracts/Registrations.sol";
import "contracts/AbstractChain.sol";

contract Election is ReentrancyGuard {
  address public registryAddress;
  address public chairperson;
  address public chainAddress;
  mapping(address => Voter) public voters;
  address[] public addresses;
  uint blockNumber;
  mapping(bytes32 => uint256) counts;
  bytes32 public previousRoot;
  bytes32 public root;
  uint256 public startsAt;
  uint256 public endsAt;
  bool public counted;
  bool public revealed;

  struct Voter {
    bool voted;
    bytes32 proposal;
  }

  function Election(
    address _registryAddress,
    address _chainAddress,
    address _chairperson,
    uint _blockNumber,
    bytes32 _previousRoot,
    uint256 _startsAt,
    uint256 _endsAt
  ) {
    registryAddress = _registryAddress;
    chainAddress = _chainAddress;
    chairperson = _chairperson;
    blockNumber = _blockNumber;
    previousRoot = _previousRoot;
    startsAt = _startsAt;
    endsAt = _endsAt;
  }

  function getNumberOfVerifiers() public view returns (uint) {
    return addresses.length;
  }

  function vote(bytes32 _proposal) external nonReentrant {
    require(block.number - 2 == blockNumber); // only allow voting for one block
    Voter sender = voters[msg.sender];
    require(!sender.voted);

    Registrations registry = Registrations(registryAddress);
    var (id, location, created, balance) = registry.verifiers(msg.sender);
    require(created);

    sender.proposal = _proposal;
    sender.voted = true;
    addresses.push(msg.sender);
  }

  function count() external nonReentrant {
    require(msg.sender == chairperson);
    require(block.number - 2 > blockNumber);
    require(!counted);

    bytes32 newRoot;
    uint256 max = 0;

    for (uint256 i = 0; i < addresses.length; i++) {
      Voter voter = voters[addresses[i]];
      counts[voter.proposal] += 1;

      if (counts[voter.proposal] >= max) {
        newRoot = voter.proposal;
        max = counts[voter.proposal];
      }
    }

    root = newRoot;
    counted = true;

    AbstractChain chain = AbstractChain(chainAddress);
    chain.electionCounted(this);
  }
}
