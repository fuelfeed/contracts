contract;

// use standards::src5::{AccessError, SRC5, State};
// use standards::src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
// use standards::src3::SRC3;
use std::string::String;
use std::storage::storage_string::StorageString;
use std::storage::storage_map::StorageMap;

// Define the B3TRBite contract as a struct
abi FuelFeed {
    #[storage(read, write)]
    fn owner() -> Identity;
    #[storage(read, write)]
    fn token_contract() -> ContractId;
    #[storage(read, write)]
    fn reward_rate() -> u64;
    #[storage(read, write)]
    fn total_submissions() -> u64;
    #[storage(read, write)]
    fn user_donations() -> StorageMap<Identity, Vec<Donation>>;
    #[storage(read, write)]
    fn submission_count() -> StorageMap<Identity, u64>;
}

/// Define the Donation struct
struct Donation {
    food_description: String,
    rewards: u64,
    donation_date: u64,
}

impl FuelFeed for Contract {
    /// Constructor to initialize the contract with the token contract address
    fn new(token_contract: ContractId) -> Self {
        assert(msg_sender() != Identity::default(), "Owner cannot be the zero address");
        Self {
            owner: msg_sender(),
            token_contract,
            reward_rate: 2000,
            total_submissions: 0,
            user_donations: StorageMap::new(),
            submission_count: StorageMap::new(),
        }
    }

    /// Ensure the caller is the contract owner
    fn only_owner() {
        
        assert(storage.owner() == msg_sender(), "Caller is not the owner");
    }

    /// Register a donation
     fn register_donation(participant: Identity, amount: u64, food_description: String) {
        storage.only_owner();
        assert(amount > 0, "Donation: Amount must be greater than 0");

        let reward = (amount * storage.reward_rate()) / 10000;
        let new_donation = Donation {
            food_description,
            donation_date: block.timestamp(),
            rewards: reward,
        };

        let mut participant_donations = self.user_donations().get(&participant).unwrap_or_default();
        participant_donations.push(new_donation);
        storage.user_donations().insert(participant, participant_donations);
let count = storage.submission_count.get(participant).unwrap_or(0);
storage.submission_count.insert(participant, count + 1);
       storage.total_submissions += 1;
    }

    /// Reward the donator with tokens
     fn reward_donator(donator: Identity, reward: u64) {
        storage.only_owner();
        assert(reward > 0, "Reward must be greater than 0");

        // Example placeholder for transferring tokens, replace with actual token contract logic.
        // Call to transfer function on the token contract would look something like this:
        // TokenContract::transfer(self.token_contract(), donator, reward);
    }

    /// Get the donation list for a participant
     fn get_donations(participant: Identity) -> Vec<Donation> {
        storage.user_donations().get(&participant).unwrap_or_default()
    }

    /// Set the token contract address
     fn set_token(token_contract: ContractId) {
        storage.only_owner(); // Call only_owner to ensure the caller is the owner
        storage.token_contract = token_contract; // Update the token contract address
    }
}

