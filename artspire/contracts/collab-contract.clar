;; Creative Artists Collective Smart Contract
;; Decentralized platform for artists, portfolios, and creative collaborations

;; Constants
(define-constant collective-curator tx-sender)
(define-constant err-curator-only (err u400))
(define-constant err-artist-not-found (err u401))
(define-constant err-artist-exists (err u402))
(define-constant err-invalid-operation (err u403))

;; Data Variables
(define-data-var next-artist-id uint u1)
(define-data-var next-artwork-id uint u1)

;; Data Maps
(define-map artists
  { creator: principal }
  {
    artist-name: (string-ascii 50),
    art-medium: (string-ascii 70),
    artist-statement: (string-ascii 600),
    debut-date: uint
  }
)

(define-map artworks
  { artwork-id: uint }
  {
    creator: principal,
    piece-title: (string-ascii 100),
    medium-type: (string-ascii 80),
    artwork-description: (string-ascii 400),
    authenticated: bool,
    authenticator: (optional principal),
    created-at: uint
  }
)

(define-map critiques
  { critic: principal, critiqued-artist: principal, art-style: (string-ascii 60) }
  {
    critique-text: (string-ascii 350),
    critique-date: uint
  }
)

(define-map artistic-collaborations
  { artist-primary: principal, artist-secondary: principal }
  { collaborating: bool, collaboration-start: uint }
)

;; Public Functions

;; Register as an artist
(define-public (register-artist (artist-name (string-ascii 50)) (art-medium (string-ascii 70)) (artist-statement (string-ascii 600)))
  (let ((creator tx-sender))
    (asserts! (is-none (map-get? artists { creator: creator })) err-artist-exists)
    (map-set artists
      { creator: creator }
      {
        artist-name: artist-name,
        art-medium: art-medium,
        artist-statement: artist-statement,
        debut-date: block-height
      }
    )
    (ok true)
  )
)

;; Update artist profile
(define-public (update-artist-profile (artist-name (string-ascii 50)) (art-medium (string-ascii 70)) (artist-statement (string-ascii 600)))
  (let ((creator tx-sender))
    (asserts! (is-some (map-get? artists { creator: creator })) err-artist-not-found)
    (map-set artists
      { creator: creator }
      {
        artist-name: artist-name,
        art-medium: art-medium,
        artist-statement: artist-statement,
        debut-date: block-height
      }
    )
    (ok true)
  )
)

;; Submit artwork to collective
(define-public (submit-artwork (piece-title (string-ascii 100)) (medium-type (string-ascii 80)) (artwork-description (string-ascii 400)))
  (let 
    (
      (artwork-id (var-get next-artwork-id))
      (creator tx-sender)
    )
    (asserts! (is-some (map-get? artists { creator: creator })) err-artist-not-found)
    (map-set artworks
      { artwork-id: artwork-id }
      {
        creator: creator,
        piece-title: piece-title,
        medium-type: medium-type,
        artwork-description: artwork-description,
        authenticated: false,
        authenticator: none,
        created-at: block-height
      }
    )
    (var-set next-artwork-id (+ artwork-id u1))
    (ok artwork-id)
  )
)

;; Authenticate artwork
(define-public (authenticate-artwork (artwork-id uint) (creator principal))
  (let 
    (
      (artwork (unwrap! (map-get? artworks { artwork-id: artwork-id }) err-artist-not-found))
      (authenticator tx-sender)
    )
    (asserts! (is-eq (get creator artwork) creator) err-invalid-operation)
    (map-set artworks
      { artwork-id: artwork-id }
      (merge artwork { 
        authenticated: true, 
        authenticator: (some authenticator) 
      })
    )
    (ok true)
  )
)

;; Provide artistic critique
(define-public (provide-critique (critiqued-artist principal) (art-style (string-ascii 60)) (critique-text (string-ascii 350)))
  (let ((critic tx-sender))
    (asserts! (is-some (map-get? artists { creator: critic })) err-artist-not-found)
    (asserts! (is-some (map-get? artists { creator: critiqued-artist })) err-artist-not-found)
    (asserts! (not (is-eq critic critiqued-artist)) err-invalid-operation)
    (map-set critiques
      { critic: critic, critiqued-artist: critiqued-artist, art-style: art-style }
      {
        critique-text: critique-text,
        critique-date: block-height
      }
    )
    (ok true)
  )
)

;; Begin artistic collaboration
(define-public (begin-collaboration (collaborator principal))
  (let ((artist tx-sender))
    (asserts! (is-some (map-get? artists { creator: artist })) err-artist-not-found)
    (asserts! (is-some (map-get? artists { creator: collaborator })) err-artist-not-found)
    (asserts! (not (is-eq artist collaborator)) err-invalid-operation)
    (map-set artistic-collaborations
      { artist-primary: artist, artist-secondary: collaborator }
      { collaborating: true, collaboration-start: block-height }
    )
    (map-set artistic-collaborations
      { artist-primary: collaborator, artist-secondary: artist }
      { collaborating: true, collaboration-start: block-height }
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-artist-profile (creator principal))
  (map-get? artists { creator: creator })
)

(define-read-only (get-artwork-details (artwork-id uint))
  (map-get? artworks { artwork-id: artwork-id })
)

(define-read-only (are-collaborating (artist-primary principal) (artist-secondary principal))
  (default-to false (get collaborating (map-get? artistic-collaborations { artist-primary: artist-primary, artist-secondary: artist-secondary })))
)

(define-read-only (get-critique (critic principal) (critiqued-artist principal) (art-style (string-ascii 60)))
  (map-get? critiques { critic: critic, critiqued-artist: critiqued-artist, art-style: art-style })
)

(define-read-only (is-artwork-authenticated (artwork-id uint))
  (match (map-get? artworks { artwork-id: artwork-id })
    artwork (get authenticated artwork)
    false
  )
)

(define-read-only (get-next-artwork-id)
  (var-get next-artwork-id)
)