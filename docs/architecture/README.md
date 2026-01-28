# Adaptive Guardian  
 **Architecture & API Overview**

 Adaptive Guardian is a distributed, secure, and scalable system for real-time risk assessment and adaptive protection in connected vehicles, combining edge intelligence with federated cloud learning.

 **Last updated:** January 2026

 ---

 ## Table of Contents

 - [Architecture Overview](#architecture-overview)
   - [Principles](#architecture-principles)
   - [System Layers](#system-layers)
   - [Technology Stack](#technology-stack)
 - [API Documentation](#api-documentation)
   - [Base URLs](#base-urls)
   - [Quick Start Example](#quick-start-example)
   - [API Versioning](#api-versioning)
   - [Main Endpoints Overview](#main-endpoints-overview)
 - [Related Documentation](#related-documentation)

 ---

 ## Architecture Overview

 ### Principles

 1. **Modularity**  
    Components are loosely coupled and independently deployable

 2. **Scalability**  
    System scales horizontally at all layers

 3. **Security**  
    Defense in depth with multiple security layers

 4. **Observability**  
    Comprehensive logging, metrics, and tracing

 5. **Resilience**  
    Fault-tolerant with graceful degradation

 ### System Layers

 ```
 ┌─────────────────────────────────────────────────────────────┐
 │                  Cloud Layer (Kubernetes)                   │
 │  ┌──────────────────┐  ┌──────────────────┐  ┌────────────┐  │
 │  │   Federated      │  │  MLOps           │  │  Monitor   │  │
 │  │   Brain          │  │  Orchestrator    │  │  Stack     │  │
 │  └──────────────────┘  └──────────────────┘  └────────────┘  │
 └─────────────────────────────────────────────────────────────┘
                               ↕
 ┌─────────────────────────────────────────────────────────────┐
 │                  Edge Layer (Vehicle)                       │
 │  ┌──────────────────┐  ┌──────────────────┐                 │
 │  │  Risk Scoring    │  │     MILP         │                 │
 │  │  Agent           │  │    Solver        │                 │
 │  └──────────────────┘  └──────────────────┘                 │
 │                                                             │
 │  ┌───────────────────────────────────────────────────────┐  │
 │  │                ECUs & Zonal Controllers               │  │
 │  └───────────────────────────────────────────────────────┘  │
 └─────────────────────────────────────────────────────────────┘
 ```
 - **Cloud Layer**: Handles federated learning, model orchestration, aggregation, and centralized monitoring.
 - **Edge Layer**: Performs low-latency inference, risk scoring, and optimization using lightweight ML models and constraint solvers directly in the vehicle.

 ### Technology Stack

 | Layer       | Technologies                              |
 |-------------|-------------------------------------------|
 | **Edge**    | C++17, TensorFlow Lite, PyTorch (TorchScript) |
 | **Cloud**   | Python, TensorFlow Federated, Kubernetes  |
 | **Storage** | PostgreSQL, Redis, MinIO (object storage) |
 | **Messaging** | Kafka, MQTT                             |
 | **Monitoring** | Prometheus, Grafana                    |

 ---

 ## API Documentation

 API reference for all Adaptive Guardian services.

 ### Base URLs

 | Environment   | URL                                      |
 |---------------|------------------------------------------|
 | Development   | http://localhost:8080                    |
 | Staging       | https://staging-api.adaptive-guardian.com|
 | Production    | https://api.adaptive-guardian.com        |

 ### Quick Start Example

 ```python
 import requests

 # Example: Predict risk score from an ECU
 response = requests.post(
     "http://localhost:8080/api/v1/predict",
     json={
         "ecu_id": "ECU_001",
         "features": {
             "speed": 85.5,
             "acceleration": 1.2,
             "braking": 0.3,
             "steering_angle": 15.0,
             "sensor_anomalies": 0,
             "network_latency_ms": 45
         }
     },
     headers={"Authorization": "Bearer YOUR_TOKEN"}
 )

 print(response.json())
 # Expected response: {"risk_score": 0.78, "risk_level": "HIGH", "confidence": 0.92}
 ```

 ### API Versioning

 All APIs use versioning in the URL path:
 - Current: `/api/v1/`
 - Legacy support: 6 months after new version release

 ### Main Endpoints Overview

 | Endpoint                          | Method | Description                              | Auth Required |
 |-----------------------------------|--------|------------------------------------------|---------------|
 | `/api/v1/predict`                 | POST   | Real-time risk scoring (edge-facing)     | Yes           |
 | `/api/v1/models/aggregate`        | POST   | Federated model aggregation (cloud)      | Yes           |
 | `/api/v1/models/deploy`           | POST   | Trigger model deployment to edge         | Yes           |
 | `/api/v1/models/status`           | GET    | Check model versions and health          | Yes           |
 | `/api/v1/health`                  | GET    | Service health check                     | No            |

For detailed request/response schemas, authentication flows (JWT/OAuth2), error codes, and rate limiting, see the individual endpoint docs:
 - [Edge Agent API](edge-agent-api.md)
 - [Federated Server API](federated-api.md)
 - [MLOps API](mlops-api.md)
 - [Authentication](authentication.md)

 ---

 ## Related Documentation

 - [System Architecture](system-architecture.md)
 - [Data Flow](data-flow.md)
 - [Security Model](security.md)
 - [Component Diagrams](components/)
 - [Deployment Guide](../deployment/README.md)
 - [Threat Model](../security/threat-model.md)

For questions or contributions, contact the core team.
