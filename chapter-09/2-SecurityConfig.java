public public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception
{
    http
        .csrf(csrf -> csrf.disable())
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/public/**").permitAll()
            .requestMatchers("/api/protected/**").authenticated()
        )
        .addFilterBefore(new FirebaseAuthenticationFilter(),
                org.springframework.security.web.authentication.
                UsernamePasswordAuthenticationFilter.class);
        return http.build();
}
}
