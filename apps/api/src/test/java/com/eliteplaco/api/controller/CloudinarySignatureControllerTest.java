package com.eliteplaco.api.controller;

import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;

import static org.junit.jupiter.api.Assertions.assertEquals;

class CloudinarySignatureControllerTest {
    @Test
    void signeLesParametresCloudinaryAvecSha1EtSecret() throws Exception {
        String folder = "elite-placo/site";
        long timestamp = 1_735_689_600L;
        String formats = "jpg,jpeg,png,webp";
        String secret = "secret-de-test";
        String payload = "allowed_formats=" + formats + "&folder=" + folder + "&timestamp=" + timestamp;
        String attendu = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-1")
                .digest((payload + secret).getBytes(StandardCharsets.UTF_8)));

        assertEquals(attendu, CloudinarySignatureController.signatureFor(folder, timestamp, formats, secret));
    }
}
