
-- Cleaning Data with SQL queries

-----------------------------------------------------------------------------------------------------
--1- Standardize Data format

SELECT SaleDate
FROM HouseInfo

UPDATE HouseInfo
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HouseInfo
ADD SaleDateConverted Date;

UPDATE HouseInfo
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM HouseInfo

-----------------------------------------------------------------------------------------------------

 --2- Property Address Data
 --There are NULL Data in the Property Address Column but when we check the data
 --the correct property address already exist in the same parcel id so we can
 --take it from there.

 --Checking the null property address data
SELECT *
FROM HouseInfo
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--We will join on the same table by using parcel id

SELECT x.ParcelID,x.PropertyAddress,y.ParcelID,y.PropertyAddress,ISNULL(x.PropertyAddress,y.PropertyAddress)
FROM HouseInfo AS x
JOIN HouseInfo AS y
	ON x.ParcelID=y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL

--We filled the blank

UPDATE x
SET PropertyAddress = ISNULL(x.PropertyAddress,y.PropertyAddress)
FROM HouseInfo AS x
JOIN HouseInfo AS y
	ON x.ParcelID=y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
WHERE x.PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------
--3- Breaking out the PropertyAddress and the OwnerAddress columns into Individual Columns(Address,City,State)
--First let's break out the property address column into

SELECT PropertyAddress
FROM HouseInfo

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM HouseInfo 

ALTER TABLE HouseInfo
ADD PropertySplitAddress NVARCHAR(250)

UPDATE HouseInfo
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE HouseInfo
ADD PropertySplitCity NVARCHAR(250)

UPDATE HouseInfo
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT PropertySplitAddress,PropertySplitCity
FROM HouseInfo

--Let's break out OwnnerAddress Column into Individual Columns(Address,City,State)

SELECT OwnerAddress
FROM HouseInfo

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3), --Address
PARSENAME(REPLACE(OwnerAddress,',','.'),2), --City
PARSENAME(REPLACE(OwnerAddress,',','.'),1)  --State
FROM HouseInfo

ALTER TABLE HouseInfo
ADD OwnerSplitAddress NVARCHAR(250)

UPDATE HouseInfo
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE HouseInfo
ADD OwnerSplitCity NVARCHAR(250)

UPDATE HouseInfo
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE HouseInfo
ADD OwnerSplitState NVARCHAR(250)

UPDATE HouseInfo
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM HouseInfo
WHERE OwnerSplitAddress IS NOT NULL


-----------------------------------------------------------------------------------------------------

--4- Changing Y to Yes and N to N in the 'Sold as Vacant' field


SELECT DISTINCT(SoldAsVacant),count(SoldAsVacant)
FROM HouseInfo
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant


--Let's use CASE statement in order to change Y to Yes and N to No
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM HouseInfo


UPDATE HouseInfo
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END


-----------------------------------------------------------------------------------------------------

--5-Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID
		) AS ROW_NUM
FROM HouseInfo
--ORDER BY ParcelID
)
 
DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1





-----------------------------------------------------------------------------------------------------

--6-Deleting Unused Columns


SELECT *
FROM HouseInfo

ALTER TABLE HouseInfo
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress



-----------------------------------------------------------------------------------------------------