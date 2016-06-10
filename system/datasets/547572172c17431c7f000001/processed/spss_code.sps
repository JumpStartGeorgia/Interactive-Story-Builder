DATA LIST FILE= "/home/xtraktr-staging/Xtraktr-Staging/releases/20141121140917/public/system/datasets/547572172c17431c7f000001/processed/data_bad.csv"  free (",")
/ UID HomeBuildedDate OwnerOfHome Walls Floor Ceiling LivingS WholeS Kitchen Cellar Bath Garage WaterSource TypeOfToilet HowManyRooms HowManyBedRooms SellingPrice Rent UsedLandYesNo NumberOfPices WholeLand S_Q1 S_Q2 S_Q2a S_Q2b S_Q2c S_Q3 S_Q4 S_Q5 S_Q6 S_Q7 S_Q8 S_Q9  .

VARIABLE LABELS
UID "UID" 
 HomeBuildedDate "HomeBuildedDate" 
 OwnerOfHome "OwnerOfHome" 
 Walls "Walls" 
 Floor "Floor" 
 Ceiling "Ceiling" 
 LivingS "LivingS" 
 WholeS "WholeS" 
 Kitchen "Kitchen" 
 Cellar "Cellar" 
 Bath "Bath" 
 Garage "Garage" 
 WaterSource "WaterSource" 
 TypeOfToilet "TypeOfToilet" 
 HowManyRooms "HowManyRooms" 
 HowManyBedRooms "HowManyBedRooms" 
 SellingPrice "SellingPrice" 
 Rent "Rent" 
 UsedLandYesNo "UsedLandYesNo" 
 NumberOfPices "NumberOfPices" 
 WholeLand "WholeLand" 
 S_Q1 "S_Q1" 
 S_Q2 "S_Q2" 
 S_Q2a "S_Q2a" 
 S_Q2b "S_Q2b" 
 S_Q2c "S_Q2c" 
 S_Q3 "S_Q3" 
 S_Q4 "S_Q4" 
 S_Q5 "S_Q5" 
 S_Q6 "S_Q6" 
 S_Q7 "S_Q7" 
 S_Q8 "S_Q8" 
 S_Q9 "S_Q9" 
 .

VALUE LABELS
/
HomeBuildedDate  
1 "After 2000" 
 2 "1995 -1999" 
 3 "1990-1994" 
 4 "1980-1989" 
 5 "1960-1979" 
 6 "1950-1959" 
 7 "1940-1949" 
 8 "1930-1939" 
 9 "1920-1929" 
 10 "Before 1920" 
 11 "Don’t know" 
/
OwnerOfHome  
1 "Belongs to the household" 
 2 "Rented" 
 3 "Mortgaged" 
 4 "Used without payment" 
 5 "Don’t know" 
/
Walls  
1 "Brick,  block, stone" 
 2 "Wood" 
 3 "Concrete slabs" 
 4 "Ground, mud, adobe" 
 5 "Other" 
 6 "Mixed" 
 7 "Don’t know" 
/
Floor  
1 "Stone, brick, concrete" 
 2 "Wood" 
 3 "Parquet" 
 4 "Laminate" 
 5 "Ground" 
 6 "Other" 
 7 "Don’t know" 
/
Ceiling  
1 "Tin" 
 2 "Schist/tile" 
 3 "Concrete" 
 4 "Wood" 
 5 "Metal tile" 
 6 "Other" 
 7 "Don’t know" 
/
Kitchen  
1 "Belongs to the household only" 
 2 "Shared" 
 3 "Doesn't have" 
/
Cellar  
1 "Belongs to the household only" 
 2 "Shared" 
 3 "Doesn't have" 
/
Bath  
1 "Belongs to the household only" 
 2 "Shared" 
 3 "Doesn't have" 
/
Garage  
1 "Belongs to the household only" 
 2 "Shared" 
 3 "Doesn't have" 
/
WaterSource  
1 "The water supply system installed in the dwelling" 
 2 "The water system tap in the yard or vicinity" 
 3 "The well in the yard or vicinity" 
 4 "Natural spring in the yard or vicinity" 
 5 "River, lake, spring, channel" 
 6 "Bought water" 
 7 "Other" 
/
TypeOfToilet  
1 "Own flush toilet connected to the sewerage system" 
 2 "Shared flush toilet connected to the sewerage system" 
 3 "Flush latrine not connected to the sewerage system (connected to the river, channel, ravine, etc.)" 
 4 "Pit latrine periodically cleaned or finally filled up and buried" 
 5 "Other" 
/
UsedLandYesNo  
1 "Yes" 
 2 "No" 
/
S_Q1  
1 "Good – no limitations on spending money" 
 2 "Middle – we satisfy our daily material needs easily" 
 3 "Satisfactory – we more or less manage to satisfy our daily needs" 
 4 "Bad – our income (harvest) is only enough for food" 
 5 "Very bad – our income (harvest) is not enough even for food" 
/
S_Q2  
1 "Rich" 
 2 "Well-off" 
 3 "Middle" 
 4 "Poor" 
 5 "Extremely poor" 
/
S_Q2a  
1 "Yes" 
 2 "No" 
/
S_Q2b  
1 "Yes" 
 2 "No" 
/
S_Q2c  
1 "Our family doesn't require social assistance" 
 2 "I don't know where to apply" 
 3 "I don't hope to get the assistance" 
 4 "I can’t do it myself and there is nobody to whom I can address for help" 
 5 "I consider it being humiliating for family" 
 6 "Other" 
 7 "It’s difficult to answer" 
/
S_Q4  
1 "Has worsened very much" 
 2 "Has slightly worsened" 
 3 "Has not changed" 
 4 "Has slightly improved" 
 5 "Has improved very much" 
/
S_Q5  
1 "Will be worsened very much" 
 2 "Will be worsened slightly" 
 3 "Won't be changed" 
 4 "Will be improved slightly" 
 5 "Will be improved very much" 
 6 "Don’t  know" 
/
S_Q6  
1 "It is well-repaired" 
 2 "It doesn't need any repairing at this stage" 
 3 "It needs cosmetic repairing" 
 4 "It needs overall repairing" 
 5 "If it is not immediately repaired, it will be ruined" 
/
S_Q9  
1 "Yes, permanently" 
 2 "Yes, periodically" 
 3 "No" 
.

EXECUTE.
