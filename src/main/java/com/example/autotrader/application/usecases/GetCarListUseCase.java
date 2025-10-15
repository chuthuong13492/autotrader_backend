package com.example.autotrader.application.usecases;

import com.example.autotrader.application.dtos.CarDto;
import com.example.autotrader.application.dtos.CarFilterCriteria;
import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.core.usecase.ExecuteUseCase;
import com.example.autotrader.domain.entities.CarListingView;
import com.example.autotrader.domain.repositories.CarListingViewRepository;
import com.example.autotrader.infrastructure.specifications.CarListingViewSpecification;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import com.example.autotrader.core.data.Pagination;

/**
 * Use case to get car listings from car_listings view
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GetCarListUseCase {
    private final CarListingViewRepository carListingViewRepository;
    private final ObjectMapper objectMapper;

    /**
     * Execute search with filters
     * 
     * @param criteria Filter criteria
     * @return Either with Failure or CarListResponseDto
     */
    public Either<Failure, Pagination<CarDto>> execute(CarFilterCriteria criteria) {
        return ExecuteUseCase.execute(
            () -> executeSearch(criteria),
            "GetCarListUseCase.execute",
            "Failed to search cars"
        );
    }
    
    /**
     * Internal method to execute search logic
     */
    private Either<Failure, Pagination<CarDto>> executeSearch(CarFilterCriteria criteria) {
        log.info("Executing GetCarListUseCase with criteria: {}", criteria);

        // Validate criteria
        if (criteria.getMinPrice() != null && criteria.getMaxPrice() != null 
            && criteria.getMinPrice().compareTo(criteria.getMaxPrice()) > 0) {
            return Either.left(Failure.validation(
                "INVALID_PRICE_RANGE",
                "Max price must be greater than min price"
            ));
        }

        // Build pageable with sorting
        Pageable pageable = buildPageable(criteria);

        // Query from car_listings view - SINGLE QUERY!
        // Use specification for dynamic filtering
        Page<CarListingView> carPage = carListingViewRepository.findAll(
            CarListingViewSpecification.filterByCriteria(criteria), 
            pageable
        );

        Pagination<CarDto> response = buildPaginationResponse(carPage);
        
        return Either.right(response);
    }

    private Pageable buildPageable(CarFilterCriteria criteria) {
        Integer page = criteria.getPage();
        Integer size = criteria.getSize();
        
        int pageValue = (page != null) ? page : 0;
        int sizeValue = (size != null) ? size : 20;
        
        Sort sort = buildSort(criteria.getSort());
        
        return PageRequest.of(pageValue, sizeValue, sort);
    }

    private Sort buildSort(String sortOption) {
        if (sortOption == null || sortOption.isEmpty()) {
            sortOption = "relevance";
        }
        
        CarFilterCriteria.SortOption sortEnum = CarFilterCriteria.SortOption.fromValue(sortOption);
        
        return switch (sortEnum) {
            case PRICE_ASC -> Sort.by("price").ascending();
            case PRICE_DESC -> Sort.by("price").descending();
            case YEAR_ASC -> Sort.by("year").ascending();
            case YEAR_DESC -> Sort.by("year").descending();
            case MILEAGE_ASC -> Sort.by("mileage").ascending();
            case MILEAGE_DESC -> Sort.by("mileage").descending();
            default -> Sort.by("createdAt").descending(); // relevance = newest first
        };
    }

            private Pagination<CarDto> buildPaginationResponse(Page<CarListingView> carPage) {
                List<CarDto> carDtos = carPage.getContent().stream()
                        .map(this::convertToDto)
                        .collect(Collectors.toList());
                return Pagination.of(
                        carDtos,
                        carPage.getNumber() + 1, 
                        carPage.getSize(),
                        carPage.getTotalElements()
                );
            }

    /**
     * Convert CarListingView to CarDto
     * All data is already denormalized in the view - no lazy loading needed!
     */
    private CarDto convertToDto(CarListingView view) {
        // Parse badges JSON from view
        List<CarDto.BadgeDto> badgeDtos = parseBadgesJson(view.getBadgesJson());

        return CarDto.builder()
                .id(view.getId())
                .year(view.getYear())
                .mileage(view.getMileage())
                .price(view.getPrice())
                .imageUrl(view.getImageUrl())
                // Denormalized data from view - already joined!
                .makeName(view.getMakeName())
                .modelName(view.getModelName())
                .trimName(view.getTrimName())
                .bodyTypeName(view.getBodyTypeName())
                .bodyTypeIcon(view.getBodyTypeIcon())
                .transmissionType(view.getTransmissionType())
                .conditionName(view.getConditionName())
                .dealerName(view.getDealerName())
                .dealerLocation(view.getDealerLocation())
                .badges(badgeDtos)
                .isFeatured(view.getIsFeatured())
                .isSold(view.getIsSold())
                .viewsCount(view.getViewsCount())
                .createdAt(view.getCreatedAt())
                .build();
    }

    /**
     * Parse badges JSON from database view
     * View returns: [{"id":"uuid","name":"Great Price","color":"#10B981"}]
     */
    private List<CarDto.BadgeDto> parseBadgesJson(String badgesJson) {
        if (badgesJson == null || badgesJson.trim().isEmpty() || badgesJson.equals("[]")) {
            return new ArrayList<>();
        }

        try {
            // Parse JSON array to List of Maps
            List<Map<String, Object>> badgesList = objectMapper.readValue(
                badgesJson, 
                new TypeReference<List<Map<String, Object>>>() {}
            );

            return badgesList.stream()
                .map(badgeMap -> CarDto.BadgeDto.builder()
                    .id(UUID.fromString((String) badgeMap.get("id")))
                    .name((String) badgeMap.get("name"))
                    .color((String) badgeMap.get("color"))
                    .build())
                .collect(Collectors.toList());

        } catch (JsonProcessingException e) {
            log.error("Failed to parse badges JSON: {}", badgesJson, e);
            return new ArrayList<>();
        }
    }
}
