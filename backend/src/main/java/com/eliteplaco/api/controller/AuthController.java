package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.LoginRequest;
import com.eliteplaco.api.dto.LoginResponse;
import com.eliteplaco.api.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    public AuthController(AuthService authService) { this.authService = authService; }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest requete) {
        return authService.login(requete);
    }

    @PostMapping("/refresh")
    public LoginResponse rafraichir(@RequestBody String refreshToken) {
        return authService.rafraichir(refreshToken);
    }
}
