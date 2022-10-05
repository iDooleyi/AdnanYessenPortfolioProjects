SELECT*
FROM PortfolioProject..NashvilleHousing

-- standardise the format of the date, by removing the time section of the current date format

SELECT SaleDate2, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add SaleDate2 Date

Update NashvilleHousing
Set SaleDate2 = CONVERT(date, SaleDate)

-- Fill in the remaining property addresses that are empty using the Parcel IDs 

SELECT*
FROM PortfolioProject..NashvilleHousing
Order by ParcelID --the parcel IDs match the addresses

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- This query joins the table to itself and selects the same columns from both tables, where table A returns the null values and table B shows the same ParcleID with the populated Address, then use the isnull function to tell it what to replace the null values with 
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.parcelID = b. ParcelID 
	And a.[UniqueID] <> b. [UniqueID]
WHERE a.PropertyAddress is null

Update a -- now updated 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.parcelID = b. ParcelID 
	And a.[UniqueID] <> b. [UniqueID]
WHERE a.PropertyAddress is null

-- Splitting Property address into two columns: address and city using Substring

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address -- Looking at Property Address, from the first letter, looking specifically for the delimeter using charindex. -1 to exclude the delimeter in the results
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City -- Second part of the address on the other side of the delimeter requires slightly more work. We are not starting from the first character but rather from after the delimeter (which is the second condition), the final condition makes sure the result ends at the "length"/end of the address  
FROM PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
Add PropertyAddressSplit Nvarchar(255)

Update NashvilleHousing
Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertyCitySplit Nvarchar(255)

Update NashvilleHousing
Set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- Changing the Y and N values in "Sold as vacant" field to yes and no using CASE statements - the current dataset has a combinations of Y/N/Yes/NO, so will standardise to just yes and no

SELECT Distinct(SoldAsVacant), COUNT(soldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group By SoldAsVacant 
Order By 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END 
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END 

-- Remove Duplicates using CTE/Row_Number/Partition
-- row_number allows you to identify when a specific row has been repeated for the second or more times, so that they may be deleted. To do this, we're partitioning by columns that should not be repeated (otherwise there is a duplicate)


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1 -- brings up all the 2s which are the dupes

-- Deleting unused columns 

SELECT*
FROM PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
DROP Column TaxDistrict, PropertyAddress, SaleDate



