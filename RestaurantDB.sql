-- SQL DDL Script for PostgreSQL
CREATE DATABASE Restaurants;

-- Restaurant Table
CREATE TABLE Restaurant (
    RestaurantID SERIAL PRIMARY KEY,
    RestaurantName VARCHAR(255) NOT NULL,
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    Website VARCHAR(255),
    OperatingHours TEXT,
    CuisineType VARCHAR(100),
    -- Add other relevant restaurant details as needed
    SeatingCapacity INT,
    Ambiance VARCHAR(255)
);

-- Menu Table
CREATE TABLE Menu (
    MenuID SERIAL PRIMARY KEY,
    RestaurantID INT NOT NULL REFERENCES Restaurant(RestaurantID),
    MenuName VARCHAR(255) NOT NULL,
    Description TEXT,
    EffectiveDate DATE,
    EndDate DATE,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- RawMenuImage Table
CREATE TABLE RawMenuImage (
    ImageID SERIAL PRIMARY KEY,
    MenuID INT NOT NULL REFERENCES Menu(MenuID),
    ImageURL VARCHAR(255),
    UploadTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID)
);

-- ExtractedMenuItem Table
CREATE TABLE ExtractedMenuItem (
    ItemID SERIAL PRIMARY KEY,
    MenuID INT NOT NULL REFERENCES Menu(MenuID),
    ItemName VARCHAR(255) NOT NULL,
    Description TEXT,
    Category VARCHAR(100),
    SubCategory VARCHAR(100),
    Price DECIMAL(10, 2),
    Currency VARCHAR(10),
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID)
);

-- Dish Table
CREATE TABLE Dish (
    DishID SERIAL PRIMARY KEY,
    ItemID INT,
    DishName VARCHAR(255),
    Description TEXT,
    PreparationTime INT, -- in minutes
    DietaryRestrictions VARCHAR(255), -- e.g., "Vegetarian, Gluten-Free"
    Allergens VARCHAR(255), -- e.g., "Nuts, Dairy"
    FOREIGN KEY (ItemID) REFERENCES ExtractedMenuItem(ItemID)
);

-- Alcohol Table
CREATE TABLE Alcohol (
    AlcoholID SERIAL PRIMARY KEY,
    AlcoholType VARCHAR(50) NOT NULL, -- e.g., "Beer", "Wine", "Spirits"
    Brand VARCHAR(100),
    Name VARCHAR(255) NOT NULL,
    RegionOrigin VARCHAR(100),
    ABV DECIMAL(4, 2), -- Alcohol by Volume
    TastingNotes TEXT
);

-- Wine Table (inherits from Alcohol)
CREATE TABLE Wine (
    WineID INT PRIMARY KEY REFERENCES Alcohol(AlcoholID),
    GrapeVarietal VARCHAR(100),
    Vintage INT,
    Body VARCHAR(50), -- e.g., "Light", "Medium", "Full"
    Acidity VARCHAR(50), -- e.g., "High", "Medium", "Low"
    Sweetness VARCHAR(50), -- e.g., "Dry", "Off-Dry", "Sweet"
    FOREIGN KEY (WineID) REFERENCES Alcohol(AlcoholID)
);

-- AlcoholPairing Table
CREATE TABLE AlcoholPairing (
    PairingID SERIAL PRIMARY KEY,
    DishID INT NOT NULL REFERENCES Dish(DishID),
    AlcoholID INT NOT NULL REFERENCES Alcohol(AlcoholID),
    PairingNotes TEXT
    -- Removed redundant foreign key constraints
);

-- User Table (for end-consumers)
CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Email VARCHAR(100) UNIQUE
    -- Add other user-related information as needed
);

-- RestaurantUser Table (for users associated with restaurants)
CREATE TABLE RestaurantUser (
    RestaurantUserID SERIAL PRIMARY KEY,
    RestaurantID INT NOT NULL REFERENCES Restaurant(RestaurantID),
    UserID INT NOT NULL REFERENCES Users(UserID),
    Role VARCHAR(50), -- e.g., "Manager", "Staff"
    -- Removed redundant foreign key constraints
    UNIQUE (RestaurantID, UserID) -- Ensure a user has a unique role per restaurant
);

-- Ingredients Table (Optional)
CREATE TABLE IF NOT EXISTS Ingredient (
    IngredientID SERIAL PRIMARY KEY,
    IngredientName VARCHAR(255) NOT NULL,
    Description TEXT,
    UnitOfMeasure VARCHAR(50)
);

-- DishIngredient Table (Optional - Many-to-Many between Dish and Ingredient)
CREATE TABLE IF NOT EXISTS DishIngredient (
    DishIngredientID SERIAL PRIMARY KEY,
    DishID INT NOT NULL REFERENCES Dish(DishID),
    IngredientID INT NOT NULL REFERENCES Ingredient(IngredientID),
    Quantity DECIMAL(10, 2),
    -- Removed redundant foreign key constraints
    UNIQUE (DishID, IngredientID) -- Ensure no duplicate ingredients per dish
);

-- Promotions Table (Optional)
CREATE TABLE IF NOT EXISTS Promotion (
    PromotionID SERIAL PRIMARY KEY,
    RestaurantID INT NOT NULL,
    PromotionName VARCHAR(255) NOT NULL,
    Description TEXT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID)
);

-- PromotionItem Table (Optional - Linking Promotions to Menu Items or Dishes)
CREATE TABLE IF NOT EXISTS PromotionItem (
    PromotionItemID SERIAL PRIMARY KEY,
    PromotionID INT NOT NULL,
    ItemID INT, -- Link to ExtractedMenuItem
    DishID INT, -- Link to Dish
    Discount DECIMAL(5, 2),
    FOREIGN KEY (PromotionID) REFERENCES Promotion(PromotionID),
    FOREIGN KEY (ItemID) REFERENCES ExtractedMenuItem(ItemID),
    FOREIGN KEY (DishID) REFERENCES Dish(DishID),
    CONSTRAINT FK_PromotionItem_ItemOrDish CHECK (
        (ItemID IS NOT NULL AND DishID IS NULL) OR (ItemID IS NULL AND DishID IS NOT NULL)
    )
);

-- CustomerReview Table (Optional)
CREATE TABLE IF NOT EXISTS CustomerReview (
    ReviewID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    RestaurantID INT, -- Reviewing the restaurant
    DishID INT, -- Reviewing a specific dish
    Rating DECIMAL(2, 1), -- e.g., 1 to 5
    Comment TEXT,
    ReviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID),
    FOREIGN KEY (DishID) REFERENCES Dish(DishID),
    CONSTRAINT FK_Review_RestaurantOrDish CHECK (
        (RestaurantID IS NOT NULL AND DishID IS NULL) OR (RestaurantID IS NULL AND DishID IS NOT NULL)
    )
);

-- Tag Table (Optional)
CREATE TABLE IF NOT EXISTS Tag (
    TagID SERIAL PRIMARY KEY,
    TagName VARCHAR(100) UNIQUE NOT NULL
);

-- DishTag Table (Optional - Many-to-Many between Dish and Tag)
CREATE TABLE IF NOT EXISTS DishTag (
    DishTagID SERIAL PRIMARY KEY,
    DishID INT NOT NULL,
    TagID INT NOT NULL,
    FOREIGN KEY (DishID) REFERENCES Dish(DishID),
    FOREIGN KEY (TagID) REFERENCES Tag(TagID),
    UNIQUE (DishID, TagID)
);

-- RestaurantTag Table (Optional - Many-to-Many between Restaurant and Tag)
CREATE TABLE IF NOT EXISTS RestaurantTag (
    RestaurantTagID SERIAL PRIMARY KEY,
    RestaurantID INT NOT NULL,
    TagID INT NOT NULL,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurant(RestaurantID),
    FOREIGN KEY (TagID) REFERENCES Tag(TagID),
    UNIQUE (RestaurantID, TagID)
);

-- Consider adding indexes to frequently queried columns, especially foreign keys.
CREATE INDEX idx_restaurantid_menu ON Menu (RestaurantID);
CREATE INDEX idx_menuid_rawmenuimage ON RawMenuImage (MenuID);
CREATE INDEX idx_menuid_extractedmenuitem ON ExtractedMenuItem (MenuID);
CREATE INDEX idx_itemid_dish ON Dish (ItemID);
CREATE INDEX idx_dishid_alcoholpairing ON AlcoholPairing (DishID);
CREATE INDEX idx_alcoholid_alcoholpairing ON AlcoholPairing (AlcoholID);
CREATE INDEX idx_restaurantid_restaurantuser ON RestaurantUser (RestaurantID);
CREATE INDEX idx_userid_restaurantuser ON RestaurantUser (UserID);
-- Add more indexes as needed based on your query patterns.
-- The following indexes are kept as they are generally compatible, but PostgreSQL might handle them slightly differently.