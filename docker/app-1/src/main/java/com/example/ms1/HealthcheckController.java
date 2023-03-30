package com.example.ms1;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.jdbc.core.JdbcTemplate;

@RestController
public class HealthcheckController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Value("${endpoint.ms2-url}")
    private String ms2Url;

	@GetMapping("/health-check")
	public String index() {
		return "1";
	}

    @GetMapping("/query")
    public String sqlQuery() {
        UUID uuid = (UUID) jdbcTemplate.queryForObject("SELECT UUID()", UUID.class);

        return uuid.toString();
    }

    @GetMapping("/query/ms2")
    public String ms2Query() {
        RestTemplate restTemplate = new RestTemplate();
        String result = restTemplate.getForObject(ms2Url+"/query", String.class);

        return result;
    }
}
