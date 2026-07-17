package com.eliteplaco.api.service;

import org.springframework.stereotype.Service;

/**
 * API de synchronisation par horodatage/versionnage (transfert des seules
 * données modifiées) — voir elite.md §3. La règle de résolution de conflit
 * exacte est un point ouvert (§9) : par défaut "dernière écriture gagne"
 * (last-write-wins) sur le champ de version, à affiner avec le dirigeant.
 *
 * TODO (Phase 6) :
 *   1. recevoirLotClient(List<MouvementFinancierDTO>) — traite les
 *      opérations locales en attente, PAR LOTS (voir elite.md §10.12-A5)
 *      pour permettre une reprise partielle en cas d'interruption réseau.
 *   2. renvoyerDeltaServeur(dateDerniereSyncClient) — ne renvoie que ce qui
 *      a changé côté serveur depuis la dernière synchro du client.
 */
@Service
public class SynchronisationService {
}
