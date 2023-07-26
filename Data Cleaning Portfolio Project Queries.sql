RENAME TABLE `nashville housing data for data cleaning` TO nashvillehousing;

/*
cleaning data in SQL queries
*/
SELECT * FROM nashvillehousing;


-- populate property address data


SELECT *
FROM nashvillehousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
JOIN nashvillehousing b 
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID;
-- WHERE a.PropertyAddress IS NULL;

UPDATE nashvillehousing a
JOIN nashvillehousing b 
	ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;


-- breaking out address individual columns (address, city, state)


SELECT PropertyAddress
FROM nashvillehousing;
-- WHERE PropertyAddress IS NULL
-- ORDER BY ParcelID;

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address,
       SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress)) AS Address
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT * FROM nashvillehousing;

SELECT OwnerAddress FROM nashvillehousing;

SELECT
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -3), ',', 1) AS Part1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS Part2,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Part3
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -3), ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

ALTER TABLE nashvillehousing
ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


-- change Y and N to Yes and No in "Sold As Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
         ElSE SoldAsVacant
	END
FROM nashvillehousing;

UPDATE nashvillehousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ElSE SoldAsVacant
END;


-- remove duplicates


WITH RowNumCTE AS 
(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
	ORDER BY UniqueID
	  ) AS ROW_NUM
FROM nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress;

DELETE nh
FROM nashvillehousing nh
JOIN (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS ROW_NUM
    FROM nashvillehousing
) AS RowNumCTE ON nh.UniqueID = RowNumCTE.UniqueID
WHERE RowNumCTE.ROW_NUM > 1;


-- delete unused columns


SELECT * FROM nashvillehousing;

ALTER TABLE nashvillehousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;
