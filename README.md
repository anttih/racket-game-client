A game client skeleton for Reaktor Algo^3
=========================================

First, start a server:

    $ nc -l 9090
    
Then in the Racket REPL:

    > (enter! "client.rkt")
    "client.rkt"> (define stop (connect))
