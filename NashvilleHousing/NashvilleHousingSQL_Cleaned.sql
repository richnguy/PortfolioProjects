/*

Cleaning Data in SQL Queries

*/

SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT
	SaleDateConverted, CONVERT(Date,SaleDate)
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Update Table

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- Did not work correctly, use ALTER TABLE

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing
WHERE 
	PropertyAddress IS NULL
ORDER BY ParcelID

SELECT 
	a.ParcelId, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashvilleHousing a 
	JOIN PortfolioProject.dbo.NashvilleHousing b 
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

-- Update the NULL PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	PortfolioProject.dbo.NashvilleHousing a 
	JOIN PortfolioProject.dbo.NashvilleHousing b 
		ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
WHERE
	a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select 
	PropertyAddress
FROM 
	PortfolioProject.dbo.NashvilleHousing
--WHERE 
	PropertyAddress is null
--ORDER
	by ParcelID

-- Separate by comma
SELECT
	SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Update Table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- Check (see columns at the very end)
SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Separte OwnerAddress

SELECT 
	OwnerAddress
FROM
	PortfolioProject.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Update Table

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

-- Check (see columns at the very end)
SELECT
	*
FROM
	PortfolioProject.dbo.NashvilleHousing

	
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT
	Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM
	PortfolioProject.dbo.NashvilleHousing
GROUP BY
	SoldAsVacant
ORDER BY
	2

-- Replace Y as Yes and N as No
SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM
	PortfolioProject.dbo.NashvilleHousing

-- Update Table

UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- CTE + Partition By

WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER
	(Partition BY	ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID) AS row_num
FROM
	PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT 
	*
FROM 
	RowNumCTE
WHERE
	row_num > 1
ORDER BY
	PropertyAddress

-- Delete

WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER
	(Partition BY	ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY UniqueID) AS row_num
FROM
	PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM 
	RowNumCTE
WHERE
	row_num > 1
-- ORDER BY
	-- PropertyAddress

	

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select 
	*
From 
	PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
	



