# Institutional Bridge Architecture

## Overview

The `mql5-execution-components` suite is designed to function as the final execution mile within a distributed quantitative trading system. While MetaTrader 5 provides the gateway to brokers, the high-alpha signal generation typically occurs in external environments.

## External Connectivity Layer

To facilitate communication between the MQL5 execution layer and external quantitative models ($Alpha Engines$), the following bridge protocols are supported:

### 1. ZeroMQ (ZMQ) Integration
- **Role**: Asynchronous message passing.
- **Implementation**: MQL5 acts as a `SUB` socket to receive signals from a centralized `PUB` server (Whale Rider).
- **Latency**: Sub-millisecond local latency.

### 2. Named Pipes
- **Role**: Secure, local inter-process communication (IPC).
- **Implementation**: Used for low-overhead connectivity when the Alpha Engine and MetaTrader instance reside on the same Windows host.
- **Advantage**: Higher security and lower overhead compared to TCIP/IP sockets.

## Execution Workflow

1. **Signal Inbound**: The `Alpha Engine` generates a trade signal (JSON/ProtoBuf).
2. **Bridge Translation**: A bridge component validates the signal and pushes it to the MQL5 layer.
3. **MQL5 Reception**: `SkeletonEA` receives the message via the chosen IPC protocol.
4. **Risk Validation**: `NotionalGuard` performs real-time checks on account health and exposure.
5. **Async Execution**: `OrderFlowRouter` dispatches `OrderSendAsync` to the trade server.
6. **Persistence**: Execution results and Retcodes are logged and piped back to the `Alpha Engine` for state synchronization.

## Fail-Safe Mechanisms

- **Watchdog Timer**: Monitoring of the bridge connection to halt trading if the signal feed is interrupted.
- **Emergency Deinit**: Automatic closing of positions or cancellation of pending orders upon detection of critical system failure.
