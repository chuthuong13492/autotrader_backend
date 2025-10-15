package com.example.autotrader.infrastructure.repositories;

import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.domain.entities.Car;
import com.example.autotrader.domain.repositories.CarRepository;
import com.example.autotrader.infrastructure.specifications.CarSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
@Slf4j
public class CarRepositoryImpl implements CarRepository {
    
    private final CarJpaRepository carJpaRepository;
    
    @Override
    public Car save(Car car) {
        log.info("Saving car");
        return carJpaRepository.save(car);
    }
    
    @Override
    public Optional<Car> findById(UUID id) {
        log.info("Finding car by id: {}", id);
        return carJpaRepository.findById(id);
    }
    
    @Override
    public Page<Car> findAll(Pageable pageable) {
        log.info("Finding all cars with pageable: {}", pageable);
        return carJpaRepository.findAll(pageable);
    }
    
    @Override
    public Page<Car> findByCriteria(CarFilterCriteria criteria, Pageable pageable) {
        log.info("Finding cars by criteria: {}", criteria);
        return carJpaRepository.findAll(CarSpecification.filterByCriteria(criteria), pageable);
    }
    
    @Override
    public void deleteById(UUID id) {
        log.info("Deleting car by id: {}", id);
        carJpaRepository.deleteById(id);
    }
    
    @Override
    public boolean existsById(UUID id) {
        log.info("Checking if car exists by id: {}", id);
        return carJpaRepository.existsById(id);
    }
    
    @Override
    public long count() {
        log.info("Counting total cars");
        return carJpaRepository.count();
    }
}
