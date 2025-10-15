package com.example.autotrader.application.usecases;

import com.example.autotrader.application.dtos.CarDto;
import com.example.autotrader.core.data.Either;
import com.example.autotrader.core.data.Failure;
import com.example.autotrader.core.exceptions.ResourceNotFoundException;
import com.example.autotrader.domain.entities.Badge;
import com.example.autotrader.domain.entities.Car;
import com.example.autotrader.domain.repositories.CarRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;

import com.example.autotrader.core.usecase.ExecuteUseCase;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Use case để lấy thông tin chi tiết của một xe
 * Ví dụ sử dụng ExecuteUseCase pattern
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GetCarDetailUseCase {
    
    private final CarRepository carRepository;
    
    public Either<Failure, CarDto> getCarDetail(UUID carId) {
        return ExecuteUseCase.execute(
                () -> {
                    Car car = carRepository.findById(carId)
                            .orElseThrow(() -> new ResourceNotFoundException("Car", carId));
                    return Either.right(convertToDto(car));
                },
                "GetCarDetailUseCase.getCarDetail",
                "Không thể lấy thông tin xe"
        );
    }
    
    
    private CarDto convertToDto(Car car) {
        // Convert badges
        List<CarDto.BadgeDto> badgeDtos = car.getBadges() != null 
            ? car.getBadges().stream()
                .map(this::convertBadgeToDto)
                .collect(Collectors.toList())
            : List.of();

        return CarDto.builder()
                .id(car.getId())
                .year(car.getYear())
                .mileage(car.getMileage())
                .price(car.getPrice())
                .imageUrl(car.getImageUrl())
                .makeName(car.getMake() != null ? car.getMake().getName() : null)
                .modelName(car.getModel() != null ? car.getModel().getName() : null)
                .trimName(car.getTrim() != null ? car.getTrim().getName() : null)
                .bodyTypeName(car.getBodyType() != null ? car.getBodyType().getName() : null)
                .bodyTypeIcon(car.getBodyType() != null ? car.getBodyType().getIcon() : null)
                .transmissionType(car.getTransmission() != null ? car.getTransmission().getType() : null)
                .conditionName(car.getCondition() != null ? car.getCondition().getName() : null)
                .dealerName(car.getDealer() != null ? car.getDealer().getName() : null)
                .dealerLocation(car.getDealer() != null ? car.getDealer().getLocation() : null)
                .badges(badgeDtos)
                .isFeatured(car.getIsFeatured())
                .isSold(car.getIsSold())
                .viewsCount(car.getViewsCount())
                .createdAt(car.getCreatedAt())
                .build();
    }
    
    private CarDto.BadgeDto convertBadgeToDto(Badge badge) {
        return CarDto.BadgeDto.builder()
                .id(badge.getId())
                .name(badge.getName())
                .color(badge.getColor())
                .build();
    }
}
