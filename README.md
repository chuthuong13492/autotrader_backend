# 🚗 AutoTrader - Modern Car Trading Platform

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)

A modern, high-performance car trading platform built with **Spring Boot 3**, **Clean Architecture**, and **PostgreSQL**. Features advanced search, filtering, and a type-safe error handling system using the **Either pattern**.

## ✨ Features

### 🏗️ Architecture
- **Clean Architecture** with clear separation of concerns
- **Domain-Driven Design** (DDD) principles
- **Repository Pattern** with JPA Specifications
- **Either Pattern** for type-safe error handling
- **Database Views** for optimized read operations

### 🚀 Performance
- **Single Query** for car listings (vs 31+ queries with traditional approach)
- **Database Views** with pre-computed JOINs
- **JPA Specifications** for dynamic filtering
- **Pagination** and **Sorting** support

### 🎯 Core Features
- **Advanced Car Search** with multiple filters
- **Real-time Filtering** by make, model, trim, body type, transmission
- **Price Range** filtering
- **Text Search** across make, model, trim names
- **Featured Cars** highlighting
- **Car Details** with comprehensive information
- **Badge System** for special offers

### 🛡️ Error Handling
- **Type-safe Either pattern** instead of exceptions
- **Specific error codes** and messages
- **Consistent API responses**
- **Automatic HTTP status mapping**

## 🏛️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  - REST Controllers                                         │
│  - Request/Response DTOs                                    │
│  - EitherResponseHelper for clean error handling            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│  - Use Cases (Business Logic)                               │
│  - DTOs for data transfer                                   │
│  - Either<Failure, T> return types                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                           │
│  - Entities                                                 │
│  - Repository Interfaces                                    │
│  - Business Rules                                           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                      │
│  - JPA Repositories                                         │
│  - Database Specifications                                  │
│  - Configuration                                            │
│  - Database Views                                           │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites
- **Java 17+**
- **Maven 3.8+**
- **PostgreSQL 15+**
- **Docker** (optional)

### 1. Clone the Repository
```bash
git clone https://github.com/chuthuong13492/autotrader_backend.git
cd autotrader
```

### 2. Database Setup
```bash
# Create database
createdb autotrader

# Run schema
psql -d autotrader -f database-schema.sql
```

### 3. Configuration
Update `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/autotrader
spring.datasource.username=your_username
spring.datasource.password=your_password
```

### 4. Run the Application
```bash
# Using Maven
./mvnw spring-boot:run

# Or build and run
./mvnw clean package
java -jar target/autotrader-0.0.1-SNAPSHOT.jar
```

### 5. Test the API
```bash
# Health check
curl http://localhost:8080/api/v1/cars/health

# Search cars
curl "http://localhost:8080/api/v1/cars/search?page=0&size=10"
```

## 📚 API Documentation

### Search Cars
```http
GET /api/v1/cars/search
```

**Query Parameters:**
- `value` - Search text (make, model, trim)
- `minPrice` - Minimum price
- `maxPrice` - Maximum price
- `selectedMakes` - Make names (comma-separated)
- `selectedModels` - Model names (comma-separated)
- `selectedTrims` - Trim names (comma-separated)
- `selectedBodyTypes` - Body type names (comma-separated)
- `selectedTransmission` - Transmission type
- `sort` - Sort option (relevance, price-asc, price-desc, year-asc, year-desc, mileage-asc, mileage-desc)
- `page` - Page number (0-based)
- `size` - Page size (1-100)

**Example:**
```bash
curl "http://localhost:8080/api/v1/cars/search?selectedMakes=Toyota,Honda&minPrice=10000&maxPrice=50000&sort=price-asc&page=0&size=20"
```

### Get Car Detail
```http
GET /api/v1/cars/{id}
```

**Example:**
```bash
curl http://localhost:8080/api/v1/cars/550e8400-e29b-41d4-a716-446655440000
```

## 🎯 Either Pattern Usage

### UseCase Example
```java
@Service
public class GetCarDetailUseCase {
    public Either<Failure, CarDto> getCarDetail(UUID id) {
        return ExecuteUseCase.execute(
            () -> {
                Car car = repo.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Car", id));
                return Either.right(convertToDto(car));
            },
            "GetCarDetailUseCase.getCarDetail",
            "Failed to get car detail"
        );
    }
}
```

### Controller Example
```java
@GetMapping("/{id}")
public ResponseEntity<ApiResponse<CarDto>> getCarDetail(@PathVariable UUID id) {
    Either<Failure, CarDto> result = useCase.getCarDetail(id);
    return EitherResponseHelper.toResponse(result, "Get car successfully");
}
```

## 🧪 Testing

### Run Tests
```bash
# All tests
./mvnw test

# Specific test class
./mvnw test -Dtest=GetCarListUseCaseTest

# Integration tests
./mvnw test -Dtest=*IntegrationTest
```

### Test API
```bash
# Using the provided script
chmod +x test-api.sh
./test-api.sh
```

## 🗃️ Database Schema

The application uses a comprehensive PostgreSQL schema with:
- **Normalized tables** for makes, models, trims, body types, etc.
- **Car listings** with relationships
- **car_listings view** for optimized read operations
- **Triggers** for automatic timestamp updates
- **Indexes** for performance

Key tables:
- `makes` - Car manufacturers
- `models` - Car models
- `trims` - Car trim levels
- `body_types` - Vehicle body types
- `transmissions` - Transmission types
- `conditions` - Vehicle conditions
- `dealers` - Car dealers
- `badges` - Special offer badges
- `cars` - Car listings
- `car_badges` - Many-to-many relationship

## 🔧 Development

### Project Structure
```
src/main/java/com/example/autotrader/
├── application/          # Application layer
│   ├── dtos/            # Data Transfer Objects
│   └── usecases/        # Business use cases
├── core/                # Core utilities
│   ├── data/            # Either pattern classes
│   ├── exceptions/      # Custom exceptions
│   ├── usecase/         # ExecuteUseCase utility
│   └── utilities/       # Helper utilities
├── domain/              # Domain layer
│   ├── entities/        # Domain entities
│   └── repositories/    # Repository interfaces
├── infrastructure/      # Infrastructure layer
│   ├── config/          # Configuration
│   ├── repositories/    # JPA implementations
│   └── specifications/  # JPA Specifications
└── presentation/        # Presentation layer
    ├── controllers/     # REST controllers
    └── dtos/           # Request/Response DTOs
```

### Key Components

#### Either Pattern
- `Either<Failure, T>` - Type-safe error handling
- `Failure` - Structured error representation
- `ExecuteUseCase` - Exception to Either conversion
- `EitherResponseHelper` - Clean controller responses

#### Performance Optimizations
- `CarListingView` - Database view entity
- `CarListingViewSpecification` - Optimized filtering
- Single query for listings vs N+1 problem

## 🚀 Performance

### Before (Traditional JPA)
- **31+ queries** for 10 cars with relationships
- N+1 query problem
- Lazy loading issues

### After (Database Views)
- **1 query** for 10 cars with all data
- Pre-computed JOINs
- Optimized read performance

## 📖 Documentation

- [API Documentation](API_DOCUMENTATION.md)
- [Either Pattern Guide](EITHER_PATTERN_GUIDE.md)
- [Database Schema](database-schema.sql)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## 🙏 Acknowledgments

- **Spring Boot** team for the amazing framework
- **PostgreSQL** community for the robust database
- **Clean Architecture** principles by Uncle Bob
- **Either pattern** inspiration from functional programming

## 📞 Support

If you have any questions or need help:
- Open an [Issue](https://github.com/chuthuong13492/autotrader_backend/issues)
- Check the [Documentation](API_DOCUMENTATION.md)
- Review [Examples](EITHER_PATTERN_GUIDE.md)

---
