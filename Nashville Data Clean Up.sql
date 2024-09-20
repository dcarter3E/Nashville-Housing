select *
from [Nashville Housing].dbo.Sheet1$;

------------------------------------------------------------------------------------
--Standarize Date Format in SaleDate column

--The code below wasn't working, so I used an ALTER TABLE command
--select SaleDate, CONVERT(date, SaleDate)
--from [Nashville Housing].dbo.Sheet1$;

--Update Sheet1$
--set SaleDate = CONVERT(date, SaleDate)

alter table Sheet1$
add SaleDateConverted date;

Update Sheet1$
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted, CONVERT(date, SaleDate)
from [Nashville Housing].dbo.Sheet1$;



-------------------------------------------------------------------------------------
--Populate PropertyAddress data where there were null values

select *
from [Nashville Housing].dbo.Sheet1$
where PropertyAddress is null;

select *
from [Nashville Housing].dbo.Sheet1$
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing].dbo.Sheet1$ as a
join [Nashville Housing].dbo.Sheet1$ as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashville Housing].dbo.Sheet1$ as a
join [Nashville Housing].dbo.Sheet1$ as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

select *
from [Nashville Housing].dbo.Sheet1$
where PropertyAddress is null;



-----------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State) using substring and charindex, parsename and replace 

--PropertyAddress split into Address and City
select PropertyAddress
from [Nashville Housing].dbo.Sheet1$;

select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from [Nashville Housing].dbo.Sheet1$;

alter table Sheet1$
add PropertySplitAddress nvarchar(255);

Update Sheet1$
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table Sheet1$
add PropertySplitCity nvarchar(255);

Update Sheet1$
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from [Nashville Housing].dbo.Sheet1$;



--OwnerAddress split into Address, City and State
select OwnerAddress
from [Nashville Housing].dbo.Sheet1$;

select 
parsename(replace(OwnerAddress, ',', '.') , 3) as Address,
parsename(replace(OwnerAddress, ',', '.') , 2) as City,
parsename(replace(OwnerAddress, ',', '.') , 1) as State
from [Nashville Housing].dbo.Sheet1$;


alter table Sheet1$
add OwnerSplitAddress nvarchar(255);

Update Sheet1$
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)

alter table Sheet1$
add OwnerSplitCity nvarchar(255);

Update Sheet1$
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)

alter table Sheet1$
add OwnerSplitState nvarchar(255);

Update Sheet1$
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)

select *
from [Nashville Housing].[dbo].[Sheet1$];


-----------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in SoldAsVacant column using case statements

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Nashville Housing].[dbo].[Sheet1$]
group by SoldAsVacant
order by 2;


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from [Nashville Housing].dbo.Sheet1$;


update Sheet1$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
					    when SoldAsVacant = 'N' then 'No'
					    else SoldAsVacant
					    end



-------------------------------------------------------------------------------------------------------------
--Remove duplicates using a row number, CTE and window functions of partition by

with RowNumCTE as (
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) as row_num
from [Nashville Housing].[dbo].[Sheet1$]
--order by ParcelID;
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress;


with RowNumCTE as (
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) as row_num
from [Nashville Housing].[dbo].[Sheet1$]
--order by ParcelID;
)
delete
from RowNumCTE
where row_num > 1
;


-------------------------------------------------------------------------------------------------------------
--Delete Unused Columns 

select *
from [Nashville Housing].[dbo].[Sheet1$]

alter table [Nashville Housing].[dbo].[Sheet1$]
drop column PropertyAddress, SaleDate, OwnerAddress,TaxDistrict  