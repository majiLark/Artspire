# 🎨 Artspire

**Artspire** is a decentralized smart contract-based platform built for creative artists to showcase portfolios, submit artwork, receive authentic critiques, and collaborate with other artists. The contract enables self-sovereign artist identities and curates creative expressions in a trustless environment.

## 🚀 Features

- **Artist Registration**: Creators can register as artists by submitting their name, medium, and artist statement.
- **Artwork Submission**: Registered artists can submit digital descriptions of their art pieces.
- **Artwork Authentication**: Peers or curators can authenticate artworks for provenance and credibility.
- **Critique System**: Artists can provide peer critiques based on artistic style and creator.
- **Collaboration Engine**: Enables two-way artistic collaboration agreements between artists.
- **Read-only Views**: Retrieve artist profiles, artwork details, critique records, and collaboration status.

## 🛠️ Smart Contract Overview

### Constants

- `collective-curator`: Initially set to `tx-sender`, this defines the contract curator.
- Error codes for:
  - Unauthorized curator actions
  - Duplicate or missing artist entries
  - Invalid operations (e.g., self-critique or self-collaboration)

### Data Structures

- **Maps**:
  - `artists`: Stores artist profile data.
  - `artworks`: Tracks artwork metadata and authentication status.
  - `critiques`: Stores critiques provided to other artists.
  - `artistic-collaborations`: Tracks pairwise collaboration agreements.

- **Variables**:
  - `next-artist-id`: Monotonic counter for artist tracking.
  - `next-artwork-id`: Auto-incremented artwork identifier.

## 📚 Public Functions

- `register-artist(...)`  
- `update-artist-profile(...)`  
- `submit-artwork(...)`  
- `authenticate-artwork(...)`  
- `provide-critique(...)`  
- `begin-collaboration(...)`  

## 🔍 Read-only Functions

- `get-artist-profile(...)`
- `get-artwork-details(...)`
- `are-collaborating(...)`
- `get-critique(...)`
- `is-artwork-authenticated(...)`
- `get-next-artwork-id`

## ✅ Use Cases

- Digital art collectives
- NFT or tokenized portfolio registries
- Artistic peer review and mentorship programs
- Decentralized collaboration among creatives
