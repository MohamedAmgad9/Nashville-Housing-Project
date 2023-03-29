

SELECT * 
FROM dbo.[NashvilleHousing];

/* Standarize Date Format */

SELECT SaleDateConverted ,CONVERT (Date , SaleDate)
FROM dbo.[NashvilleHousing];

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date , SaleDate)


/* Populate Property Address data */


SELECT *
FROM dbo.[NashvilleHousing]
--WHERE PropertyAddress is null
order by ParcelID


/*  Replace the Null Values in PropertyAddress */



SELECT a.ParcelID ,a.PropertyAddress , b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM dbo.[NashvilleHousing] a
JOIN dbo.[NashvilleHousing] b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


Update a
SET  PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
FROM dbo.[NashvilleHousing] a
JOIN dbo.[NashvilleHousing] b
	on a.ParcelID = b. ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



/* Breaking out PropertyAddress into Individual Columns (Address , City ) */

SELECT PropertyAddress
FROM dbo.[NashvilleHousing]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as  Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) as  Address
FROM dbo.[NashvilleHousing]


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) + 1 , LEN(PropertyAddress)) 



SELECT *
FROM dbo.[NashvilleHousing]


/* Breaking out OwnerAddress into Individual Columns (Address , City , State) */


Select OwnerAddress 
From dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)


SELECT * 
FROM dbo.[NashvilleHousing];



/*  Change Y  and N to Yes and No in "Sold As Vacant" field */

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN  SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.[NashvilleHousing]

Update [NashvilleHousing]
SET SoldAsVacant = CASE WHEN  SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN  SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


/* Remove Duplicates*/


WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress ,
				 SalePrice , 
				 SaleDate , 
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM dbo.[NashvilleHousing]
)
--DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress;


/* DELETE Unused Columns*/


ALTER TABLE  dbo.[NashvilleHousing]
DROP Column OwnerAddress , TaxDistrict , PropertyAddress , SaleDate

SELECT *
FROM dbo.[NashvilleHousing];
