package com.zerotrust.payment.security.validator;

import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.util.Assert;

/**
 * Validates that the JWT has the expected audience claim.
 * This ensures that tokens are intended for this specific service.
 */
public class AudienceValidator implements OAuth2TokenValidator<Jwt> {
    
    private final String audience;
    
    public AudienceValidator(String audience) {
        Assert.hasText(audience, "audience cannot be empty");
        this.audience = audience;
    }
    
    @Override
    public OAuth2TokenValidatorResult validate(Jwt jwt) {
        if (jwt.getAudience().contains(audience)) {
            return OAuth2TokenValidatorResult.success();
        }
        
        OAuth2Error error = new OAuth2Error("invalid_token", "The required audience '" + audience + "' is missing", null);
        return OAuth2TokenValidatorResult.failure(error);
    }
}
