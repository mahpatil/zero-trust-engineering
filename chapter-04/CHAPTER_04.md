### Chapter 4: Secure Your Identities

This chapter explores identity and access management in the context of Zero Trust, where identity becomes the primary security perimeter. It covers authentication, authorization, and implementing fine-grained access controls based on attributes and context.

## Attribute-Based Access Control (ABAC)

### AWS ABAC Policy Example

[abac-policy.json](abac-policy.json) - Demonstrates an AWS IAM policy implementing Attribute-Based Access Control for AWS Secrets Manager:

**Policy Overview:**
This policy showcases how to implement fine-grained access control using resource and principal attributes (tags) rather than traditional role-based access control (RBAC) using a sample ABAC policy within AWS. 

The policy allows principals to create, read, edit, and delete resources, but only when those resources are tagged with the same key-value pairs as the principal. In short, this means that if someone is trying to create a secret, the user’s project, team, and cost center must match that of the resource they are making. This will limit them from creating resources for some other team or project.

**Key Features:**

1. **Tag-Based Access Control:**
   - Grants access to AWS Secrets Manager resources only when principal tags match resource tags
   - Enforces matching on three key attributes: `access-project`, `access-team`, and `cost-center`
   - Users/roles can only access secrets tagged with the same project, team, and cost center as their own tags

2. **Conditional Access:**
   - Uses `StringEquals` conditions to ensure resource tags match principal tags
   - Implements `ForAllValues:StringEquals` to restrict which tags can be applied
   - Uses `StringEqualsIfExists` to validate request tags match principal tags when creating/updating resources

3. **Zero Trust Principles:**
   - Implements least privilege access by limiting resource access based on attributes
   - Prevents lateral movement between projects or teams
   - Ensures users can only manage resources within their authorized scope
   - Enforces consistent tagging strategy for access control and cost allocation



**Key Takeaway:** ABAC provides more scalable and flexible access control than traditional RBAC by using attributes to make access decisions. This aligns with Zero Trust principles by enabling dynamic, context-aware authorization based on identity attributes rather than static role assignments.