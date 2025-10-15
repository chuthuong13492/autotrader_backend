package com.example.autotrader.infrastructure.config;

import com.example.autotrader.domain.repositories.CarRepository;
import com.example.autotrader.infrastructure.repositories.CarRepositoryImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
@RequiredArgsConstructor
public class ApplicationConfig {
    
    /**
     * Cấu hình Dependency Injection cho CarRepository
     * Sử dụng @Primary để đảm bảo Spring sử dụng implementation này
     */
    @Bean
    @Primary
    public CarRepository carRepository(com.example.autotrader.infrastructure.repositories.CarJpaRepository carJpaRepository) {
        return new CarRepositoryImpl(carJpaRepository);
    }
    
    /**
     * ObjectMapper bean for JSON parsing
     * Used to parse badges JSON from car_listings view
     */
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        // Register JavaTimeModule to handle Java 8 date/time types
        mapper.registerModule(new JavaTimeModule());
        return mapper;
    }
}
