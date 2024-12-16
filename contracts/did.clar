;; Decentralized Identifier (DID) Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data Maps
(define-map dids
  { did: (string-ascii 100) }
  {
    owner: principal,
    document: (string-utf8 1000),
    created-at: uint,
    updated-at: uint
  }
)

;; Public Functions
(define-public (create-did (did (string-ascii 100)) (document (string-utf8 1000)))
  (let
    (
      (did-data (map-get? dids { did: did }))
    )
    (asserts! (is-none did-data) err-already-exists)
    (ok (map-set dids
      { did: did }
      {
        owner: tx-sender,
        document: document,
        created-at: block-height,
        updated-at: block-height
      }
    ))
  )
)

(define-public (update-did (did (string-ascii 100)) (document (string-utf8 1000)))
  (let
    (
      (did-data (unwrap! (map-get? dids { did: did }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get owner did-data)) err-owner-only)
    (ok (map-set dids
      { did: did }
      (merge did-data
        {
          document: document,
          updated-at: block-height
        }
      )
    ))
  )
)

(define-read-only (get-did (did (string-ascii 100)))
  (ok (unwrap! (map-get? dids { did: did }) err-not-found))
)

(define-read-only (get-did-owner (did (string-ascii 100)))
  (ok (get owner (unwrap! (map-get? dids { did: did }) err-not-found)))
)

