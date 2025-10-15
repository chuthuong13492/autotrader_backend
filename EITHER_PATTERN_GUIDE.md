# Either Pattern with Spring Boot - Best Practices Guide

## 🎯 Why Either Pattern?

Either pattern provides **type-safe error handling** with explicit error flow:

### ✅ Benefits:
1. **Type-safe** - Compiler ensures you handle both success and failure
2. **Explicit** - Error flow is visible in code, not hidden exceptions
3. **Functional** - Compose operations with map, flatMap, fold
4. **Testable** - Easy to test both success and failure cases
5. **Specific** - Different error types with detailed info

### ❌ vs Traditional Exceptions:
```java
// Traditional (hidden error flow)
public CarDto getCar(UUID id) {
    return repo.findById(id)
        .orElseThrow(() -> new NotFoundException(...));  // Exception hidden!
}

// Either (explicit error flow)
public Either<Failure, CarDto> getCar(UUID id) {
    return repo.findById(id)
        .map(car -> Either.right(convertToDto(car)))
        .orElse(Either.left(Failure.notFound(...)));  // Error visible!
}
```

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Controller                          │
│  - Receives request                                         │
│  - Calls UseCase                                            │
│  - Converts Either → ResponseEntity using helper            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                          UseCase                            │
│  - Business logic                                           │
│  - Returns Either<Failure, T>                               │
│  - Wrapped with ExecuteUseCase for exception handling       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      ExecuteUseCase                         │
│  - Catches all exceptions                                   │
│  - Converts to Either<Failure, T>                           │
│  - Provides consistent error handling                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    EitherResponseHelper                     │
│  - Converts Either → ResponseEntity                         │
│  - Maps Failure → HTTP status codes                         │
│  - Builds ApiResponse                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 💻 Code Examples

### 1. Simple UseCase

```java
@Service
@RequiredArgsConstructor
public class GetCarDetailUseCase {
    private final CarRepository carRepository;
    
    public Either<Failure, CarDto> getCarDetail(UUID id) {
        return ExecuteUseCase.execute(
            () -> {
                Car car = carRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Car", id));
                
                CarDto dto = convertToDto(car);
                return Either.right(dto);
            },
            "GetCarDetailUseCase.getCarDetail",
            "Failed to get car detail"
        );
    }
}
```

### 2. Controller (Clean!)

```java
@RestController
@RequiredArgsConstructor
public class CarDetailController {
    private final GetCarDetailUseCase useCase;
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CarDto>> getCarDetail(@PathVariable UUID id) {
        Either<Failure, CarDto> result = useCase.getCarDetail(id);
        
        // One line! Helper handles everything
        return EitherResponseHelper.toResponse(result, "Get car successfully");
    }
}
```

### 3. UseCase with Validation

```java
public Either<Failure, CarListResponseDto> search(CarFilterCriteria criteria) {
    return ExecuteUseCase.execute(
        () -> {
            // Validation
            if (criteria.getMinPrice() != null && criteria.getMaxPrice() != null) {
                if (criteria.getMinPrice().compareTo(criteria.getMaxPrice()) > 0) {
                    return Either.left(Failure.validation(
                        "INVALID_PRICE_RANGE",
                        "Max price must be greater than min price"
                    ));
                }
            }
            
            // Business logic
            Page<Car> cars = repository.findAll(spec, pageable);
            CarListResponseDto dto = buildResponse(cars);
            
            return Either.right(dto);
        },
        "SearchCarsUseCase.search",
        "Failed to search cars"
    );
}
```

### 4. Custom Error Handling

```java
@GetMapping("/premium/{id}")
public ResponseEntity<ApiResponse<CarDto>> getPremiumCar(@PathVariable UUID id) {
    Either<Failure, CarDto> result = useCase.getPremiumCar(id);
    
    // Custom error messages based on failure type
    return EitherResponseHelper.toResponseWithErrorMapper(
        result,
        "Get premium car successfully",
        failure -> {
            if (failure.getErrorCode().equals("NOT_PREMIUM")) {
                return "This car is not available in premium tier";
            }
            return failure.getMessage();
        }
    );
}
```

### 5. Create with 201 Status

```java
@PostMapping
public ResponseEntity<ApiResponse<CarDto>> createCar(@RequestBody CarRequest request) {
    Either<Failure, CarDto> result = useCase.createCar(request);
    
    // Return 201 CREATED on success
    return EitherResponseHelper.toResponse(
        result,
        "Car created successfully",
        HttpStatus.CREATED
    );
}
```

---

## 🎨 Failure Types

```java
// Not Found (404)
Failure.notFound("Car not found");

// Validation Error (400)
Failure.validation("INVALID_INPUT", "Price must be positive");

// Business Logic Error (400)
Failure.business("INSUFFICIENT_STOCK", "Car is out of stock");

// Network Error (503)
Failure.network("Failed to connect to external service");

// Server Error (500)
Failure.server("Internal server error occurred");

// Custom Error
Failure.custom("CUSTOM_CODE", "Custom message", 418);
```

---

## 📊 HTTP Status Code Mapping

```java
Failure.notFound(...)       → 404 NOT_FOUND
Failure.validation(...)     → 400 BAD_REQUEST
Failure.business(...)       → 400 BAD_REQUEST
Failure.unauthorized(...)   → 401 UNAUTHORIZED
Failure.forbidden(...)      → 403 FORBIDDEN
Failure.network(...)        → 503 SERVICE_UNAVAILABLE
Failure.server(...)         → 500 INTERNAL_SERVER_ERROR
```

---

## 🧪 Testing

### Test UseCase

```java
@Test
void testGetCarDetail_Success() {
    // Given
    UUID id = UUID.randomUUID();
    Car car = createMockCar();
    when(repository.findById(id)).thenReturn(Optional.of(car));
    
    // When
    Either<Failure, CarDto> result = useCase.getCarDetail(id);
    
    // Then
    assertTrue(result.isRight());
    result.fold(
        failure -> fail("Should not be failure"),
        carDto -> {
            assertEquals("Toyota", carDto.getMakeName());
        }
    );
}

@Test
void testGetCarDetail_NotFound() {
    // Given
    UUID id = UUID.randomUUID();
    when(repository.findById(id)).thenReturn(Optional.empty());
    
    // When
    Either<Failure, CarDto> result = useCase.getCarDetail(id);
    
    // Then
    assertTrue(result.isLeft());
    result.fold(
        failure -> {
            assertEquals(404, failure.getStatusCode());
            assertTrue(failure.getMessage().contains("not found"));
        },
        carDto -> fail("Should not be success")
    );
}
```

### Test Controller

```java
@Test
void testGetCarDetail_Success() throws Exception {
    // Given
    UUID id = UUID.randomUUID();
    CarDto dto = createMockCarDto();
    when(useCase.getCarDetail(id)).thenReturn(Either.right(dto));
    
    // When & Then
    mockMvc.perform(get("/api/v1/cars/{id}", id))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.success").value(true))
        .andExpect(jsonPath("$.data.makeName").value("Toyota"));
}

@Test
void testGetCarDetail_NotFound() throws Exception {
    // Given
    UUID id = UUID.randomUUID();
    Failure failure = Failure.notFound("Car not found");
    when(useCase.getCarDetail(id)).thenReturn(Either.left(failure));
    
    // When & Then
    mockMvc.perform(get("/api/v1/cars/{id}", id))
        .andExpect(status().isNotFound())
        .andExpect(jsonPath("$.success").value(false))
        .andExpect(jsonPath("$.message").value("Car not found"));
}
```

---

## 🎯 Best Practices

### ✅ DO:

1. **Use ExecuteUseCase wrapper** for consistent error handling
```java
return ExecuteUseCase.execute(
    () -> {
        // business logic
        return Either.right(result);
    },
    "UseCase.method",
    "Error message"
);
```

2. **Use EitherResponseHelper** in controllers
```java
return EitherResponseHelper.toResponse(result, "Success message");
```

3. **Return specific Failure types**
```java
// Good
return Either.left(Failure.validation("INVALID_PRICE", "Price must be positive"));

// Bad
return Either.left(Failure.builder().message("Error").build());
```

4. **Handle validation in UseCase**
```java
if (invalid) {
    return Either.left(Failure.validation(...));
}
```

### ❌ DON'T:

1. **Don't mix Either and exceptions** in same UseCase
```java
// Bad
public Either<Failure, T> method() {
    if (error) {
        throw new RuntimeException();  // ❌ Should return Either.left()
    }
}
```

2. **Don't use try-catch in Controller** (ExecuteUseCase handles it)
```java
// Bad
try {
    Either<Failure, T> result = useCase.execute();
    return EitherResponseHelper.toResponse(result);
} catch (Exception e) {  // ❌ Unnecessary!
    // ...
}
```

3. **Don't create ResponseEntity manually**
```java
// Bad
return result.fold(
    failure -> ResponseEntity.status(...)  // ❌ Use helper!
        .body(ApiResponse.error(...)),
    data -> ResponseEntity.ok(...)
);

// Good
return EitherResponseHelper.toResponse(result, "Success");
```

---

## 🚀 Migration from Exception to Either

### Before (Exception):
```java
// UseCase
public CarDto getCar(UUID id) {
    Car car = repo.findById(id)
        .orElseThrow(() -> new NotFoundException(...));
    return convertToDto(car);
}

// Controller
@GetMapping("/{id}")
public ResponseEntity<ApiResponse<CarDto>> getCar(@PathVariable UUID id) {
    try {
        CarDto dto = useCase.getCar(id);
        return ResponseEntity.ok(ApiResponse.success("OK", dto));
    } catch (NotFoundException e) {
        return ResponseEntity.status(404)
            .body(ApiResponse.error(e.getMessage()));
    }
}
```

### After (Either):
```java
// UseCase
public Either<Failure, CarDto> getCar(UUID id) {
    return ExecuteUseCase.execute(
        () -> {
            Car car = repo.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(...));
            return Either.right(convertToDto(car));
        },
        "GetCarUseCase.getCar",
        "Failed to get car"
    );
}

// Controller
@GetMapping("/{id}")
public ResponseEntity<ApiResponse<CarDto>> getCar(@PathVariable UUID id) {
    Either<Failure, CarDto> result = useCase.getCar(id);
    return EitherResponseHelper.toResponse(result, "Get car successfully");
}
```

**Lines of code:**
- Before: ~15 lines
- After: ~8 lines (47% reduction!)

---

## 📚 Summary

1. **UseCases** return `Either<Failure, T>`
2. **Wrap with ExecuteUseCase** for exception handling
3. **Controllers** use `EitherResponseHelper` for clean code
4. **Failures** are type-safe and specific
5. **Testing** is straightforward

**Result:** Type-safe, explicit, testable error handling! 🎉

