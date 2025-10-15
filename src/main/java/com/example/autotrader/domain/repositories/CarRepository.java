package com.example.autotrader.domain.repositories;

import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.domain.entities.Car;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.Optional;
import java.util.UUID;

public interface CarRepository {
    
    /**
     * Lưu một chiếc xe
     */
    Car save(Car car);
    
    /**
     * Tìm xe theo ID
     */
    Optional<Car> findById(UUID id);
    
    /**
     * Lấy tất cả xe với phân trang
     */
    Page<Car> findAll(Pageable pageable);
    
    /**
     * Tìm xe theo criteria với phân trang
     */
    Page<Car> findByCriteria(CarFilterCriteria criteria, Pageable pageable);
    
    /**
     * Xóa xe theo ID
     */
    void deleteById(UUID id);
    
    /**
     * Kiểm tra xe có tồn tại không
     */
    boolean existsById(UUID id);
    
    /**
     * Đếm tổng số xe
     */
    long count();
}
