SELECT COUNT(*) FROM nashville_housing;

LOAD DATA LOCAL INFILE '/Users/kasthumathan/Desktop/Work/Freelancing/Learning/Full Project/5. Nashville Housing (Data Cleaning)/Nashville Housing Data for Data Cleaning.csv'
INTO TABLE nashville_housing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM nashville_housing;

CREATE TABLE nashville_housing_staging
LIKE nashville_housing;

INSERT nashville_housing_staging
SELECT * FROM nashville_housing;

-- Standardize Date Format
SELECT SaleDate FROM nashville_housing_staging;

SELECT SaleDate, STR_TO_DATE(
	REGEXP_REPLACE(SaleDate, '([0-9]+)(st|nd|rd|th)', '\\1'),
    '%M %d, %Y') AS standardized_date
FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET SaleDate = STR_TO_DATE(
    REGEXP_REPLACE(SaleDate, '([0-9]+)(st|nd|rd|th)', '\\1'),
    '%M %d, %Y'
);

SELECT * FROM nashville_housing_staging;

-- Populate Property Address Data
SELECT * FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET 
    PropertyAddress = NULLIF(PropertyAddress, ''),
    OwnerName = NULLIF(OwnerName, ''),
    OwnerAddress = NULLIF(OwnerAddress, ''),
    Acreage = NULLIF(Acreage, ''),
    TaxDistrict = NULLIF(TaxDistrict, ''),
    LandValue = NULLIF(LandValue, ''),
    BuildingValue = NULLIF(BuildingValue, ''),
    TotalValue = NULLIF(TotalValue, ''),
    YearBuilt = NULLIF(YearBuilt, ''),
    Bedrooms = NULLIF(Bedrooms, ''),
    FullBath = NULLIF(FullBath, ''),
    HalfBath = NULLIF(HalfBath, '')
WHERE PropertyAddress = '' OR OwnerName = '' OR OwnerAddress = '' OR Acreage = '' OR TaxDistrict = '' OR LandValue = '' OR BuildingValue = '' OR TotalValue = ''
	OR YearBuilt = '' OR Bedrooms = '' OR FullBath = '' OR HalfBath = '';

SELECT * FROM nashville_housing_staging
WHERE PropertyAddress IS NULL;

SELECT COUNT(*) 
FROM nashville_housing_staging
WHERE PropertyAddress IS NULL;

SELECT * FROM nashville_housing_staging
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashville_housing_staging a
JOIN nashville_housing_staging b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing_staging a
JOIN nashville_housing_staging b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE nashville_housing_staging a
JOIN nashville_housing_staging b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT * FROM nashville_housing_staging;

ALTER TABLE nashville_housing_staging
ADD COLUMN PropertySplitAddress VARCHAR(255);

UPDATE nashville_housing_staging
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashville_housing_staging
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE nashville_housing_staging
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);
    
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity FROM nashville_housing_staging;

-- Owner Address
SELECT OwnerAddress FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET OwnerAddress = REPLACE(OwnerAddress, '/', ',');

SELECT 
    OwnerAddress,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS OwnerSplitAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerSplitCity,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerSplitState
FROM nashville_housing_staging
LIMIT 10;

-- Owner Split Address
ALTER TABLE nashville_housing_staging
ADD COLUMN OwnerSplitAddress VARCHAR(255);

SELECT OwnerSplitAddress FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));

-- Owner Split City
ALTER TABLE nashville_housing_staging
ADD COLUMN OwnerSplitCity VARCHAR(255);

SELECT OwnerSplitCity FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

-- Owner Split State
ALTER TABLE nashville_housing_staging
ADD COLUMN OwnerSplitState VARCHAR(255);

SELECT OwnerSplitState FROM nashville_housing_staging;

UPDATE nashville_housing_staging
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant FROM nashville_housing_staging;

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM nashville_housing_staging
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT DISTINCT SoldAsVacant,
       CASE 
           WHEN SoldAsVacant = 'N' THEN 'No'
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           ELSE SoldAsVacant
       END AS SoldVacant
FROM nashville_housing_staging;

UPDATE nashville_housing_staging
set SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END;



-- Remove Duplicates
SELECT * FROM nashville_housing_staging;

SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ORDER BY UniqueID
    ) AS row_num
FROM nashville_housing_staging
ORDER BY ParcelID; -- Look for other similar data's other than Unique ID, Unique ID maybe different but the others may be the same

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
    ) AS row_num
	FROM nashville_housing_staging
	-- ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE FROM nashville_housing_staging
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
            ) AS row_num
        FROM nashville_housing_staging
    ) AS RowNumCTE
    WHERE row_num > 1
);

-- Delete Unused Columns
SELECT * FROM nashville_housing_staging;

ALTER TABLE nashville_housing_staging
DROP COLUMN PropertyAddress;

ALTER TABLE nashville_housing_staging
DROP COLUMN OwnerAddress;

ALTER TABLE nashville_housing_staging
DROP COLUMN TaxDistrict;














