;; Verifiable Credentials Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Maps
(define-map credentials
  { id: uint }
  {
    issuer: principal,
    holder: principal,
    type: (string-ascii 50),
    data: (string-utf8 1000),
    issued-at: uint,
    expires-at: uint,
    revoked: bool
  }
)

(define-data-var credential-id-nonce uint u0)

;; Public Functions
(define-public (issue-credential (holder principal) (type (string-ascii 50)) (data (string-utf8 1000)) (expires-at uint))
  (let
    (
      (credential-id (var-get credential-id-nonce))
    )
    (map-set credentials
      { id: credential-id }
      {
        issuer: tx-sender,
        holder: holder,
        type: type,
        data: data,
        issued-at: block-height,
        expires-at: expires-at,
        revoked: false
      }
    )
    (var-set credential-id-nonce (+ credential-id u1))
    (ok credential-id)
  )
)

(define-public (revoke-credential (credential-id uint))
  (let
    (
      (credential (unwrap! (map-get? credentials { id: credential-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get issuer credential)) err-unauthorized)
    (ok (map-set credentials
      { id: credential-id }
      (merge credential { revoked: true })
    ))
  )
)

(define-read-only (verify-credential (credential-id uint))
  (let
    (
      (credential (unwrap! (map-get? credentials { id: credential-id }) err-not-found))
    )
    (ok {
      valid: (and
        (not (get revoked credential))
        (<= block-height (get expires-at credential))
      ),
      issuer: (get issuer credential),
      holder: (get holder credential),
      type: (get type credential)
    })
  )
)

(define-read-only (get-credential (credential-id uint))
  (ok (unwrap! (map-get? credentials { id: credential-id }) err-not-found))
)

