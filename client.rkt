#lang racket

(require json)

(file-stream-buffer-mode (current-output-port) 'none)

(struct ActionSeq (action state) #:transparent)

(define (no-op state) (ActionSeq '() state))
(define (action a state) (ActionSeq (list a) state))

(define (connect)
  (define-values (in out) (tcp-connect "localhost" 9090))
  (file-stream-buffer-mode out 'line)
  (define (disconnect)
    (displayln "disconnecting")
    (close-output-port out))
  (thread
    (lambda ()
      (let loop ([next (no-op (hash))])
        (match-let ([(ActionSeq actions state) next])
          (for-each (lambda (a) (displayln (jsexpr->string a) out))
                    actions)
          (let ([data (read-json in)])
            (if (eof-object? data)
              (disconnect)
              (loop (handle data state))))))))
  disconnect)

(define (handle input state)
  (match (list (hash-ref input 'msgType) (hash-ref input 'data))
    [(list "initialize" data) (action (hash 'key "value") state)]
    [_ (no-op state)]))
