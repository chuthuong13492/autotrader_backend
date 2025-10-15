package com.example.autotrader;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.example.autotrader")
@EnableJpaRepositories(basePackages = "com.example.autotrader.infrastructure.repositories")
public class AutotraderApplication {
	public static void main(String[] args) {
		SpringApplication.run(AutotraderApplication.class, args);
	}

}
