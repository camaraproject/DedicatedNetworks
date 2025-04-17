```mermaid
stateDiagram-v2
[*] --> REQUESTED: POST /networks
REQUESTED --> RESERVED: Dedicated Network use is confirmed
RESERVED --> ACTIVATED: Dedicated Network ready for use
ACTIVATED --> TERMINATED: Dedicated Network service time expires
```
