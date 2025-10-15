package com.example.autotrader.presentation.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CarRequestDto {
    
    @NotBlank(message = "Brand không được để trống")
    @Size(max = 50, message = "Brand không được vượt quá 50 ký tự")
    private String brand;
    
    @NotBlank(message = "Model không được để trống")
    @Size(max = 50, message = "Model không được vượt quá 50 ký tự")
    private String model;
    
    @NotNull(message = "Year không được để trống")
    @Min(value = 1900, message = "Year phải lớn hơn 1900")
    @Max(value = 2030, message = "Year phải nhỏ hơn 2030")
    private Integer year;
    
    @NotBlank(message = "Color không được để trống")
    @Size(max = 30, message = "Color không được vượt quá 30 ký tự")
    private String color;
    
    @NotNull(message = "Price không được để trống")
    @DecimalMin(value = "0.0", inclusive = false, message = "Price phải lớn hơn 0")
    @DecimalMax(value = "999999999.99", message = "Price không được vượt quá 999,999,999.99")
    private BigDecimal price;
    
    @Min(value = 0, message = "Mileage phải lớn hơn hoặc bằng 0")
    private Integer mileage;
    
    @Size(max = 20, message = "Fuel type không được vượt quá 20 ký tự")
    private String fuelType;
    
    @Size(max = 20, message = "Transmission không được vượt quá 20 ký tự")
    private String transmission;
    
    @Size(max = 1000, message = "Description không được vượt quá 1000 ký tự")
    private String description;
}
