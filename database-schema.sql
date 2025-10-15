-- ============================================
-- AUTOTRADER COMPLETE DATABASE SETUP
-- PostgreSQL Schema + Tất cả 60 cars từ mock-data.ts
-- ============================================

-- Enable UUID extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. DEALERS TABLE (Nhà bán xe)
-- ============================================
CREATE TABLE dealers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    location VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. MAKES TABLE (Hãng xe)
-- ============================================
CREATE TABLE makes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(100),
    logo_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. MODELS TABLE (Dòng xe)
-- ============================================
CREATE TABLE models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    make_id UUID NOT NULL REFERENCES makes(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50), -- Sedan, SUV, etc.
    image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(make_id, name)
);

-- ============================================
-- 4. TRIMS TABLE (Phiên bản xe)
-- ============================================
CREATE TABLE trims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    engine_type VARCHAR(100),
    horsepower INTEGER,
    fuel_economy_city DECIMAL(4,1),
    fuel_economy_highway DECIMAL(4,1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(model_id, name)
);

-- ============================================
-- 5. BODY_TYPES TABLE (Kiểu dáng xe)
-- ============================================
CREATE TABLE body_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    icon VARCHAR(10),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 6. TRANSMISSIONS TABLE (Hộp số)
-- ============================================
CREATE TABLE transmissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL UNIQUE, -- 'Automatic', 'Manual'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 7. CONDITIONS TABLE (Tình trạng xe)
-- ============================================
CREATE TABLE conditions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) NOT NULL UNIQUE, -- 'New', 'Used'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 8. BADGES TABLE (Nhãn đặc biệt)
-- ============================================
CREATE TABLE badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    color VARCHAR(20) DEFAULT '#3B82F6',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. CARS TABLE (Xe chính)
-- ============================================
CREATE TABLE cars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Basic Info
    year INTEGER NOT NULL CHECK (year >= 1900 AND year <= 2030),
    mileage INTEGER NOT NULL CHECK (mileage >= 0),
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(500),
    
    -- Foreign Keys
    make_id UUID NOT NULL REFERENCES makes(id) ON DELETE CASCADE,
    model_id UUID NOT NULL REFERENCES models(id) ON DELETE CASCADE,
    trim_id UUID REFERENCES trims(id) ON DELETE SET NULL,
    body_type_id UUID NOT NULL REFERENCES body_types(id) ON DELETE CASCADE,
    transmission_id UUID NOT NULL REFERENCES transmissions(id) ON DELETE CASCADE,
    condition_id UUID NOT NULL REFERENCES conditions(id) ON DELETE CASCADE,
    dealer_id UUID NOT NULL REFERENCES dealers(id) ON DELETE CASCADE,
    
    -- Metadata
    is_featured BOOLEAN DEFAULT FALSE,
    is_sold BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. CAR_BADGES TABLE (Many-to-Many: Cars <-> Badges)
-- ============================================
CREATE TABLE car_badges (
    car_id UUID NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (car_id, badge_id)
);

-- ============================================
-- 11. FILTER_PRESETS TABLE (Bộ lọc đã lưu)
-- ============================================
CREATE TABLE filter_presets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID, -- NULL for anonymous users
    name VARCHAR(255) NOT NULL,
    
    -- Filter criteria (JSON for flexibility)
    filters JSONB NOT NULL DEFAULT '{}',
    
    -- Metadata
    is_public BOOLEAN DEFAULT FALSE,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 12. SEARCH_HISTORY TABLE (Lịch sử tìm kiếm)
-- ============================================
CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID, -- NULL for anonymous users
    search_query VARCHAR(500),
    filters JSONB DEFAULT '{}',
    results_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Cars table indexes
CREATE INDEX idx_cars_year ON cars(year);
CREATE INDEX idx_cars_price ON cars(price);
CREATE INDEX idx_cars_mileage ON cars(mileage);
CREATE INDEX idx_cars_make_model ON cars(make_id, model_id);
CREATE INDEX idx_cars_dealer ON cars(dealer_id);
CREATE INDEX idx_cars_condition ON cars(condition_id);
CREATE INDEX idx_cars_body_type ON cars(body_type_id);
CREATE INDEX idx_cars_transmission ON cars(transmission_id);
CREATE INDEX idx_cars_created_at ON cars(created_at);
CREATE INDEX idx_cars_featured ON cars(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_cars_sold ON cars(is_sold) WHERE is_sold = FALSE;

-- Composite indexes for common queries
CREATE INDEX idx_cars_search ON cars(year, price, mileage, is_sold);
CREATE INDEX idx_cars_filter ON cars(make_id, model_id, body_type_id, transmission_id, condition_id, is_sold);

-- Models and Trims indexes
CREATE INDEX idx_models_make ON models(make_id);
CREATE INDEX idx_trims_model ON trims(model_id);

-- Search history indexes
CREATE INDEX idx_search_history_user ON search_history(user_id);
CREATE INDEX idx_search_history_created_at ON search_history(created_at);

-- Filter presets indexes
CREATE INDEX idx_filter_presets_user ON filter_presets(user_id);
CREATE INDEX idx_filter_presets_public ON filter_presets(is_public) WHERE is_public = TRUE;

-- ============================================
-- TRIGGERS FOR UPDATED_AT AND DATA VALIDATION
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to validate car make-model-trim consistency
CREATE OR REPLACE FUNCTION validate_car_consistency()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate make-model relationship
    IF NOT EXISTS (
        SELECT 1 FROM models m 
        WHERE m.id = NEW.model_id AND m.make_id = NEW.make_id
    ) THEN
        RAISE EXCEPTION 'Model % does not belong to make %', NEW.model_id, NEW.make_id;
    END IF;
    
    -- Validate model-trim relationship (if trim is provided)
    IF NEW.trim_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM trims t 
        WHERE t.id = NEW.trim_id AND t.model_id = NEW.model_id
    ) THEN
        RAISE EXCEPTION 'Trim % does not belong to model %', NEW.trim_id, NEW.model_id;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
CREATE TRIGGER update_dealers_updated_at BEFORE UPDATE ON dealers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cars_updated_at BEFORE UPDATE ON cars FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_filter_presets_updated_at BEFORE UPDATE ON filter_presets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply validation trigger for cars
CREATE TRIGGER validate_car_consistency_trigger 
    BEFORE INSERT OR UPDATE ON cars 
    FOR EACH ROW EXECUTE FUNCTION validate_car_consistency();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- View for car listings with all related data (sortable version)
CREATE VIEW car_listings AS
SELECT 
    c.id,
    c.year,
    c.mileage,
    c.price,
    c.image_url,
    c.is_featured,
    c.is_sold,
    c.views_count,
    c.created_at,
    
    -- Make info
    mk.name AS make_name,
    
    -- Model info
    m.name AS model_name,
    
    -- Trim info
    t.name AS trim_name,
    
    -- Body type info
    bt.name AS body_type_name,
    bt.icon AS body_type_icon,
    
    -- Transmission info
    trans.type AS transmission_type,
    
    -- Condition info
    cond.name AS condition_name,
    
    -- Dealer info
    d.name AS dealer_name,
    d.location AS dealer_location,
    
    -- Badge info (sortable)
    COALESCE(json_array_length(
        json_agg(
            json_build_object(
                'id', b.id,
                'name', b.name,
                'color', b.color
            )
        ) FILTER (WHERE b.id IS NOT NULL)
    ), 0) AS badge_count,
    
    -- Badge names as array (for searching and filtering)
    COALESCE(
        array_agg(b.name) FILTER (WHERE b.name IS NOT NULL),
        ARRAY[]::text[]
    ) AS badge_names,
    
    -- Badges JSON (for display)
    COALESCE(
        json_agg(
            json_build_object(
                'id', b.id,
                'name', b.name,
                'color', b.color
            )
        ) FILTER (WHERE b.name IS NOT NULL), 
        '[]'::json
    ) AS badges

FROM cars c
LEFT JOIN makes mk ON c.make_id = mk.id
LEFT JOIN models m ON c.model_id = m.id
LEFT JOIN trims t ON c.trim_id = t.id
LEFT JOIN body_types bt ON c.body_type_id = bt.id
LEFT JOIN transmissions trans ON c.transmission_id = trans.id
LEFT JOIN conditions cond ON c.condition_id = cond.id
LEFT JOIN dealers d ON c.dealer_id = d.id
LEFT JOIN car_badges cb ON c.id = cb.car_id
LEFT JOIN badges b ON cb.badge_id = b.id
GROUP BY c.id, mk.name, m.name, t.name, bt.name, bt.icon, trans.type, cond.name, d.name, d.location;

-- View for filter options
CREATE VIEW filter_options AS
SELECT 
    'makes' AS filter_type,
    mk.id AS value,
    mk.name AS label,
    NULL AS parent_value
FROM makes mk

UNION ALL

SELECT 
    'models' AS filter_type,
    m.id AS value,
    m.name AS label,
    m.make_id AS parent_value
FROM models m

UNION ALL

SELECT 
    'trims' AS filter_type,
    t.id AS value,
    t.name AS label,
    t.model_id AS parent_value
FROM trims t

UNION ALL

SELECT 
    'body_types' AS filter_type,
    bt.id AS value,
    bt.name AS label,
    NULL AS parent_value
FROM body_types bt

UNION ALL

SELECT 
    'transmissions' AS filter_type,
    trans.id AS value,
    trans.type AS label,
    NULL AS parent_value
FROM transmissions trans

UNION ALL

SELECT 
    'conditions' AS filter_type,
    cond.id AS value,
    cond.name AS label,
    NULL AS parent_value
FROM conditions cond;

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert basic reference data
INSERT INTO transmissions (type, description) VALUES 
('Automatic', 'Automatic transmission'),
('Manual', 'Manual transmission');

INSERT INTO conditions (name, description) VALUES 
('New', 'Brand new vehicle'),
('Used', 'Previously owned vehicle');

INSERT INTO body_types (name, icon, description) VALUES 
('Sedan', '🚗', 'Four-door passenger car'),
('SUV', '🚙', 'Sport Utility Vehicle'),
('Hatchback', '🚗', 'Compact car with rear door'),
('Coupe', '🏎️', 'Two-door car'),
('Truck', '🚚', 'Pickup truck'),
('Wagon', '🚐', 'Station wagon'),
('Convertible', '🏎️', 'Car with retractable roof');

INSERT INTO badges (name, color, description) VALUES 
('Great Price', '#10B981', 'Excellent value for money'),
('No Accidents', '#3B82F6', 'No accident history'),
('Certified', '#F59E0B', 'Certified pre-owned'),
('Good Price', '#8B5CF6', 'Good value'),
('Hybrid', '#06B6D4', 'Hybrid vehicle'),
('Electric', '#10B981', 'Electric vehicle');

-- Insert sample dealers
INSERT INTO dealers (name, location, phone, email) VALUES 
('San Francisco Toyota', 'San Francisco, CA', '(415) 555-0101', 'info@sftoyota.com'),
('Livermore Honda', 'Livermore, CA', '(925) 555-0102', 'info@livermorehonda.com'),
('Bay Area Motors', 'San Jose, CA', '(408) 555-0103', 'info@bayareamotors.com'),
('Peninsula Auto', 'Palo Alto, CA', '(650) 555-0104', 'info@peninsulaauto.com'),
('Golden Gate Ford', 'San Francisco, CA', '(415) 555-0105', 'info@goldengateford.com'),
('Euro Auto SF', 'San Francisco, CA', '(415) 555-0106', 'info@euroautosf.com'),
('City Kia', 'Oakland, CA', '(510) 555-0107', 'info@citykia.com'),
('Marin Mazda', 'San Rafael, CA', '(415) 555-0108', 'info@marinmazda.com'),
('City Hyundai', 'Oakland, CA', '(510) 555-0109', 'info@cityhyundai.com'),
('Livermore Toyota', 'Livermore, CA', '(925) 555-0110', 'info@livermoretoyota.com'),
('SF EV Center', 'San Francisco, CA', '(415) 555-0111', 'info@sfevcenter.com')
ON CONFLICT (name) DO NOTHING;

-- Insert sample makes
INSERT INTO makes (name, country) VALUES 
('Hyundai', 'South Korea'),
('Toyota', 'Japan'),
('Chevrolet', 'USA'),
('Honda', 'Japan'),
('Subaru', 'Japan'),
('Tesla', 'USA'),
('Ford', 'USA'),
('BMW', 'Germany'),
('Kia', 'South Korea'),
('Mazda', 'Japan'),
('Audi', 'Germany'),
('Volkswagen', 'Germany'),
('Nissan', 'Japan'),
('Mercedes-Benz', 'Germany'),
('Lexus', 'Japan')
ON CONFLICT (name) DO NOTHING;

-- Insert models
INSERT INTO models (make_id, name, category) VALUES 
-- Hyundai models
((SELECT id FROM makes WHERE name = 'Hyundai'), 'Santa Fe', 'SUV'),
((SELECT id FROM makes WHERE name = 'Hyundai'), 'Tucson', 'SUV'),
((SELECT id FROM makes WHERE name = 'Hyundai'), 'Elantra', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Hyundai'), 'Kona', 'SUV'),
((SELECT id FROM makes WHERE name = 'Hyundai'), 'Ioniq 5', 'SUV'),

-- Toyota models
((SELECT id FROM makes WHERE name = 'Toyota'), 'Corolla', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Camry', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'RAV4', 'SUV'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Prius', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Highlander', 'SUV'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'GR Supra', 'Coupe'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Avalon', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Prius Prime', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Sienna', 'Wagon'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Tacoma', 'Truck'),
((SELECT id FROM makes WHERE name = 'Toyota'), 'Corolla Cross', 'SUV'),

-- Chevrolet models
((SELECT id FROM makes WHERE name = 'Chevrolet'), 'Corvette', 'Coupe'),
((SELECT id FROM makes WHERE name = 'Chevrolet'), 'Tahoe', 'SUV'),
((SELECT id FROM makes WHERE name = 'Chevrolet'), 'Bolt EV', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Chevrolet'), 'Camaro', 'Coupe'),
((SELECT id FROM makes WHERE name = 'Chevrolet'), 'Trailblazer', 'SUV'),

-- Honda models
((SELECT id FROM makes WHERE name = 'Honda'), 'Accord', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Honda'), 'Civic', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Honda'), 'Fit', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Honda'), 'CR-V', 'SUV'),
((SELECT id FROM makes WHERE name = 'Honda'), 'Pilot', 'SUV'),
((SELECT id FROM makes WHERE name = 'Honda'), 'HR-V', 'SUV'),

-- Subaru models
((SELECT id FROM makes WHERE name = 'Subaru'), 'Outback', 'Wagon'),
((SELECT id FROM makes WHERE name = 'Subaru'), 'WRX', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Subaru'), 'Crosstrek', 'SUV'),
((SELECT id FROM makes WHERE name = 'Subaru'), 'Forester', 'SUV'),

-- Tesla models
((SELECT id FROM makes WHERE name = 'Tesla'), 'Model 3', 'Sedan'),

-- Ford models
((SELECT id FROM makes WHERE name = 'Ford'), 'F-150', 'Truck'),
((SELECT id FROM makes WHERE name = 'Ford'), 'Mustang', 'Coupe'),
((SELECT id FROM makes WHERE name = 'Ford'), 'Focus', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Ford'), 'Explorer', 'SUV'),
((SELECT id FROM makes WHERE name = 'Ford'), 'Bronco Sport', 'SUV'),
((SELECT id FROM makes WHERE name = 'Ford'), 'Escape', 'SUV'),

-- BMW models
((SELECT id FROM makes WHERE name = 'BMW'), '328i', 'Sedan'),
((SELECT id FROM makes WHERE name = 'BMW'), 'X3', 'SUV'),
((SELECT id FROM makes WHERE name = 'BMW'), 'M340i', 'Sedan'),
((SELECT id FROM makes WHERE name = 'BMW'), 'M2', 'Coupe'),

-- Kia models
((SELECT id FROM makes WHERE name = 'Kia'), 'Soul', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Kia'), 'Sorento', 'SUV'),
((SELECT id FROM makes WHERE name = 'Kia'), 'K5', 'Sedan'),

-- Mazda models
((SELECT id FROM makes WHERE name = 'Mazda'), 'CX-5', 'SUV'),
((SELECT id FROM makes WHERE name = 'Mazda'), '3', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Mazda'), 'MX-5 Miata', 'Coupe'),
((SELECT id FROM makes WHERE name = 'Mazda'), '6', 'Sedan'),

-- Audi models
((SELECT id FROM makes WHERE name = 'Audi'), 'A4', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Audi'), 'Q5', 'SUV'),
((SELECT id FROM makes WHERE name = 'Audi'), 'A3', 'Sedan'),

-- Volkswagen models
((SELECT id FROM makes WHERE name = 'Volkswagen'), 'Golf', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Volkswagen'), 'Tiguan', 'SUV'),

-- Nissan models
((SELECT id FROM makes WHERE name = 'Nissan'), 'Altima', 'Sedan'),
((SELECT id FROM makes WHERE name = 'Nissan'), 'Rogue', 'SUV'),
((SELECT id FROM makes WHERE name = 'Nissan'), 'Leaf', 'Hatchback'),
((SELECT id FROM makes WHERE name = 'Nissan'), 'Maxima', 'Sedan'),

-- Mercedes-Benz models
((SELECT id FROM makes WHERE name = 'Mercedes-Benz'), 'C300', 'Sedan'),

-- Lexus models
((SELECT id FROM makes WHERE name = 'Lexus'), 'RX 350', 'SUV')

ON CONFLICT (make_id, name) DO NOTHING;

-- Insert trims
INSERT INTO trims (model_id, name) VALUES 
-- Hyundai trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Santa Fe'), 'Sport'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Tucson'), 'SEL'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Elantra'), 'SEL'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Kona'), 'N Line'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Ioniq 5'), 'SEL'),

-- Toyota trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla'), 'LE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Camry'), 'SE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'RAV4'), 'XLE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius'), 'LE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Highlander'), 'XLE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'GR Supra'), '3.0'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Avalon'), 'Limited'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius Prime'), 'SE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Sienna'), 'XLE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Tacoma'), 'TRD Sport'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla Cross'), 'LE'),

-- Chevrolet trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Corvette'), 'Stingray'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Tahoe'), 'LT'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Bolt EV'), 'LT'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Camaro'), 'SS'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Trailblazer'), 'LT'),

-- Honda trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Accord'), 'Sport'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Civic'), 'EX'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Fit'), 'EX'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'CR-V'), 'EX'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Pilot'), 'EX-L'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'HR-V'), 'EX'),

-- Subaru trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Outback'), '2.5i'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'WRX'), 'Base'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Crosstrek'), 'Premium'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Forester'), 'Limited'),

-- Tesla trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Tesla' AND m.name = 'Model 3'), 'Long Range'),

-- Ford trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'F-150'), 'XLT'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Mustang'), 'GT'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Focus'), 'SE'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Explorer'), 'XLT'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Bronco Sport'), 'Badlands'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Escape'), 'Titanium'),

-- BMW trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = '328i'), 'Base'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'X3'), 'xDrive30i'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M340i'), 'xDrive'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M2'), 'Base'),

-- Kia trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Soul'), 'Ex'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Sorento'), 'LX'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'K5'), 'GT-Line'),

-- Mazda trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'CX-5'), 'Touring'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '3'), 'Touring'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'MX-5 Miata'), 'Club'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '6'), 'Grand Touring'),

-- Audi trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A4'), 'Premium'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'Q5'), 'Premium Plus'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A3'), 'Premium'),

-- Volkswagen trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Golf'), 'TSI'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Tiguan'), 'SEL'),

-- Nissan trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Altima'), 'SV'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Rogue'), 'SV'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Leaf'), 'SV'),
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Maxima'), 'SL'),

-- Mercedes-Benz trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mercedes-Benz' AND m.name = 'C300'), 'Base'),

-- Lexus trims
((SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Lexus' AND m.name = 'RX 350'), 'Base')

ON CONFLICT (model_id, name) DO NOTHING;

-- ============================================
-- INSERT ALL 60 CARS FROM MOCK-DATA.TS
-- ============================================

-- Car 1: Hyundai Santa Fe Sport
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2017, 76000, 13588, 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
    (SELECT id FROM makes WHERE name = 'Hyundai'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Santa Fe'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Santa Fe' AND t.name = 'Sport'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'San Francisco Toyota')
);

-- Car 2: Toyota Corolla LE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2025, 3000, 22988, 'https://images2.autotrader.com/hn/c/0c42fbd4da54493bbca94c3efc1ee8c8.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla' AND t.name = 'LE'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'San Francisco Toyota')
);

-- Car 3: Chevrolet Corvette Stingray
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2019, 2000, 49777, 'https://images.unsplash.com/photo-1493238792000-8113da705763',
    (SELECT id FROM makes WHERE name = 'Chevrolet'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Corvette'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Corvette' AND t.name = 'Stingray'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 4: Honda Accord Sport
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2025, 5, 35452, 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Accord'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Accord' AND t.name = 'Sport'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'New'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 5: Toyota Camry SE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2025, 10, 30565, 'https://images2.autotrader.com/hn/c/cb21b15ba4854a68aec864d270feef6f.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Camry'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Camry' AND t.name = 'SE'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'New'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 6: Subaru Outback 2.5i
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2018, 52000, 17990, 'https://images2.autotrader.com/hn/c/5e481a9a5ddb40d3bb40b1c1fa7a1b6f.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Subaru'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Outback'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Outback' AND t.name = '2.5i'),
    (SELECT id FROM body_types WHERE name = 'Wagon'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 7: Tesla Model 3 Long Range
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 12000, 32800, 'https://images2.autotrader.com/hn/c/f494480c3a824b67a0c6e4717d2222ce.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Tesla'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Tesla' AND m.name = 'Model 3'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Tesla' AND m.name = 'Model 3' AND t.name = 'Long Range'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'SF EV Center')
);

-- Car 8: Ford F-150 XLT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 41000, 29950, 'https://images2.autotrader.com/hn/c/2bc0b8d34af44761b8b7e499fd6ba868.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'F-150'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'F-150' AND t.name = 'XLT'),
    (SELECT id FROM body_types WHERE name = 'Truck'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 9: BMW 328i Base
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2016, 69000, 16800, 'https://images2.autotrader.com/hn/c/ffa9e285737d447fa397aea5ed13d062.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'BMW'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = '328i'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = '328i' AND t.name = 'Base'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 10: Kia Soul Ex
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 21000, 16990, 'https://images2.autotrader.com/hn/c/e50aba058fab433b9e4d176cde4d7548.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Kia'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Soul'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Soul' AND t.name = 'Ex'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Kia')
);

-- Car 11: Mazda CX-5 Touring
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 9000, 27990, 'https://images2.autotrader.com/hn/c/0529463a672d4e68a373244eefb2c23a.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Mazda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'CX-5'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'CX-5' AND t.name = 'Touring'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Marin Mazda')
);

-- Car 12: Audi A4 Premium
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2015, 88000, 13990, 'https://images2.autotrader.com/hn/c/09bd2677b7a44eec8bfb353a4a064b0c.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Audi'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A4'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A4' AND t.name = 'Premium'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 13: Honda Civic EX
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2018, 43000, 17500, 'https://images2.autotrader.com/hn/c/9ecc0c1ef9844055852afa01f70364ed.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Civic'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Civic' AND t.name = 'EX'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 14: Toyota RAV4 XLE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2019, 38000, 25990, 'https://images2.autotrader.com/hn/c/871b931df0f347d0bbe88ac1fb402e42.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'RAV4'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'RAV4' AND t.name = 'XLE'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 15: Volkswagen Golf TSI
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 25000, 18990, 'https://images2.autotrader.com/hn/c/9ecc0c1ef9844055852afa01f70364ed.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Volkswagen'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Golf'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Golf' AND t.name = 'TSI'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 16: Ford Mustang GT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2024, 1000, 39990, 'https://images2.autotrader.com/hn/c/21c1ac47bfd940c6b96d55a931eecc77.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Mustang'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Mustang' AND t.name = 'GT'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 17: Nissan Altima SV
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2017, 72000, 12990, 'https://images2.autotrader.com/hn/c/6797347887124fbe99ab5336cf1e0d4e.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Nissan'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Altima'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Altima' AND t.name = 'SV'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 18: Hyundai Tucson SEL
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 14000, 23990, 'https://images2.autotrader.com/hn/c/5d2cf39c3b4d4acc81e9f91c130f841e.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Hyundai'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Tucson'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Tucson' AND t.name = 'SEL'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Hyundai')
);

-- Car 19: Subaru WRX Base
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2016, 64000, 20990, 'https://images2.autotrader.com/hn/c/b634662539504db0867f2546908950c5.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Subaru'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'WRX'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'WRX' AND t.name = 'Base'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 20: Chevrolet Tahoe LT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 23000, 47990, 'https://images2.autotrader.com/hn/c/21c1ac47bfd940c6b96d55a931eecc77.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Chevrolet'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Tahoe'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Tahoe' AND t.name = 'LT'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 21: Honda Fit EX
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2018, 51000, 14990, 'https://images2.autotrader.com/hn/c/5e481a9a5ddb40d3bb40b1c1fa7a1b6f.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Fit'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Fit' AND t.name = 'EX'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 22: Toyota Prius LE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 28000, 21990, 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius' AND t.name = 'LE'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 23: BMW X3 xDrive30i
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 8000, 41990, 'https://images2.autotrader.com/hn/c/6a08e81dd9fc4547b06f413e402e7db5.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'BMW'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'X3'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'X3' AND t.name = 'xDrive30i'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 24: Ford Focus SE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2015, 93000, 8990, 'https://images2.autotrader.com/hn/c/2289cccc880c4840908754b4458afaac.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Focus'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Focus' AND t.name = 'SE'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 25: Kia Sorento LX
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2019, 36000, 21950, 'https://images2.autotrader.com/hn/c/c7e88f0fc98847fe9036d0082f2d92cc.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Kia'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Sorento'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Sorento' AND t.name = 'LX'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Kia')
);
-- Car 26: Hyundai Elantra SEL
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 18000, 18990, 'https://images2.autotrader.com/hn/c/0529463a672d4e68a373244eefb2c23a.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Hyundai'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Elantra'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Elantra' AND t.name = 'SEL'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Hyundai')
);

-- Car 27: Mazda 3 Touring
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2017, 60000, 12950, 'https://images2.autotrader.com/hn/c/09bd2677b7a44eec8bfb353a4a064b0c.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Mazda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '3'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '3' AND t.name = 'Touring'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Marin Mazda')
);

-- Car 28: Toyota Highlander XLE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 15000, 38990, 'https://images.unsplash.com/photo-1502877338535-766e1452684a',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Highlander'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Highlander' AND t.name = 'XLE'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 29: Mercedes-Benz C300 Base
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2016, 70000, 20990, 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf',
    (SELECT id FROM makes WHERE name = 'Mercedes-Benz'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mercedes-Benz' AND m.name = 'C300'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mercedes-Benz' AND m.name = 'C300' AND t.name = 'Base'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 30: Nissan Rogue SV
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2024, 5000, 27990, 'https://images2.autotrader.com/hn/c/22520209d8154804b245908a67a26b56.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Nissan'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Rogue'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Rogue' AND t.name = 'SV'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 31: Toyota GR Supra 3.0
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 8000, 47900, 'https://images.unsplash.com/photo-1563720223185-11003d516935',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'GR Supra'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'GR Supra' AND t.name = '3.0'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 32: Honda CR-V EX
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2019, 34000, 24990, 'https://images2.autotrader.com/hn/c/ebdebb78cc1041699f25aeaff64d4185.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'CR-V'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'CR-V' AND t.name = 'EX'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 33: Toyota Avalon Limited
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 22000, 30990, 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Avalon'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Avalon' AND t.name = 'Limited'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 34: Hyundai Kona N Line
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2024, 4000, 25990, 'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023',
    (SELECT id FROM makes WHERE name = 'Hyundai'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Kona'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Kona' AND t.name = 'N Line'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Hyundai')
);

-- Car 35: Ford Explorer XLT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2017, 78000, 19950, 'https://images2.autotrader.com/hn/c/cd9a7e66b0104e7986b3cd47f29ea504.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Explorer'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Explorer' AND t.name = 'XLT'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 36: Mazda MX-5 Miata Club
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 6000, 29990, 'https://images2.autotrader.com/hn/c/1181dfc8f989425396cd4748abea1283.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Mazda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'MX-5 Miata'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'MX-5 Miata' AND t.name = 'Club'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Marin Mazda')
);

-- Car 37: Chevrolet Bolt EV LT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2018, 42000, 15990, 'https://images2.autotrader.com/hn/c/0eb941e863934141b9b2b12ae1da29df.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Chevrolet'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Bolt EV'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Bolt EV' AND t.name = 'LT'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 38: Lexus RX 350 Base
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2016, 69000, 24950, 'https://images2.autotrader.com/hn/c/4177af881f294c8b81a7b92279111130.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Lexus'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Lexus' AND m.name = 'RX 350'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Lexus' AND m.name = 'RX 350' AND t.name = 'Base'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 39: Subaru Crosstrek Premium
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 7000, 26990, 'https://images2.autotrader.com/hn/c/ef573f1a63aa4048ac79368a67877516.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Subaru'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Crosstrek'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Crosstrek' AND t.name = 'Premium'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 40: Honda Pilot EX-L
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2015, 98000, 15990, 'https://images2.autotrader.com/ps-vehicle-media/0a8945d3-f97f-486c-8d1a-80c7cac63662.jpeg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Pilot'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Pilot' AND t.name = 'EX-L'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 41: Toyota Prius Prime SE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 8000, 28990, 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius Prime'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius Prime' AND t.name = 'SE'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 42: Honda HR-V EX
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2024, 3000, 26990, 'https://images2.autotrader.com/hn/c/5e481a9a5ddb40d3bb40b1c1fa7a1b6f.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Honda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'HR-V'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'HR-V' AND t.name = 'EX'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Honda')
);

-- Car 43: Subaru Forester Limited
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 28000, 32990, 'https://images2.autotrader.com/hn/c/ef573f1a63aa4048ac79368a67877516.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Subaru'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Forester'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Forester' AND t.name = 'Limited'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 44: Ford Bronco Sport Badlands
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 12000, 35990, 'https://images2.autotrader.com/hn/c/cd9a7e66b0104e7986b3cd47f29ea504.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Bronco Sport'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Bronco Sport' AND t.name = 'Badlands'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 45: BMW M340i xDrive
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 15000, 51990, 'https://images2.autotrader.com/hn/c/6a08e81dd9fc4547b06f413e402e7db5.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'BMW'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M340i'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M340i' AND t.name = 'xDrive'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 46: Kia K5 GT-Line
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 22000, 24990, 'https://images2.autotrader.com/hn/c/c7e88f0fc98847fe9036d0082f2d92cc.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Kia'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'K5'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'K5' AND t.name = 'GT-Line'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'City Kia')
);

-- Car 47: Mazda 6 Grand Touring
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 35000, 24990, 'https://images2.autotrader.com/hn/c/0529463a672d4e68a373244eefb2c23a.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Mazda'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '6'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = '6' AND t.name = 'Grand Touring'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Marin Mazda')
);

-- Car 48: Audi Q5 Premium Plus
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 8000, 44990, 'https://images2.autotrader.com/hn/c/6a08e81dd9fc4547b06f413e402e7db5.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Audi'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'Q5'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'Q5' AND t.name = 'Premium Plus'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 49: Volkswagen Tiguan SEL
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 18000, 32990, 'https://images2.autotrader.com/hn/c/9ecc0c1ef9844055852afa01f70364ed.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Volkswagen'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Tiguan'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Volkswagen' AND m.name = 'Tiguan' AND t.name = 'SEL'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 50: Nissan Leaf SV
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 15000, 22990, 'https://images2.autotrader.com/hn/c/22520209d8154804b245908a67a26b56.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Nissan'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Leaf'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Leaf' AND t.name = 'SV'),
    (SELECT id FROM body_types WHERE name = 'Hatchback'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'SF EV Center')
);

-- Car 51: Toyota Sienna XLE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 25000, 42990, 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Sienna'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Sienna' AND t.name = 'XLE'),
    (SELECT id FROM body_types WHERE name = 'Wagon'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 52: Toyota Tacoma TRD Sport
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 12000, 39990, 'https://images2.autotrader.com/hn/c/2bc0b8d34af44761b8b7e499fd6ba868.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Tacoma'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Tacoma' AND t.name = 'TRD Sport'),
    (SELECT id FROM body_types WHERE name = 'Truck'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Livermore Toyota')
);

-- Car 53: Toyota Corolla Cross LE
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2024, 5000, 27990, 'https://images2.autotrader.com/hn/c/0c42fbd4da54493bbca94c3efc1ee8c8.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Toyota'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla Cross'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla Cross' AND t.name = 'LE'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'San Francisco Toyota')
);

-- Car 54: Chevrolet Camaro SS
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 25000, 35990, 'https://images.unsplash.com/photo-1493238792000-8113da705763',
    (SELECT id FROM makes WHERE name = 'Chevrolet'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Camaro'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Camaro' AND t.name = 'SS'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 55: Chevrolet Trailblazer LT
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 8000, 27990, 'https://images2.autotrader.com/hn/c/cd9a7e66b0104e7986b3cd47f29ea504.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Chevrolet'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Trailblazer'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Trailblazer' AND t.name = 'LT'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Bay Area Motors')
);

-- Car 56: Ford Escape Titanium
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2021, 30000, 28990, 'https://images2.autotrader.com/hn/c/cd9a7e66b0104e7986b3cd47f29ea504.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Ford'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Escape'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Escape' AND t.name = 'Titanium'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Golden Gate Ford')
);

-- Car 57: BMW M2 Base
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 5000, 59990, 'https://images2.autotrader.com/hn/c/6a08e81dd9fc4547b06f413e402e7db5.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'BMW'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M2'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'BMW' AND m.name = 'M2' AND t.name = 'Base'),
    (SELECT id FROM body_types WHERE name = 'Coupe'),
    (SELECT id FROM transmissions WHERE type = 'Manual'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 58: Audi A3 Premium
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2022, 15000, 32990, 'https://images2.autotrader.com/hn/c/09bd2677b7a44eec8bfb353a4a064b0c.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Audi'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A3'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Audi' AND m.name = 'A3' AND t.name = 'Premium'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Euro Auto SF')
);

-- Car 59: Nissan Maxima SL
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2020, 35000, 29990, 'https://images2.autotrader.com/hn/c/6797347887124fbe99ab5336cf1e0d4e.jpg?format=auto&width=408&height=306',
    (SELECT id FROM makes WHERE name = 'Nissan'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Maxima'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Maxima' AND t.name = 'SL'),
    (SELECT id FROM body_types WHERE name = 'Sedan'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'Peninsula Auto')
);

-- Car 60: Hyundai Ioniq 5 SEL
INSERT INTO cars (year, mileage, price, image_url, make_id, model_id, trim_id, body_type_id, transmission_id, condition_id, dealer_id) VALUES (
    2023, 12000, 39990, 'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023',
    (SELECT id FROM makes WHERE name = 'Hyundai'),
    (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Ioniq 5'),
    (SELECT t.id FROM trims t JOIN models m ON t.model_id = m.id JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Ioniq 5' AND t.name = 'SEL'),
    (SELECT id FROM body_types WHERE name = 'SUV'),
    (SELECT id FROM transmissions WHERE type = 'Automatic'),
    (SELECT id FROM conditions WHERE name = 'Used'),
    (SELECT id FROM dealers WHERE name = 'SF EV Center')
);
-- ============================================
-- INSERT CAR BADGES FOR ALL 60 CARS
-- ============================================

-- Car 1 badges (Hyundai Santa Fe Sport)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2017 AND make_id = (SELECT id FROM makes WHERE name = 'Hyundai') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Santa Fe')), (SELECT id FROM badges WHERE name = 'Great Price')),
((SELECT id FROM cars WHERE year = 2017 AND make_id = (SELECT id FROM makes WHERE name = 'Hyundai') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Santa Fe')), (SELECT id FROM badges WHERE name = 'No Accidents'));

-- Car 2 badges (Toyota Corolla LE)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2025 AND make_id = (SELECT id FROM makes WHERE name = 'Toyota') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla')), (SELECT id FROM badges WHERE name = 'Certified')),
((SELECT id FROM cars WHERE year = 2025 AND make_id = (SELECT id FROM makes WHERE name = 'Toyota') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Corolla')), (SELECT id FROM badges WHERE name = 'No Accidents'));

-- Car 3 badges (Chevrolet Corvette Stingray)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2019 AND make_id = (SELECT id FROM makes WHERE name = 'Chevrolet') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Corvette')), (SELECT id FROM badges WHERE name = 'Good Price'));

-- Car 4 badges (Honda Accord Sport)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2025 AND make_id = (SELECT id FROM makes WHERE name = 'Honda') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'Accord')), (SELECT id FROM badges WHERE name = 'Hybrid'));

-- Car 6 badges (Subaru Outback 2.5i)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2018 AND make_id = (SELECT id FROM makes WHERE name = 'Subaru') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Subaru' AND m.name = 'Outback')), (SELECT id FROM badges WHERE name = 'No Accidents'));

-- Car 7 badges (Tesla Model 3 Long Range)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2022 AND make_id = (SELECT id FROM makes WHERE name = 'Tesla') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Tesla' AND m.name = 'Model 3')), (SELECT id FROM badges WHERE name = 'Electric'));

-- Car 10 badges (Kia Soul Ex)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2021 AND make_id = (SELECT id FROM makes WHERE name = 'Kia') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Kia' AND m.name = 'Soul')), (SELECT id FROM badges WHERE name = 'Great Price'));

-- Car 14 badges (Toyota RAV4 XLE)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2019 AND make_id = (SELECT id FROM makes WHERE name = 'Toyota') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'RAV4')), (SELECT id FROM badges WHERE name = 'No Accidents'));

-- Car 16 badges (Ford Mustang GT)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2024 AND make_id = (SELECT id FROM makes WHERE name = 'Ford') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Mustang')), (SELECT id FROM badges WHERE name = 'Great Price'));

-- Car 22 badges (Toyota Prius LE)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2020 AND make_id = (SELECT id FROM makes WHERE name = 'Toyota') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius')), (SELECT id FROM badges WHERE name = 'Hybrid'));

-- Car 24 badges (Ford Focus SE)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2015 AND make_id = (SELECT id FROM makes WHERE name = 'Ford') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Ford' AND m.name = 'Focus')), (SELECT id FROM badges WHERE name = 'Great Price'));

-- Car 32 badges (Honda CR-V EX)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2019 AND make_id = (SELECT id FROM makes WHERE name = 'Honda') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Honda' AND m.name = 'CR-V')), (SELECT id FROM badges WHERE name = 'No Accidents'));

-- Car 36 badges (Mazda MX-5 Miata Club)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2022 AND make_id = (SELECT id FROM makes WHERE name = 'Mazda') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Mazda' AND m.name = 'MX-5 Miata')), (SELECT id FROM badges WHERE name = 'Great Price'));

-- Car 37 badges (Chevrolet Bolt EV LT)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2018 AND make_id = (SELECT id FROM makes WHERE name = 'Chevrolet') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Chevrolet' AND m.name = 'Bolt EV')), (SELECT id FROM badges WHERE name = 'Electric'));

-- Car 41 badges (Toyota Prius Prime SE)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2023 AND make_id = (SELECT id FROM makes WHERE name = 'Toyota') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Toyota' AND m.name = 'Prius Prime')), (SELECT id FROM badges WHERE name = 'Hybrid'));

-- Car 50 badges (Nissan Leaf SV)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2021 AND make_id = (SELECT id FROM makes WHERE name = 'Nissan') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Nissan' AND m.name = 'Leaf')), (SELECT id FROM badges WHERE name = 'Electric'));

-- Car 60 badges (Hyundai Ioniq 5 SEL)
INSERT INTO car_badges (car_id, badge_id) VALUES 
((SELECT id FROM cars WHERE year = 2023 AND make_id = (SELECT id FROM makes WHERE name = 'Hyundai') AND model_id = (SELECT m.id FROM models m JOIN makes mk ON m.make_id = mk.id WHERE mk.name = 'Hyundai' AND m.name = 'Ioniq 5')), (SELECT id FROM badges WHERE name = 'Electric'));

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check total counts
SELECT 'Makes' as table_name, COUNT(*) as count FROM makes
UNION ALL
SELECT 'Models' as table_name, COUNT(*) as count FROM models
UNION ALL
SELECT 'Trims' as table_name, COUNT(*) as count FROM trims
UNION ALL
SELECT 'Cars' as table_name, COUNT(*) as count FROM cars
UNION ALL
SELECT 'Car Badges' as table_name, COUNT(*) as count FROM car_badges;

-- Check cars with badges
SELECT 
    c.year,
    mk.name as make,
    m.name as model,
    t.name as trim,
    c.price,
    array_agg(b.name) as badges
FROM cars c
JOIN makes mk ON c.make_id = mk.id
JOIN models m ON c.model_id = m.id
LEFT JOIN trims t ON c.trim_id = t.id
LEFT JOIN car_badges cb ON c.id = cb.car_id
LEFT JOIN badges b ON cb.badge_id = b.id
GROUP BY c.id, c.year, mk.name, m.name, t.name, c.price
ORDER BY c.year DESC, mk.name, m.name;

-- Check badge distribution
SELECT 
    b.name as badge_name,
    COUNT(cb.car_id) as car_count
FROM badges b
LEFT JOIN car_badges cb ON b.id = cb.badge_id
GROUP BY b.name
ORDER BY car_count DESC;

-- Check all 60 cars are inserted
SELECT COUNT(*) as total_cars FROM cars;

-- Test car_listings view
SELECT 
    make_name,
    model_name,
    trim_name,
    year,
    price,
    badge_count,
    badge_names
FROM car_listings 
ORDER BY year DESC, price DESC
LIMIT 10;

-- Test filter_options view
SELECT * FROM filter_options 
WHERE filter_type = 'makes' 
ORDER BY label;

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE dealers IS 'Danh sách các nhà bán xe';
COMMENT ON TABLE makes IS 'Danh sách các hãng xe';
COMMENT ON TABLE models IS 'Danh sách các dòng xe theo hãng';
COMMENT ON TABLE trims IS 'Danh sách các phiên bản xe theo dòng';
COMMENT ON TABLE body_types IS 'Danh sách các kiểu dáng xe';
COMMENT ON TABLE transmissions IS 'Danh sách các loại hộp số';
COMMENT ON TABLE conditions IS 'Danh sách tình trạng xe';
COMMENT ON TABLE badges IS 'Danh sách các nhãn đặc biệt';
COMMENT ON TABLE cars IS 'Bảng chính chứa thông tin xe';
COMMENT ON TABLE car_badges IS 'Bảng liên kết nhiều-nhiều giữa xe và nhãn';
COMMENT ON TABLE filter_presets IS 'Bộ lọc đã lưu của người dùng';
COMMENT ON TABLE search_history IS 'Lịch sử tìm kiếm';

COMMENT ON VIEW car_listings IS 'View tổng hợp thông tin xe với tất cả dữ liệu liên quan';
COMMENT ON VIEW filter_options IS 'View cung cấp các tùy chọn lọc cho frontend';

-- ============================================
-- COMPLETE DATABASE SETUP FINISHED
-- ============================================
-- 
-- This script contains:
-- ✅ Complete PostgreSQL schema with all tables
-- ✅ All indexes for optimal performance  
-- ✅ Triggers for data validation and timestamps
-- ✅ Views for car listings and filter options
-- ✅ All 60 cars from mock-data.ts
-- ✅ All car badges and relationships
-- ✅ Verification queries to test the setup
--
-- Total expected records:
-- - 11 dealers
-- - 15 makes  
-- - 60+ models
-- - 60+ trims
-- - 7 body types
-- - 2 transmissions
-- - 2 conditions
-- - 6 badges
-- - 60 cars
-- - 20+ car-badge relationships
--
-- Usage:
-- 1. Run this script in PostgreSQL
-- 2. Execute verification queries to confirm setup
-- 3. Use car_listings view for main queries
-- 4. Use filter_options view for frontend dropdowns
--
-- ============================================
