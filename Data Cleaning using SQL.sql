select * from protfolioProject..housing

-- Standradize Date Format
select SaleDate  , SaleDateConverted from protfolioProject..housing

Update protfolioProject..housing 
Set SaleDate = CONVERT(Date,SaleDate)

Alter table protfolioProject..housing  
add SaleDateConverted Date

Update protfolioProject..housing 
Set SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data 
select * 
from protfolioProject..housing
-- where PropertyAddress is null
order by ParcelID


select p.ParcelID , p.PropertyAddress ,s.ParcelID , s.PropertyAddress , 
ISNULL(p.PropertyAddress,s.PropertyAddress)
from protfolioProject..housing as p
join protfolioProject..housing as s
on p.ParcelID = s.ParcelID
and p.[UniqueID] <> s.[UniqueID ]
where p.PropertyAddress is null

update p
Set PropertyAddress = ISNULL(p.PropertyAddress,s.PropertyAddress)
from protfolioProject..housing as p
join protfolioProject..housing as s
on p.ParcelID = s.ParcelID
and p.[UniqueID] <> s.[UniqueID ]
where p.PropertyAddress is null

-- Breaking out Adress into Indiviual Columns (Address , City , State)
select PropertyAddress  
from protfolioProject..housing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as city
from protfolioProject..housing

Alter table protfolioProject..housing  
add PropertySplitAddress Nvarchar(225)

Update protfolioProject..housing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter table protfolioProject..housing  
add PropertySplitCity Nvarchar(225)

Update protfolioProject..housing 
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

select PropertySplitAddress , PropertySplitCity 
from protfolioProject..housing 

select OwnerAddress 
from protfolioProject..housing 
-- where OwnerAddress is null


select 
PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,3)
,PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,2)
,PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,1	)
from protfolioProject..housing 
where OwnerAddress is not null

Alter table protfolioProject..housing  
add OwnerSplitAddress Nvarchar(225)

Update protfolioProject..housing 
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,3)

Alter table protfolioProject..housing  
add OwnerSplitCity Nvarchar(225)

Update protfolioProject..housing 
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,2)

Alter table protfolioProject..housing  
add OwnerSplitState Nvarchar(225)

Update protfolioProject..housing 
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress , ',' , '.') ,1)

select 
OwnerSplitState, OwnerSplitCity , OwnerSplitAddress
from protfolioProject..housing 
where OwnerAddress is not null

-- Change Y , and N to Yes and No in "Sold as Vacant" Field 
Select Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
from  protfolioProject..housing 
Group by SoldAsVacant 
Order by SoldAsVacant


select SoldAsVacant
, Case when SoldAsVacant= 'Y' then 'Yes'
	   when SoldAsVacant= 'N' then 'No'
	   ELSE SoldAsVacant
	   END	
from  protfolioProject..housing 

update protfolioProject..housing 
set SoldAsVacant = Case when SoldAsVacant= 'Y' then 'Yes'
	   when SoldAsVacant= 'N' then 'No'
	   ELSE SoldAsVacant
	   END	

-- Remove Duplicates 
WITH RowNumCTE As(
select *,  
	ROW_NUMBER() over(
	PARTITION BY ParcelID ,
				PropertyAddress ,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num
from protfolioProject..housing 
) select * from RowNumCTE
where row_num > 1
order by PropertyAddress


WITH RowNumCTE As(
select *,  
	ROW_NUMBER() over(
	PARTITION BY ParcelID ,
				PropertyAddress ,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num
from protfolioProject..housing 
) delete 
from RowNumCTE
where row_num > 1

--Delete Unused Columns 
ALter table protfolioProject..housing 
drop Column OwnerAddress , TaxDistrict , PropertyAddress 

ALter table protfolioProject..housing 
drop Column SaleDate

select * from protfolioProject..housing 