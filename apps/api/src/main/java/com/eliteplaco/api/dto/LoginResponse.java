package com.eliteplaco.api.dto;

/** jetonAcces : courte durée de vie. jetonRafraichissement : renouvelle jetonAcces. */
public record LoginResponse(
        String jetonAcces,
        String jetonRafraichissement,
        long expireDansSecondes
) {}
