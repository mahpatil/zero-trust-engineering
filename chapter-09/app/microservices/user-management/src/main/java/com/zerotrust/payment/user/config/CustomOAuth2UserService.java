package com.zerotrust.payment.user.config;

import com.zerotrust.payment.user.model.Role;
import com.zerotrust.payment.user.model.User;
import com.zerotrust.payment.user.repository.RoleRepository;
import com.zerotrust.payment.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Collections;
import java.util.Optional;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private RoleRepository roleRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);
        
        try {
            return processOAuth2User(userRequest, oAuth2User);
        } catch (Exception ex) {
            throw new InternalAuthenticationServiceException(ex.getMessage(), ex.getCause());
        }
    }

    private OAuth2User processOAuth2User(OAuth2UserRequest userRequest, OAuth2User oAuth2User) {
        // Extract user details from OAuth2User
        String email = oAuth2User.getAttribute("email");
        if (!StringUtils.hasText(email)) {
            throw new OAuth2AuthenticationException("Email not found from OAuth2 provider");
        }
        
        Optional<User> userOptional = userRepository.findByEmail(email);
        User user;
        
        if (userOptional.isPresent()) {
            user = userOptional.get();
            // Update existing user with new information from OAuth2 provider
            updateExistingUser(user, oAuth2User);
        } else {
            user = registerNewUser(userRequest, oAuth2User);
        }
        
        return UserPrincipal.create(user, oAuth2User.getAttributes());
    }

    private User registerNewUser(OAuth2UserRequest userRequest, OAuth2User oAuth2User) {
        User user = new User();
        
        user.setGoogleId(oAuth2User.getAttribute("sub"));
        user.setFirstName(oAuth2User.getAttribute("given_name"));
        user.setLastName(oAuth2User.getAttribute("family_name"));
        user.setEmail(oAuth2User.getAttribute("email"));
        user.setEmailVerified(oAuth2User.getAttribute("email_verified"));
        user.setProfilePictureUrl(oAuth2User.getAttribute("picture"));
        
        // Assign default role
        Role userRole = roleRepository.findByName(Role.ERole.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Error: Role is not found."));
        user.setRoles(Collections.singleton(userRole));
        
        return userRepository.save(user);
    }

    private void updateExistingUser(User existingUser, OAuth2User oAuth2User) {
        existingUser.setFirstName(oAuth2User.getAttribute("given_name"));
        existingUser.setLastName(oAuth2User.getAttribute("family_name"));
        existingUser.setProfilePictureUrl(oAuth2User.getAttribute("picture"));
        userRepository.save(existingUser);
    }
}