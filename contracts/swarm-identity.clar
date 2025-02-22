;; Swarm Identity Contract

(define-data-var next-robot-id uint u0)

(define-map robots
  { robot-id: uint }
  {
    owner: principal,
    swarm-id: uint,
    capabilities: (list 5 (string-ascii 20)),
    active: bool
  }
)

(define-map swarms
  { swarm-id: uint }
  {
    name: (string-ascii 50),
    members: (list 100 uint)
  }
)

(define-public (register-robot (capabilities (list 5 (string-ascii 20))))
  (let
    ((robot-id (+ (var-get next-robot-id) u1)))
    (var-set next-robot-id robot-id)
    (ok (map-set robots
      { robot-id: robot-id }
      {
        owner: tx-sender,
        swarm-id: u0,
        capabilities: capabilities,
        active: true
      }
    ))
  )
)

(define-public (create-swarm (name (string-ascii 50)))
  (let
    ((swarm-id (+ (var-get next-robot-id) u1)))
    (var-set next-robot-id swarm-id)
    (ok (map-set swarms
      { swarm-id: swarm-id }
      {
        name: name,
        members: (list)
      }
    ))
  )
)

(define-public (join-swarm (robot-id uint) (swarm-id uint))
  (let
    ((robot (unwrap! (map-get? robots { robot-id: robot-id }) (err u404)))
     (swarm (unwrap! (map-get? swarms { swarm-id: swarm-id }) (err u404))))
    (asserts! (is-eq (get owner robot) tx-sender) (err u403))
    (asserts! (< (len (get members swarm)) u100) (err u401))
    (map-set robots
      { robot-id: robot-id }
      (merge robot { swarm-id: swarm-id })
    )
    (map-set swarms
      { swarm-id: swarm-id }
      (merge swarm { members: (unwrap! (as-max-len? (append (get members swarm) robot-id) u100) (err u401)) })
    )
    (ok true)
  )
)

(define-read-only (get-robot (robot-id uint))
  (map-get? robots { robot-id: robot-id })
)

(define-read-only (get-swarm (swarm-id uint))
  (map-get? swarms { swarm-id: swarm-id })
)

