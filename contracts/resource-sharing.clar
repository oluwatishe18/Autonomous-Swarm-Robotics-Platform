;; Resource Sharing Contract

(define-map robot-resources
  { robot-id: uint }
  {
    energy: uint,
    data: (list 10 (string-utf8 100))
  }
)

(define-public (update-resources (robot-id uint) (energy uint) (data (string-utf8 100)))
  (let
    ((resources (default-to { energy: u0, data: (list) } (map-get? robot-resources { robot-id: robot-id }))))
    (ok (map-set robot-resources
      { robot-id: robot-id }
      {
        energy: energy,
        data: (unwrap! (as-max-len? (append (get data resources) data) u10) (err u401))
      }
    ))
  )
)

(define-public (share-energy (from-robot uint) (to-robot uint) (amount uint))
  (let
    ((from-resources (unwrap! (map-get? robot-resources { robot-id: from-robot }) (err u404)))
     (to-resources (unwrap! (map-get? robot-resources { robot-id: to-robot }) (err u404))))
    (asserts! (>= (get energy from-resources) amount) (err u401))
    (map-set robot-resources
      { robot-id: from-robot }
      (merge from-resources { energy: (- (get energy from-resources) amount) })
    )
    (map-set robot-resources
      { robot-id: to-robot }
      (merge to-resources { energy: (+ (get energy to-resources) amount) })
    )
    (ok true)
  )
)

(define-public (share-data (from-robot uint) (to-robot uint) (data (string-utf8 100)))
  (let
    ((from-resources (unwrap! (map-get? robot-resources { robot-id: from-robot }) (err u404)))
     (to-resources (unwrap! (map-get? robot-resources { robot-id: to-robot }) (err u404))))
    (asserts! (< (len (get data to-resources)) u10) (err u401))
    (map-set robot-resources
      { robot-id: to-robot }
      (merge to-resources { data: (unwrap! (as-max-len? (append (get data to-resources) data) u10) (err u401)) })
    )
    (ok true)
  )
)

(define-read-only (get-resources (robot-id uint))
  (map-get? robot-resources { robot-id: robot-id })
)

