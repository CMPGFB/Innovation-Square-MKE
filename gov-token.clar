(define-constant token-name "Innovation Square Governance Token")
(define-constant token-symbol "ISGT")
(define-constant renewal-period uint 525600)

(define-data-var total-supply uint u0)
(define-data-var proposal-count uint u0)
(define-data-var director principal tx-sender)

(define-map balances { account: principal } { balance: uint })
(define-map lease-records { nft-id: uint }
  {
    owner: principal,
    last-renewal: uint,
    renewal-fee: uint,
    delegated-to: (optional principal)
  })

(define-map proposals
  { id: uint }
  {
    description: (string-ascii 256),
    vote-count: uint,
    end-time: uint,
    executed: bool
  }
)
(define-map proposal-votes { proposal-id: uint, voter: principal } bool)

;; =========================== HELPERS ===========================

(define-read-only (is-director (caller principal))
  (ok (is-eq caller (var-get director)))
)

(define-read-only (is-valid-nft-holder (caller principal))
  (let loop ((i u1))
    (if (> i (var-get total-supply))
        (ok false)
        (let ((record (map-get? lease-records { nft-id: i })))
          (match record r
            (if (and (is-eq (get owner r) caller)
                     (<= (block-height) (+ (get last-renewal r) renewal-period)))
                (ok true)
                (loop (+ i u1))
            )
            (loop (+ i u1))
          )
        )
  )
)

;; =========================== TOKEN LOGIC ===========================

(define-public (mint (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get director)) (err u100))
    (var-set total-supply (+ (var-get total-supply) amount))
    (map-set balances { account: recipient }
      { balance: (+ (get balance (default-to { balance: u0 } (map-get? balances { account: recipient }))) amount) })
    (ok true)
  )
)

(define-public (transfer (recipient principal) (amount uint))
  (let ((sender-bal (default-to { balance: u0 } (map-get? balances { account: tx-sender }))))
    (begin
      (asserts! (>= (get balance sender-bal) amount) (err u101))
      (map-set balances { account: tx-sender } { balance: (- (get balance sender-bal) amount) })
      (let ((recipient-bal (default-to { balance: u0 } (map-get? balances { account: recipient }))))
        (map-set balances { account: recipient } { balance: (+ (get balance recipient-bal) amount) }))
      (ok true)
    )
  )
)

;; =========================== GOVERNANCE ===========================

(define-public (create-proposal (desc (string-ascii 256)) (duration uint))
  (begin
    (asserts! (is-eq tx-sender (var-get director)) (err u102))
    (let ((new-id (+ (var-get proposal-count) u1)) (end-time (+ (block-height) duration)))
      (begin
        (var-set proposal-count new-id)
        (map-set proposals { id: new-id }
          { description: desc, vote-count: u0, end-time: end-time, executed: false })
        (ok new-id)
      )
    )
  )
)

(define-public (vote (proposal-id uint))
  (begin
    (asserts! (is-none (map-get? proposal-votes { proposal-id: proposal-id, voter: tx-sender })) (err u103))
    (match (is-valid-nft-holder tx-sender)
      true =>
        (let ((p (map-get? proposals { id: proposal-id })))
          (match p proposal =>
            (begin
              (asserts! (< (block-height) (get end-time proposal)) (err u104))
              (let ((voter-bal (default-to { balance: u0 } (map-get? balances { account: tx-sender }))))
                (map-set proposals { id: proposal-id }
                  {
                    description: (get description proposal),
                    vote-count: (+ (get vote-count proposal) (get balance voter-bal)),
                    end-time: (get end-time proposal),
                    executed: (get executed proposal)
                  })
                (map-set proposal-votes { proposal-id: proposal-id, voter: tx-sender } true)
                (ok true)
              )
            )
            none => (err u105)
          )
      false => (err u106)
    )
  )
)

(define-public (execute-proposal (proposal-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get director)) (err u107))
    (let ((p (map-get? proposals { id: proposal-id })))
      (match p proposal =>
        (begin
          (asserts! (>= (block-height) (get end-time proposal)) (err u108))
          (asserts! (not (get executed proposal)) (err u109))
          (map-set proposals { id: proposal-id }
            {
              description: (get description proposal),
              vote-count: (get vote-count proposal),
              end-time: (get end-time proposal),
              executed: true
            })
          (ok true)
        )
        none => (err u110)
      )
    )
  )
)

(define-read-only (get-balance (who principal))
  (ok (get balance (default-to { balance: u0 } (map-get? balances { account: who }))))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-proposal (proposal-id uint))
  (let ((p (map-get? proposals { id: proposal-id })))
    (match p proposal => (ok proposal) none => (err u111))
  )
)
