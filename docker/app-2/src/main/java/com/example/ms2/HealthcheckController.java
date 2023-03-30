package com.example.ms2;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.jdbc.core.JdbcTemplate;

@RestController
public class HealthcheckController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

	@GetMapping("/health-check")
	public String index() {
		return "1";
	}

    @GetMapping("/query")
    public String sqlQuery() {
        UUID uuid = (UUID) jdbcTemplate.queryForObject("SELECT UUID()", UUID.class);

        return uuid.toString();
    }
}
