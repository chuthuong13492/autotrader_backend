package com.example.autotrader.infrastructure.repositories;

import com.example.autotrader.domain.entities.Car;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CarJpaRepository extends JpaRepository<Car, UUID>, JpaSpecificationExecutor<Car> {
    
    /**
     * Tìm xe chưa bán
     */
    List<Car> findByIsSoldFalse();
}
