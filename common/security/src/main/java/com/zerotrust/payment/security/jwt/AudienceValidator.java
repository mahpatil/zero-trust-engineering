package com.zerotrust.payment.security.jwt;

import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.util.Assert;

/**
 * Validator for JWT audience claim to ensure tokens are intended for this service.
 * Part of zero trust implementation - verify every access request.
 */
public class AudienceValidator implements OAuth2TokenValidator<Jwt> {

    private final String audience;
    private final OAuth2Error error = new OAuth2Error(
            "invalid_token",
            "The required audience is missing",
            null
    );

    public AudienceValidator(String audience) {
        Assert.hasText(audience, "audience is required");
        this.audience = audience;
    }

    @Override
    public OAuth2TokenValidatorResult validate(Jwt jwt) {
        if (jwt.getAudience().contains(audience)) {
            return OAuth2TokenValidatorResult.success();
        }
        return OAuth2TokenValidatorResult.failure(error);
    }
}