package com.eliteplaco.api.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class CloudinarySignatureController {
    @Value("${CLOUDINARY_CLOUD_NAME:}") private String cloudName;
    @Value("${CLOUDINARY_API_KEY:}") private String apiKey;
    @Value("${CLOUDINARY_API_SECRET:}") private String apiSecret;

    @PostMapping("/medias/signature")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> signature(@RequestBody SignatureRequest request) {
        return signer(request.chantierId(), request.type());
    }

    @GetMapping("/cloudinary/signature")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> legacySignature(
            @RequestParam(required = false) Long chantierId,
            @RequestParam(required = false, defaultValue = "PHOTO") String type) {
        return signer(chantierId, type);
    }

    private ResponseEntity<Map<String, Object>> signer(Long chantierId, String type) {
        if (cloudName.isBlank() || apiKey.isBlank() || apiSecret.isBlank()) {
            return ResponseEntity.status(503).body(Map.of(
                    "enabled", false,
                    "message", "Cloudinary n'est pas configure sur cet environnement."));
        }

        String normalizedType = type == null ? "PHOTO" : type.toUpperCase();
        String resourceType;
        String folder;
        String allowedFormats;
        if ("SITE".equals(normalizedType)) {
            folder = "elite-placo/site";
            resourceType = "image";
            allowedFormats = "jpg,jpeg,png,webp";
        } else {
            if (chantierId == null || chantierId <= 0) {
                return ResponseEntity.badRequest().body(Map.of(
                        "enabled", false,
                        "message", "Un chantierId positif est obligatoire pour une photo ou un document de chantier."));
            }
            if ("DOCUMENT".equals(normalizedType)) {
                folder = chantierFolder(chantierId) + "/documents";
                resourceType = "raw";
                allowedFormats = "pdf";
            } else {
                folder = chantierFolder(chantierId) + "/photos";
                resourceType = "image";
                allowedFormats = "jpg,jpeg,png,webp";
            }
        }

        long timestamp = Instant.now().getEpochSecond();
        String signature = signatureFor(folder, timestamp, allowedFormats, apiSecret);
        return ResponseEntity.ok(Map.of(
                "enabled", true,
                "cloudName", cloudName,
                "apiKey", apiKey,
                "timestamp", timestamp,
                "folder", folder,
                "resourceType", resourceType,
                "allowedFormats", allowedFormats,
                "allowed_formats", allowedFormats,
                "signature", signature,
                "uploadUrl", "https://api.cloudinary.com/v1_1/" + cloudName + "/" + resourceType + "/upload"));
    }

    private String chantierFolder(Long chantierId) {
        return "elite-placo/chantiers/" + chantierId;
    }

    static String signatureFor(String folder, long timestamp, String allowedFormats, String secret) {
        String payload = "allowed_formats=" + allowedFormats
                + "&folder=" + folder
                + "&timestamp=" + timestamp;
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-1");
            return HexFormat.of().formatHex(digest.digest((payload + secret).getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("Impossible de signer la requête Cloudinary", e);
        }
    }

    public record SignatureRequest(Long chantierId, String type) {}
}
