package com.example.autotrader.infrastructure.specifications;

import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.domain.entities.*;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public class CarSpecification {
    
    @SuppressWarnings("CollectionsToArray")
    public static Specification<Car> filterByCriteria(CarFilterCriteria criteria) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            // Always filter out sold cars
            predicates.add(criteriaBuilder.isFalse(root.get("isSold")));
            
            // Search text filter (in make, model, or trim name)
            if (criteria.getValue() != null && !criteria.getValue().trim().isEmpty()) {
                String searchPattern = "%" + criteria.getValue().toLowerCase() + "%";
                
                Join<Car, Make> makeJoin = root.join("make");
                Join<Car, Model> modelJoin = root.join("model");
                
                Predicate makePredicate = criteriaBuilder.like(
                    criteriaBuilder.lower(makeJoin.get("name")), 
                    searchPattern
                );
                
                Predicate modelPredicate = criteriaBuilder.like(
                    criteriaBuilder.lower(modelJoin.get("name")), 
                    searchPattern
                );
                
                // Include trim if present
                Predicate trimPredicate = criteriaBuilder.and();
                if (root.get("trim") != null) {
                    Join<Car, Trim> trimJoin = root.join("trim");
                    trimPredicate = criteriaBuilder.like(
                        criteriaBuilder.lower(trimJoin.get("name")), 
                        searchPattern
                    );
                }
                
                predicates.add(criteriaBuilder.or(makePredicate, modelPredicate, trimPredicate));
            }
            
            // Price range filter
            if (criteria.getMinPrice() != null) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(
                    root.get("price"), 
                    criteria.getMinPrice()
                ));
            }
            
            if (criteria.getMaxPrice() != null) {
                predicates.add(criteriaBuilder.lessThanOrEqualTo(
                    root.get("price"), 
                    criteria.getMaxPrice()
                ));
            }
            
            // Make filter
            if (criteria.getSelectedMake() != null) {
                Join<Car, Make> makeJoin = root.join("make");
                predicates.add(criteriaBuilder.equal(makeJoin.get("id"), criteria.getSelectedMake()));
            }
            
            // Model filter
            if (criteria.getSelectedModel() != null) {
                Join<Car, Model> modelJoin = root.join("model");
                predicates.add(criteriaBuilder.equal(modelJoin.get("id"), criteria.getSelectedModel()));
            }
            
            // Trim filter
            if (criteria.getSelectedTrim() != null) {
                Join<Car, Trim> trimJoin = root.join("trim");
                predicates.add(criteriaBuilder.equal(trimJoin.get("id"), criteria.getSelectedTrim()));
            }
            
            // Body types filter
            if (criteria.getSelectedBodyTypes() != null && !criteria.getSelectedBodyTypes().isEmpty()) {
                Join<Car, BodyType> bodyTypeJoin = root.join("bodyType");
                predicates.add(bodyTypeJoin.get("id").in(criteria.getSelectedBodyTypes()));
            }
            
            // Transmission filter
            if (criteria.getSelectedTransmission() != null) {
                Join<Car, Transmission> transmissionJoin = root.join("transmission");
                predicates.add(criteriaBuilder.equal(
                    transmissionJoin.get("id"), 
                    criteria.getSelectedTransmission()
                ));
            }
            
            return criteriaBuilder.and(predicates.toArray(Predicate[]::new));
        };
    }
}

