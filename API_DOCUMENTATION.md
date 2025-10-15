# API Usage Examples - car_listings VIEW Approach

## 🎯 Key Change: Filter by NAMES, not UUIDs!

Vì sử dụng VIEW `car_listings` với data đã **denormalized**, nên API filter theo **TÊN** thay vì UUID.

---

## 📝 API Endpoint

```
GET /api/v1/cars/search
```

### Parameters

| Parameter | Type | Example | Mô tả |
|-----------|------|---------|-------|
| `value` | String | "Toyota" | Tìm kiếm text trong make/model/trim |
| `minPrice` | Number | 20000 | Giá tối thiểu |
| `maxPrice` | Number | 50000 | Giá tối đa |
| `selectedMakes` | String | "Toyota" | **Tên hãng xe** |
| `selectedModels` | String | "Camry" | **Tên dòng xe** |
| `selectedTrims` | String | "LE" | **Tên phiên bản** |
| `selectedBodyTypes` | String CSV | "SUV,Sedan" | **Tên kiểu dáng**, phân tách bằng dấu phẩy |
| `selectedTransmission` | String | "Automatic" | **Loại hộp số**: "Automatic", "Manual", "All" |
| `sort` | String | "price-asc" | Sắp xếp (xem bên dưới) |
| `page` | Number | 0 | Số trang (0-based) |
| `size` | Number | 10 | Số kết quả mỗi trang |

---

## 🔍 Examples

### 1. Search all cars (no filters)

```bash
curl "http://localhost:8080/api/v1/cars/search"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 0;
```

---

### 2. Search by text (in make/model/trim names)

```bash
curl "http://localhost:8080/api/v1/cars/search?value=Toyota"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND (
    LOWER(make_name) LIKE '%toyota%' OR 
    LOWER(model_name) LIKE '%toyota%' OR
    LOWER(trim_name) LIKE '%toyota%'
  )
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 3. Filter by make name

```bash
curl "http://localhost:8080/api/v1/cars/search?selectedMakes=Toyota"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND LOWER(make_name) = 'toyota'
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 4. Filter by make AND model

```bash
curl "http://localhost:8080/api/v1/cars/search?selectedMakes=Toyota&selectedModels=Camry"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND LOWER(make_name) = 'toyota'
  AND LOWER(model_name) = 'camry'
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 5. Filter by price range

```bash
curl "http://localhost:8080/api/v1/cars/search?minPrice=20000&maxPrice=40000"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND price >= 20000 
  AND price <= 40000
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 6. Filter by body types (multiple)

```bash
curl "http://localhost:8080/api/v1/cars/search?selectedBodyTypes=SUV,Sedan"
```

**Note:** Phân tách bằng dấu phẩy, dùng **TÀN** chứ không phải UUID!

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND LOWER(body_type_name) IN ('suv', 'sedan')
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 7. Filter by transmission type

```bash
curl "http://localhost:8080/api/v1/cars/search?selectedTransmission=Automatic"
```

**Values:** `"Automatic"`, `"Manual"`, hoặc `"All"` (không filter)

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND LOWER(transmission_type) = 'automatic'
ORDER BY created_at DESC 
LIMIT 10;
```

---

### 8. Complex filter: Toyota SUVs under $40k, sorted by price

```bash
curl "http://localhost:8080/api/v1/cars/search?\
selectedMakes=Toyota&\
selectedBodyTypes=SUV&\
maxPrice=40000&\
sort=price-asc&\
page=0&\
size=20"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND LOWER(make_name) = 'toyota'
  AND LOWER(body_type_name) = 'suv'
  AND price <= 40000
ORDER BY price ASC 
LIMIT 20 OFFSET 0;
```

---

### 9. Text search + filters + sorting

```bash
curl "http://localhost:8080/api/v1/cars/search?\
value=sport&\
selectedBodyTypes=Sedan,Coupe&\
selectedTransmission=Manual&\
minPrice=15000&\
maxPrice=35000&\
sort=year-desc&\
page=0&\
size=15"
```

**SQL executed:**
```sql
SELECT * FROM car_listings 
WHERE is_sold = false 
  AND (
    LOWER(make_name) LIKE '%sport%' OR 
    LOWER(model_name) LIKE '%sport%' OR
    LOWER(trim_name) LIKE '%sport%'
  )
  AND LOWER(body_type_name) IN ('sedan', 'coupe')
  AND LOWER(transmission_type) = 'manual'
  AND price BETWEEN 15000 AND 35000
ORDER BY year DESC 
LIMIT 15;
```

---

## 🎨 Sort Options

| Value | Mô tả | SQL |
|-------|-------|-----|
| `relevance` | Mới nhất trước (mặc định) | `ORDER BY created_at DESC` |
| `price-asc` | Giá tăng dần | `ORDER BY price ASC` |
| `price-desc` | Giá giảm dần | `ORDER BY price DESC` |
| `year-asc` | Năm tăng dần | `ORDER BY year ASC` |
| `year-desc` | Năm giảm dần | `ORDER BY year DESC` |
| `mileage-asc` | Km đi tăng dần | `ORDER BY mileage ASC` |
| `mileage-desc` | Km đi giảm dần | `ORDER BY mileage DESC` |

---

## 📊 Available Filter Values

### Make Names (selectedMakes)
From database: `SELECT DISTINCT make_name FROM car_listings ORDER BY make_name;`

Examples:
- `"Toyota"`
- `"Honda"`
- `"Ford"`
- `"BMW"`
- `"Hyundai"`
- etc.

### Model Names (selectedModels)
From database: `SELECT DISTINCT model_name FROM car_listings ORDER BY model_name;`

Examples:
- `"Camry"`
- `"Civic"`
- `"F-150"`
- `"X5"`
- etc.

### Body Type Names (selectedBodyTypes)
From database: `SELECT DISTINCT body_type_name FROM car_listings ORDER BY body_type_name;`

Values:
- `"Sedan"`
- `"SUV"`
- `"Hatchback"`
- `"Coupe"`
- `"Truck"`
- `"Wagon"`
- `"Convertible"`

### Transmission Types (selectedTransmission)
Values:
- `"Automatic"`
- `"Manual"`
- `"All"` (không filter)

---

## 🚀 Frontend Integration (TypeScript)

```typescript
interface CarSearchParams {
  value?: string;
  minPrice?: number;
  maxPrice?: number;
  selectedMakes?: string;      // NAME, not UUID!
  selectedModels?: string;     // NAME, not UUID!
  selectedTrims?: string;      // NAME, not UUID!
  selectedBodyTypes?: string[];  // NAMES, not UUIDs!
  selectedTransmission?: string; // NAME
  sort?: string;
  page?: number;
  size?: number;
}

async function searchCars(params: CarSearchParams) {
  const queryParams = new URLSearchParams();
  
  if (params.value) queryParams.append('value', params.value);
  if (params.minPrice) queryParams.append('minPrice', params.minPrice.toString());
  if (params.maxPrice) queryParams.append('maxPrice', params.maxPrice.toString());
  
  // Filter by NAMES
  if (params.selectedMakes) queryParams.append('selectedMakes', params.selectedMakes);
  if (params.selectedModels) queryParams.append('selectedModels', params.selectedModels);
  if (params.selectedTrims) queryParams.append('selectedTrims', params.selectedTrims);
  
  // Body types as comma-separated names
  if (params.selectedBodyTypes?.length) {
    queryParams.append('selectedBodyTypes', params.selectedBodyTypes.join(','));
  }
  
  if (params.selectedTransmission) {
    queryParams.append('selectedTransmission', params.selectedTransmission);
  }
  
  if (params.sort) queryParams.append('sort', params.sort);
  if (params.page !== undefined) queryParams.append('page', params.page.toString());
  if (params.size) queryParams.append('size', params.size.toString());
  
  const response = await fetch(`/api/v1/cars/search?${queryParams}`);
  return response.json();
}

// Example usage
const results = await searchCars({
  selectedMakes: 'Toyota',        // NAME!
  selectedBodyTypes: ['SUV', 'Sedan'],  // NAMES!
  maxPrice: 40000,
  sort: 'price-asc'
});
```