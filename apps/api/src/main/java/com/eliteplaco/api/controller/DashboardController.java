package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.VueGlobaleDTO;
import com.eliteplaco.api.service.TableauDeBordService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Endpoint REST du Module 4 (tableau de bord global). */
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final TableauDeBordService tableauDeBordService;
    public DashboardController(TableauDeBordService tableauDeBordService) {
        this.tableauDeBordService = tableauDeBordService;
    }

    @GetMapping
    public VueGlobaleDTO vueGlobale() {
        return tableauDeBordService.calculerVueGlobale();
    }
}
