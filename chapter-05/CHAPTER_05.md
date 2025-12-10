### Chapter 5: Secure Your Network

This chapter focuses on implementing Zero Trust network security principles, where the network is assumed to be hostile and every network interaction must be authenticated and authorized. It covers service mesh security, API gateway policies, and encryption in transit.

---

## 1 - API Gateway Security with Kong

### Kong Multi-Layer Authentication Policy

[kong-api-policy.yaml](kong-api-policy.yaml) - Implements defense-in-depth security for API access using Kong Gateway, it defines a plugin to perform OAuth2 or JWT validation to ensure that only services with the correct JWT token can access protected resources in Service B. 

**Policy Configuration:**
This configuration secures `service-b` using three layers of authentication and authorization plugins.

**Security Layers:**

1. **JWT Authentication Plugin:**
   - Validates JSON Web Tokens for API requests
   - Uses RSA256 algorithm for signature verification
   - References secrets from Vault (`vault:jwt-secret`) for secure key management
   - Verifies token expiration (`exp` claim)
   - Extracts issuer from `iss` claim

2. **mTLS Authentication Plugin:**
   - Requires client certificate authentication
   - Validates client certificates against trusted CA (`/etc/kong/ca.crt`)
   - `allow_without_client_cert: false` enforces mandatory certificate presentation
   - Adds cryptographic identity verification beyond JWT tokens

3. **Access Control List (ACL) Plugin:**
   - Implements authorization after authentication
   - Whitelists specific service roles (e.g., `service-role`)
   - Ensures only authorized consumers can access the API

4. **Consumer Configuration:**
   - Defines `service-a` as a consumer with JWT credentials
   - Uses RSA public key for JWT verification
   - Links consumer identity to service-to-service communication

**Key Takeaway:** Combining JWT authentication, mTLS, and ACL plugins creates a robust Zero Trust security model for APIs, ensuring that every request is authenticated at multiple levels and explicitly authorized before reaching backend services.

## 2 - Mutual TLS (mTLS) with Istio Service Mesh

### Istio PeerAuthentication Policy

[istio-mtls-policy.yaml](istio-mtls-policy.yaml) - Sample policy within the Istio service mesh to enforce mutual TLS on all applications within a namespace. Istio automatically handles mTLS for encrypted service communication.

**Policy Configuration:**
- **Resource Type:** `PeerAuthentication` - Istio's custom resource for defining authentication requirements
- **Scope:** Applied to a specific namespace, enforcing mTLS for all services within that namespace
- **Mode:** `STRICT` - Requires mutual TLS for all peer-to-peer communication

**Key Takeaway:** Strict mTLS mode ensures that all service-to-service communication within the mesh is authenticated and encrypted, embodying the Zero Trust principle of "never trust, always verify" at the network layer.