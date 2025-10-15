package com.example.autotrader.infrastructure.specifications;

import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.domain.entities.CarListingView;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

/**
 * JPA Specification for filtering car_listings view
 * 
 * Much simpler than CarSpecification because:
 * - No JOINs needed (view already has all data denormalized)
 * - Direct field access (make_name, model_name, etc.)
 * - Better performance
 */
public class CarListingViewSpecification {
    
    /**
     * Create an always-true specification (no filters)
     * Used for basic findAll operations
     */
    public static Specification<CarListingView> alwaysTrue() {
        return (root, query, criteriaBuilder) -> criteriaBuilder.conjunction();
    }
    
    public static Specification<CarListingView> filterByCriteria(CarFilterCriteria criteria) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();
            
            // Always filter out sold cars
            predicates.add(criteriaBuilder.isFalse(root.get("isSold")));
            
            // Text search in make_name, model_name, trim_name
            // No JOINs needed! Everything is denormalized in the view
            if (criteria.getValue() != null && !criteria.getValue().trim().isEmpty()) {
                String searchPattern = "%" + criteria.getValue().toLowerCase() + "%";
                
                predicates.add(criteriaBuilder.or(
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("makeName")), 
                        searchPattern
                    ),
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("modelName")), 
                        searchPattern
                    ),
                    criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("trimName")), 
                        searchPattern
                    )
                ));
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
            
            // Make filter by name (direct field access, no JOIN!)
            if (criteria.getSelectedMake() != null && !criteria.getSelectedMake().trim().isEmpty()) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("makeName")),
                    criteria.getSelectedMake().toLowerCase()
                ));
            }
            
            // Model filter by name
            if (criteria.getSelectedModel() != null && !criteria.getSelectedModel().trim().isEmpty()) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("modelName")),
                    criteria.getSelectedModel().toLowerCase()
                ));
            }
            
            // Trim filter by name
            if (criteria.getSelectedTrim() != null && !criteria.getSelectedTrim().trim().isEmpty()) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("trimName")),
                    criteria.getSelectedTrim().toLowerCase()
                ));
            }
            
            // Body type filter by names (multiple allowed)
            if (criteria.getSelectedBodyTypes() != null && !criteria.getSelectedBodyTypes().isEmpty()) {
                List<String> lowerCaseBodyTypes = criteria.getSelectedBodyTypes().stream()
                    .map(String::toLowerCase)
                    .collect(java.util.stream.Collectors.toList());
                
                predicates.add(
                    criteriaBuilder.lower(root.get("bodyTypeName")).in(lowerCaseBodyTypes)
                );
            }
            
            // Transmission filter by type name
            if (criteria.getSelectedTransmission() != null 
                && !criteria.getSelectedTransmission().trim().isEmpty()
                && !criteria.getSelectedTransmission().equalsIgnoreCase("All")) {
                predicates.add(criteriaBuilder.equal(
                    criteriaBuilder.lower(root.get("transmissionType")),
                    criteria.getSelectedTransmission().toLowerCase()
                ));
            }
            
            return criteriaBuilder.and(predicates.toArray(Predicate[]::new));
        };
    }
}

