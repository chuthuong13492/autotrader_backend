package com.example.autotrader.infrastructure.repositories;

import com.example.autotrader.domain.entities.CarListingView;
import com.example.autotrader.domain.repositories.CarListingViewRepository;
import com.example.autotrader.infrastructure.specifications.CarListingViewSpecification;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

/**
 * Infrastructure implementation of CarListingViewRepository
 * 
 * This implementation uses Spring Data JPA with specifications
 * for dynamic query building on the car_listings view.
 * 
 * Performance benefits:
 * - Single query for all car data (vs N+1 queries)
 * - Database view optimization
 * - Dynamic filtering with specifications
 */
@Repository
@RequiredArgsConstructor
public class CarListingViewRepositoryImpl implements CarListingViewRepository {
    
    private final CarListingViewJpaRepository jpaRepository;
    
    @Override
    public Page<CarListingView> findAll(Pageable pageable) {
        // Use default specification (no filters)
        Specification<CarListingView> spec = CarListingViewSpecification.alwaysTrue();
        return jpaRepository.findAll(spec, pageable);
    }
    
    @Override
    public Optional<CarListingView> findById(UUID id) {
        return jpaRepository.findById(id);
    }
    
    @Override
    public long count() {
        // Use default specification (no filters)
        Specification<CarListingView> spec = CarListingViewSpecification.alwaysTrue();
        return jpaRepository.count(spec);
    }
    
    @Override
    public boolean existsById(UUID id) {
        return jpaRepository.existsById(id);
    }
    
    @Override
    public Page<CarListingView> findAll(Specification<CarListingView> spec, Pageable pageable) {
        return jpaRepository.findAll(spec, pageable);
    }
    
    @Override
    public long count(Specification<CarListingView> spec) {
        return jpaRepository.count(spec);
    }
}
