### Chapter 9: Container Security

This chapter explores security best practices for containerized applications, covering the entire container lifecycle from build to deployment. It demonstrates how to implement various Zero Trust security principles we've learnt across the book.

## Secure CI/CD Pipeline for Containers

### 1 - Multi-Stage Security Pipeline

[1-sample-pipeline.yaml](1-sample-pipeline.yaml) - Demonstrates a sample GitHub Actions pipeline with security scanning at every stage:

**Pipeline Structure:**

This pipeline implements a "shift-left" security approach, embedding security checks throughout the software development lifecycle (SDLC) rather than treating security as a final gate.

**Pipeline Stages:**

1. **Build and Unit Test**
   - Compiles code and runs unit tests
   - Validates basic functionality before security scanning
   - Language-specific build process

2. **Static Code Analysis (SonarCloud)**
   - Performs static application security testing (SAST)
   - Identifies code quality issues, security vulnerabilities, and code smells
   - Runs after successful build to analyze source code
   - Catches issues like SQL injection, XSS, and insecure configurations early

3. **Software Composition Analysis (JFrog Xray)**
   - Scans dependencies for known vulnerabilities (CVEs)
   - Identifies outdated or insecure third-party libraries
   - Checks for license compliance issues
   - Critical for supply chain security

4. **Build Docker Image**
   - Creates containerized version of the application
   - Pushes image to container registry
   - Uses secure base images and follows container best practices

5. **Artifact Attestation**
   - Generates cryptographic attestation for build artifacts
   - Provides integrity verification and provenance tracking
   - Ensures artifacts haven't been tampered with
   - Implements supply chain security (SLSA framework)

6. **Dynamic Application Security Testing (DAST) with ZAP**
   - Uses OWASP ZAP (Zed Attack Proxy) for runtime security testing
   - Tests running application for vulnerabilities
   - Identifies issues that only appear at runtime
   - Scans deployed service endpoint for common web vulnerabilities

7. **Deploy**
   - Deploys container to target environment
   - Only proceeds if all security checks pass

8. **Functional Tests**
   - Validates application behavior post-deployment
   - Ensures security controls don't break functionality
   - Regression testing in production-like environment

**Zero Trust Implementation:**

- **Continuous Verification:** Every stage validates security before proceeding
- **Automated Security Gates:** Pipeline fails if vulnerabilities exceed thresholds
- **Artifact Integrity:** Attestation ensures build artifacts are authentic
- **Defense in Depth:** Multiple layers of security scanning (SAST, SCA, DAST)
- **Supply Chain Security:** Tracks provenance and validates dependencies

**Pipeline Triggers:**
- Activates on push to `main` branch
- Runs on pull requests to `main` branch
- Ensures all changes undergo security review

**Key Takeaway:** This pipeline embodies "security as code" by automating security checks throughout the CI/CD process. Every commit is validated through multiple security lenses before deployment, ensuring that artefacts are built securely and vulnerabilities are caught early.

---

## 2 - Container Application Security Configuration

### Spring Security with Firebase Authentication

[2-SecurityConfig.java](2-SecurityConfig.java) - Implements authentication and authorization for a containerized Spring Boot microservice:

**Security Configuration:**

This class configures Spring Security's filter chain to protect API endpoints using Firebase authentication tokens.

**Key Components:**

1. **CSRF Protection Disabled:**
   ```java
   .csrf(csrf -> csrf.disable())
   ```
   - Disables Cross-Site Request Forgery protection
   - Common for stateless REST APIs using token-based authentication
   - Note: Only disable CSRF when using stateless authentication (JWT/tokens)

2. **Endpoint Authorization Rules:**
   - **Public Endpoints:** `/api/public/**`
     - Accessible without authentication
     - Suitable for health checks, documentation, or public data
     - Uses `.permitAll()` to allow unauthenticated access

   - **Protected Endpoints:** `/api/protected/**`
     - Requires authentication
     - Users must present valid Firebase token
     - Uses `.authenticated()` to enforce authentication requirement

3. **Custom Authentication Filter:**
   ```java
   .addFilterBefore(new FirebaseAuthenticationFilter(),
       UsernamePasswordAuthenticationFilter.class)
   ```
   - Inserts custom Firebase authentication filter early in the filter chain
   - Validates Firebase JWT tokens from incoming requests
   - Extracts user identity and roles from token claims
   - Runs before standard username/password authentication

**Authentication Flow:**

1. Client sends request with Firebase JWT token (typically in Authorization header)
2. `FirebaseAuthenticationFilter` intercepts the request
3. Filter validates token with Firebase Auth service
4. If valid, extracts user identity and sets authentication context
5. Spring Security evaluates authorization rules based on endpoint
6. Request proceeds to controller if authorized, returns 401/403 if not

**Zero Trust Principles:**

1. **Identity-Based Access:** Every request must present valid identity token
2. **Least Privilege:** Public endpoints are minimal; most require authentication
3. **External Identity Provider:** Leverages Firebase for centralized identity management
4. **Stateless Authentication:** No server-side sessions; each request independently verified
5. **Fine-Grained Authorization:** Path-based access control for different API sections

**Key Takeaway:** This security configuration implements Zero Trust identity verification for containerized applications by requiring authentication for protected endpoints and leveraging a centralized identity provider (Firebase). Every request is independently authenticated, eliminating implicit trust and enabling secure, scalable microservices.
