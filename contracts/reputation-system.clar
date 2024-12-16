;; Reputation System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Maps
(define-map reputation-scores
  { user: principal }
  {
    score: int,
    last-updated: uint
  }
)

(define-map reputation-factors
  { factor: (string-ascii 50) }
  { weight: int }
)

;; Public Functions
(define-public (update-reputation (user principal) (factor (string-ascii 50)) (value int))
  (let
    (
      (factor-weight (default-to { weight: 0 } (map-get? reputation-factors { factor: factor })))
      (current-score (default-to { score: 0, last-updated: u0 } (map-get? reputation-scores { user: user })))
      (weighted-value (* value (get weight factor-weight)))
    )
    (ok (map-set reputation-scores
      { user: user }
      {
        score: (+ (get score current-score) weighted-value),
        last-updated: block-height
      }
    ))
  )
)

(define-public (set-factor-weight (factor (string-ascii 50)) (weight int))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set reputation-factors { factor: factor } { weight: weight }))
  )
)

(define-read-only (get-reputation (user principal))
  (ok (unwrap! (map-get? reputation-scores { user: user }) err-not-found))
)

(define-read-only (get-factor-weight (factor (string-ascii 50)))
  (ok (unwrap! (map-get? reputation-factors { factor: factor }) err-not-found))
)

