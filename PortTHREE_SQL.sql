
-- Cleaning data using SQL

select * 
from PortfolioProjectOne.dbo.NashvilleHousing


-- Standardize date format

select SaleDate, CONVERT(date,SaleDate)
from PortfolioProjectOne.dbo.NashvilleHousing

update PortfolioProjectOne.dbo.NashvilleHousing
set saledate = CONVERT(date,SaleDate)

alter table PortfolioProjectOne.dbo.NashvilleHousing
add SaleDateConverted date;

update PortfolioProjectOne.dbo.NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

--Populate property address data

select *
from PortfolioProjectOne.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjectOne.dbo.NashvilleHousing a
join PortfolioProjectOne.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjectOne.dbo.NashvilleHousing a
join PortfolioProjectOne.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out address into individual columns (address, city,state)

select PropertyAddress
from PortfolioProjectOne.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
from PortfolioProjectOne.dbo.NashvilleHousing


alter table PortfolioProjectOne.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProjectOne.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 

alter table PortfolioProjectOne.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProjectOne.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) 

select *
from PortfolioProjectOne.dbo.NashvilleHousing

select OwnerAddress
from PortfolioProjectOne.dbo.NashvilleHousing

select PARSEName(Replace(OwnerAddress,',','.'),3),
PARSEName(Replace(OwnerAddress,',','.'),2),
PARSEName(Replace(OwnerAddress,',','.'),1)
from PortfolioProjectOne.dbo.NashvilleHousing

alter table PortfolioProjectOne.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProjectOne.dbo.NashvilleHousing
set OwnerSplitAddress = PARSEName(Replace(OwnerAddress,',','.'),3)

alter table PortfolioProjectOne.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProjectOne.dbo.NashvilleHousing
set OwnerSplitCity = PARSEName(Replace(OwnerAddress,',','.'),2)

alter table PortfolioProjectOne.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProjectOne.dbo.NashvilleHousing
set OwnerSplitState = PARSEName(Replace(OwnerAddress,',','.'),1)


--Change Y and N to yes and no in "SoldAsVacant" field

select distinct(SoldAsVacant), COUNT(soldasvacant)
from PortfolioProjectOne.dbo.NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant  = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProjectOne.dbo.NashvilleHousing

update PortfolioProjectOne.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant  = 'N' then 'No'
	 else SoldAsVacant
	 end

-- Removing Duplicates

with RowNumCTE as(
select *,
       row_number() over(
	   Partition by ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by 
					  UniqueId
					  ) row_num
from PortfolioProjectOne.dbo.NashvilleHousing
)
select*
from RowNumCTE
where row_num>1
order by PropertyAddress

-- Deleteing Unused Columns

select *
from PortfolioProjectOne.dbo.NashvilleHousing

Alter table PortfolioProjectOne.dbo.NashvilleHousing
drop column PropertyAddress, TaxDistrict, OwnerAddress

Alter table PortfolioProjectOne.dbo.NashvilleHousing
drop column SaleDate







