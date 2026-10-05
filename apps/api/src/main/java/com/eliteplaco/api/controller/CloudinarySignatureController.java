package com.eliteplaco.api.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
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
    public ResponseEntity<Map<String, Object>> signature(@Valid @RequestBody SignatureRequest request) {
        return signer(request.chantierId(), request.type());
    }

    /** Compatibility for the first admin UI version. The folder remains server-controlled. */
    @GetMapping("/cloudinary/signature")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Map<String, Object>> legacySignature(@RequestParam(required = false) Long chantierId,
                                                                 @RequestParam(required = false, defaultValue = "PHOTO") String type) {
        return signer(chantierId == null ? 0L : chantierId, type);
    }

    private ResponseEntity<Map<String, Object>> signer(Long chantierId, String type) {
        if (cloudName.isBlank() || apiKey.isBlank() || apiSecret.isBlank()) {
            return ResponseEntity.status(503).body(Map.of("enabled", false,
                    "message", "Cloudinary n'est pas configure sur cet environnement."));
        }
        String normalizedType = "DOCUMENT".equalsIgnoreCase(type) ? "documents" : "photos";
        String resourceType = "documents".equals(normalizedType) ? "raw" : "image";
        long timestamp = Instant.now().getEpochSecond();
        String folder = "elite-placo/chantiers/" + chantierId + "/" + normalizedType;
        String payload = "folder=" + folder + "&timestamp=" + timestamp;
        return ResponseEntity.ok(Map.of("enabled", true, "cloudName", cloudName, "apiKey", apiKey,
                "timestamp", timestamp, "folder", folder, "resourceType", resourceType,
                "allowedFormats", resourceType.equals("image") ? "jpg,jpeg,png,webp" : "pdf",
                "signature", hmacSha1(payload, apiSecret),
                "uploadUrl", "https://api.cloudinary.com/v1_1/" + cloudName + "/" + resourceType + "/upload"));
    }

    private String hmacSha1(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA1"));
            return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("Impossible de signer la requête Cloudinary", e);
        }
    }

    public record SignatureRequest(@NotNull @Positive Long chantierId, String type) {}
}
