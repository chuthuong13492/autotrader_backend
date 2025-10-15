# AutoTrader - Spring Boot Clean Architecture

Dự án AutoTrader được xây dựng theo chuẩn Clean Architecture với Spring Boot và PostgreSQL.

## 🏗️ Cấu trúc Clean Architecture

```
src/main/java/com/example/autotrader/
├── domain/                    # Domain Layer - Business Logic Core
│   ├── entities/             # Domain Entities
│   │   └── Car.java         # Car Entity
│   └── repositories/         # Repository Interfaces
│       └── CarRepository.java
├── application/              # Application Layer - Use Cases
│   ├── dtos/                # Application DTOs
│   │   ├── CarDto.java
│   │   └── CarListResponseDto.java
│   └── usecases/            # Use Case Interfaces & Implementations
│       └── GetCarListUseCase.java
├── infrastructure/          # Infrastructure Layer - External Concerns
│   ├── config/              # Configuration
│   │   ├── ApplicationConfig.java
│   │   └── DataInitializer.java
│   └── repositories/        # Repository Implementations
│       ├── CarRepositoryImpl.java
│       └── CarJpaRepository.java
└── presentation/            # Presentation Layer - Controllers & DTOs
    ├── controllers/         # REST Controllers
    │   ├── CarController.java
    │   └── GlobalExceptionHandler.java
    └── dtos/               # Presentation DTOs
        ├── CarRequestDto.java
        ├── CarResponseDto.java
        └── ApiResponse.java
```

## 🚀 Cài đặt và Chạy

### 1. Khởi động PostgreSQL

```bash
docker run --name my-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=testdb \
  -p 5432:5432 \
  -d postgres
```

### 2. Chạy ứng dụng

```bash
# Maven
./mvnw spring-boot:run

# Hoặc build và chạy JAR
./mvnw clean package
java -jar target/autotrader-0.0.1-SNAPSHOT.jar
```

### 3. Truy cập ứng dụng

- **Base URL**: http://localhost:8080
- **API Documentation**: Swagger UI (nếu có)

## 📚 API Endpoints

### 1. Lấy danh sách tất cả xe

```http
GET /api/v1/cars
```

**Query Parameters:**
- `page` (default: 0): Số trang
- `size` (default: 10): Số lượng xe mỗi trang
- `sortBy` (default: id): Trường sắp xếp
- `sortDir` (default: asc): Hướng sắp xếp (asc/desc)

**Ví dụ:**
```bash
curl "http://localhost:8080/api/v1/cars?page=0&size=5&sortBy=price&sortDir=desc"
```

### 2. Lấy danh sách xe theo brand

```http
GET /api/v1/cars/brand/{brand}
```

**Ví dụ:**
```bash
curl "http://localhost:8080/api/v1/cars/brand/Toyota?page=0&size=10"
```

### 3. Lấy danh sách xe theo khoảng giá

```http
GET /api/v1/cars/price-range?minPrice={minPrice}&maxPrice={maxPrice}
```

**Ví dụ:**
```bash
curl "http://localhost:8080/api/v1/cars/price-range?minPrice=300000000&maxPrice=500000000&page=0&size=10"
```

### 4. Health Check

```http
GET /api/v1/cars/health
```

## 📊 Response Format

Tất cả API đều trả về format chuẩn:

```json
{
  "success": true,
  "message": "Lấy danh sách xe thành công",
  "data": {
    "cars": [
      {
        "id": 1,
        "brand": "Toyota",
        "model": "Camry",
        "year": 2022,
        "color": "White",
        "price": 350000000,
        "mileage": 15000,
        "fuelType": "Gasoline",
        "transmission": "Automatic",
        "description": "Xe Toyota Camry 2022, màu trắng, số tự động, đã chạy 15,000km",
        "isAvailable": true,
        "createdAt": "2024-01-01T10:00:00",
        "updatedAt": "2024-01-01T10:00:00"
      }
    ],
    "totalPages": 1,
    "totalElements": 5,
    "currentPage": 0,
    "pageSize": 10,
    "hasNext": false,
    "hasPrevious": false
  },
  "timestamp": "2024-01-01T10:00:00"
}
```

## 🏛️ Kiến trúc Clean Architecture

### 1. Domain Layer
- **Entities**: Chứa business logic core
- **Repository Interfaces**: Định nghĩa contract cho data access

### 2. Application Layer
- **Use Cases**: Chứa business logic của ứng dụng
- **DTOs**: Data transfer objects cho application layer

### 3. Infrastructure Layer
- **Repository Implementations**: Triển khai data access
- **Configuration**: Cấu hình Spring beans và DI

### 4. Presentation Layer
- **Controllers**: REST API endpoints
- **DTOs**: Request/Response objects cho API

## 🔧 Dependency Injection

Sử dụng Spring's `@Configuration` để cấu hình DI:

```java
@Configuration
@RequiredArgsConstructor
public class ApplicationConfig {
    
    @Bean
    @Primary
    public CarRepository carRepository(CarJpaRepository carJpaRepository) {
        return new CarRepositoryImpl(carJpaRepository);
    }
}
```

## 🛠️ Công nghệ sử dụng

- **Spring Boot 3.5.6**
- **Spring Data JPA**
- **PostgreSQL**
- **Lombok**
- **Spring Validation**
- **Maven**

## 📝 Dữ liệu mẫu

Ứng dụng sẽ tự động tạo 5 xe mẫu khi khởi động lần đầu:
- Toyota Camry 2022
- Honda Civic 2023  
- Ford Focus 2021
- BMW X5 2023
- Mercedes C-Class 2022

## 🔍 Testing

```bash
# Chạy tests
./mvnw test

# Chạy tests với coverage
./mvnw test jacoco:report
```

## 📋 Lưu ý

- Đảm bảo PostgreSQL đang chạy trước khi start ứng dụng
- Port mặc định: 8080
- Database: testdb
- Username/Password: postgres/postgres
