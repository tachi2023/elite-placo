package com.eliteplaco.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entrée de l'API Élite Placo & Déco / PRIMA BTP.
 * Démarre le serveur Spring Boot et active le scan automatique de tous les
 * composants du package com.eliteplaco.api (entity, repository, service,
 * controller, security, dto, exception) — aucune configuration
 * supplémentaire n'est nécessaire tant que tout reste sous ce package.
 */
@SpringBootApplication
public class ElitePlacoApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(ElitePlacoApiApplication.class, args);
    }
}
