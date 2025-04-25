(define-constant renewal-period uint 525600)
(define-data-var total-nfts uint 0)
(define-data-var profit-pool uint 0)
(define-data-var director principal tx-sender)

(define-map lease-records { nft-id: uint }
  { owner: principal, last-renewal: uint, renewal-fee: uint, delegated-to: (optional principal) })

(define-public (mint-lease-nft (recipient principal) (initial-fee uint))
  (let ((nft-id (+ (var-get total-nfts) u1)))
    (map-set lease-records { nft-id: nft-id }
      { owner: recipient, last-renewal: (block-height), renewal-fee: initial-fee, delegated-to: none })
    (var-set total-nfts nft-id)
    (ok nft-id)))

(define-public (renew-lease (nft-id uint) (new-fee uint))
  (let ((record (default-to {owner: tx-sender, last-renewal: u0, renewal-fee: u0, delegated-to: none}
                  (map-get? lease-records {nft-id: nft-id})))
        (deadline (+ (get last-renewal record) renewal-period)))
    (begin
      (asserts! (is-eq (get owner record) tx-sender) (err u101))
      (asserts! (<= (block-height) deadline) (err u102))
      (map-set lease-records {nft-id: nft-id}
        { owner: tx-sender, last-renewal: (block-height), renewal-fee: new-fee, delegated-to: (get delegated-to record) })
      (ok true))))

(define-public (reclaim-nft (nft-id uint))
  (let ((record (default-to {owner: tx-sender, last-renewal: u0, renewal-fee: u0, delegated-to: none}
                  (map-get? lease-records {nft-id: nft-id})))
        (deadline (+ (get last-renewal record) renewal-period)))
    (begin
      (asserts! (>= (block-height) deadline) (err u103))
      (asserts! (is-eq tx-sender (var-get director)) (err u104))
      (map-set lease-records {nft-id: nft-id}
        { owner: (var-get director), last-renewal: (block-height), renewal-fee: (get renewal-fee record), delegated-to: none })
      (ok true))))
