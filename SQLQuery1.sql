/*

cleaning data in SQL queries

*/

select * 
from portfolio_project..nashville_housing;

--------------------------------------------------------------------------------------------------------

/* 

standardize date format

*/

select SaleDate,saledateconverted
from portfolio_project..nashville_housing;

alter table portfolio_project..nashville_housing
add saledateconverted date;

update portfolio_project..nashville_housing
set saledateconverted = CONVERT(date,SaleDate);

------------------------------------------------------------------------------------------------------


/* 

populate property address data (self join)

*/

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolio_project..nashville_housing a
join portfolio_project..nashville_housing b
on a.ParcelID =	b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

---------------------------------------------------------------------------------------------------

/* 

breaking out address into multiple columns (address, city, state)

*/

alter table portfolio_project..nashville_housing 
add property_split_address nvarchar(255);


update portfolio_project..nashville_housing
set property_split_address = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1);


alter table portfolio_project..nashville_housing 
add property_split_city nvarchar(255);

update portfolio_project..nashville_housing
set property_split_city = SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress));


alter table portfolio_project..nashville_housing 
add OwnerSplitAddress nvarchar(255);

update portfolio_project..nashville_housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

alter table portfolio_project..nashville_housing 
add OwnerSplitCity nvarchar(255);

update portfolio_project..nashville_housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

alter table portfolio_project..nashville_housing 
add OwnerSplitState nvarchar(255);

update portfolio_project..nashville_housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1);

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from portfolio_project..nashville_housing;

--------------------------------------------------------------------------------------------------------

/*

change y/n as Yes and No in "sold as vacant" field

*/

update portfolio_project..nashville_housing
set SoldAsVacant = 
					case
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					END;

SELECT DISTINCT(SoldAsVacant) FROM portfolio_project..nashville_housing;

-----------------------------------------------------------------------------------------------------------


/*

Remove duplicates

*/


with RowNumCTE as( 
select *,
ROW_NUMBER()over(partition by 
							ParcelID,PropertyAddress,
							SalePrice,SaleDate,
							LegalReference
							order By UniqueID) row_num
from portfolio_project..nashville_housing)
delete from RowNumCTE
where row_num > 1

-------------------------------------------------------------------------------------------------


/*

delete unused columns

*/

alter table portfolio_project..nashville_housing
drop column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate;

select * from portfolio_project..nashville_housing;




